//
//  RiotRateLimiter.swift
//  LeagueOfLegendsData
//
//  Created by Jungwoon Ko on 2/3/26.
//
import Foundation

actor RiotRateLimiter {
    // Limits
    private let burstCount = 20
    private let burstWindow: TimeInterval = 1.0
    
    private let longCount = 100
    private let longWindow: TimeInterval = 120.0
    
    // Timestamps of granted permits (monotonic time)
    private var granted: [TimeInterval] = []
    
    /// Wait until it's legal to perform the next request
    /// Call this immediately before making a Riot API request
    func acquire() async throws {
        while true {
            try Task.checkCancellation()
            
            let now = Self.now()
            
            // Drop timestamps outside the largest window (120s)
            let cutoff = now - longWindow
            if !granted.isEmpty {
                // granted is in chronological order; drop old entries
                var idx = 0
                while idx < granted.count, granted[idx] < cutoff { idx += 1 }
                if idx > 0 { granted.removeFirst(idx) }
            }
            
            // Count requests inside each window
            let burstCutoff = now - burstWindow
            let burstUsed = granted.count - firstIndexGE(granted, burstCutoff)
            let longUsed = granted.count
            
            // If both limits allow it, grant immediately
            if burstUsed < burstCount, longUsed < longCount {
                granted.append(now)
                return
            }
            
            // Otherwise, compute how long to wait until at least one limit frees up
            var waitSeconds: TimeInterval = 0
            
            if burstUsed >= burstCount {
                // the (burstCount-th most recent within 1s) determines when we can proceed
                let burstIndex = firstIndexGE(granted, burstCutoff)
                let oldestBurst = granted[burstIndex] // first within 1s window
                waitSeconds = max(waitSeconds, (oldestBurst + burstWindow) - now)
            }
            
            if longUsed >= burstCount {
                // the oldest timestamp in the last 120s determines when we can proceed
                let oldestLong = granted[0]
                waitSeconds = max(waitSeconds, (oldestLong + longWindow) - now)
            }
            
            // Sleep a tiny bit longer to avoid "edge" violations due to clock granularity.
            let nanos = UInt64((waitSeconds + 0.01) * 1_000_000_000)
            try await Task.sleep(nanoseconds: max(nanos, 1_000_000))
        }
    }
    
    // MARK: - Helpers
    
    /// Monotonic time in seconds
    private static func now() -> TimeInterval {
        Double(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
    }
    
    /// Returns the first index i where array[i] >= value, assuming array is sorted
    private func firstIndexGE(_ array: [TimeInterval], _ value: TimeInterval) -> Int {
        var lo = 0
        var hi = array.count
        while lo < hi {
            let mid = (lo + hi) / 2
            if array[mid] < value { lo = mid + 1 } else { hi = mid }
        }
        return lo
    }
}
