//
//  LeagueSaveAllEngine.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 1/4/26.
//

/// A value type representing a single fetch-and-save task.
/// Each job fully specifies *what* data should be fetched and *where* it should be saved.
///
/// - High tiers:
///  - `division` and `page` are `nil`
///
/// - Low tiers:
///  - `division` and `page` must be non-nil
///
///  Conforming to `Hashable` allows future extensions such as
///  deduplication, retry tracking, or persistence.
struct FetchJob: Hashable {
    let server: Server
    let queue: RankQueue
    let tier: TierSelection
    let division: Division?
    let page: Int?
}

/// An actor responsible for orchestrating the "save all league data" pipeline.
///
/// Responsibilities:
/// - Generate all required fetch jobs
/// - Execute jobs sequentially
/// - Fetch data from the network via `LeagueServicign`
/// - Persists results via `LeaguFileService`
/// - Report progress to the caller
///
/// Non-responsibilities:
/// - UI state management
/// - Thread hopping to `MainActor`
/// - View lifecycle awareness
///
/// The actor isolation guarantees:
/// - No data races
/// - Predictable execution order
/// - Safe coordination of network and file I/O
actor LeagueSaveAllEngine {
    
    private let service: LeagueServicing
    private let fileService: LeagueFileService
    private let limiter = RiotRateLimiter()
    
    init(service: LeagueServicing, fileService: LeagueFileService) {
        self.service = service
        self.fileService = fileService
    }
    
    /// Executes all league fetch-and-save jobs sequentially
    ///
    /// - Parameters:
    ///  - servers: Servers to fetch data from (e.g. NA1, KR)
    ///  - queues: Ranked queues to fetch (e.g. RANKED\_SOLO\_5X5)
    ///  - lowPages: Page range for low-tier pagination
    ///  - onProgress: Async callback invoked after each completed job
    ///
    /// Progress rporting is delegated to the caller.
    /// The engine itself is UI-agnostic and does not assume `MainActor`.
    ///
    /// Cancellation:
    /// - The loop cooperatively checks `Task.isCancelled`
    /// - Execution stops gracefully without leaving partial state
    func saveAll (
        servers: [Server],
        queues: [RankQueue],
        lowPages: ClosedRange<Int>,
        onProgress: @MainActor @Sendable (Int, Int) async -> Void
    ) async throws {
        
        let jobs = makeJobs(servers: servers, queues: queues, lowPages: lowPages)
        let total = jobs.count
        var done = 0
        
        // Exectue jobs sequentially to:
        // - Avoid API rate-limit spikes
        // - Prevent disk write contention
        // - Keep memory usage predictable
        for job in jobs {
            if Task.isCancelled { return }
            try await run(job)
            done += 1
            await onProgress(done, total)
        }
    }
    
    /// Executes a single fetch-and-save job.
    ///
    /// This method:
    /// - Fetches league data from the API
    /// - Persists the result to disk
    ///
    /// Invariants:
    /// - High-tier jobs never require `division` or `page`
    /// - Low-tier jobs must always include both
    private func run(_ job: FetchJob) async throws {
        switch job.tier {
        case .high(let highTier):
            try await limiter.acquire()
            let dto = try await service.fetchHighTier(job.server, highTier, job.queue)
            try await fileService.saveHighTier(dto, job.server, highTier, job.queue)
            
        case .low(let lowTier):
            guard let division = job.division, let page = job.page else { return }
            try await limiter.acquire()
            let dto = try await service.fetchLowTier(job.server, division, lowTier, job.queue, page)
            try await fileService.saveLowTier(dto, job.server, division, lowTier, job.queue, page)
        }
    }
    
    /// Generates all fetch jobs required to fully cover the league dataset
    ///
    /// - High tiers:
    ///  - server x queue x tier
    ///
    /// - Low tiers:
    ///  - server x queue x tier x division x page
    ///
    ///  This method is intentionally determinisitc and side-effect free.
    private func makeJobs (
        servers: [Server],
        queues: [RankQueue],
        lowPages: ClosedRange<Int>
    ) -> [FetchJob] {
        var jobs: [FetchJob] = []
        
        // High tiers
        for server in servers {
            for queue in queues {
                for high in HighTier.allCases {
                    jobs.append(.init(server: server, queue: queue, tier: .high(high), division: nil, page: nil))
                }
            }
        }
        
        // Low tiers
        for server in servers {
            for queue in queues {
                for low in LowTier.allCases {
                    for division in Division.allCases {
                        for page in lowPages {
                            jobs.append(.init(server: server, queue: queue, tier: .low(low), division: division, page: page))
                        }
                    }
                }
            }
        }
        
        return jobs
    }
}
