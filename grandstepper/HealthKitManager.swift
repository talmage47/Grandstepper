import Foundation
import HealthKit

@MainActor
@Observable
final class HealthKitManager {
    private let store = HKHealthStore()

    var steps: Int = 0
    var distanceMeters: Double = 0
    var isAuthorized: Bool = false
    var errorMessage: String?

    private var stepsQuery: HKQuery?
    private var distanceQuery: HKQuery?

    private let stepsType = HKQuantityType(.stepCount)
    private let distanceType = HKQuantityType(.distanceWalkingRunning)

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Health data is not available on this device."
            return
        }
        do {
            try await store.requestAuthorization(toShare: [], read: [stepsType, distanceType])
            isAuthorized = true
            startObserving()
        } catch {
            errorMessage = "Could not access Health data."
        }
    }

    private func startObserving() {
        observe(type: stepsType) { [weak self] in await self?.refreshSteps() }
        observe(type: distanceType) { [weak self] in await self?.refreshDistance() }
        Task {
            await refreshSteps()
            await refreshDistance()
        }
    }

    private func observe(type: HKQuantityType, onUpdate: @escaping () async -> Void) {
        let query = HKObserverQuery(sampleType: type, predicate: nil) { _, completion, _ in
            Task { await onUpdate() }
            completion()
        }
        store.execute(query)
        store.enableBackgroundDelivery(for: type, frequency: .immediate) { _, _ in }
    }

    private func todayPredicate() -> NSPredicate {
        let start = Calendar.current.startOfDay(for: Date())
        return HKQuery.predicateForSamples(withStart: start, end: nil, options: .strictStartDate)
    }

    private func refreshSteps() async {
        let total = await sumQuantity(type: stepsType, unit: .count())
        steps = Int(total)
    }

    private func refreshDistance() async {
        distanceMeters = await sumQuantity(type: distanceType, unit: .meter())
    }

    private func sumQuantity(type: HKQuantityType, unit: HKUnit) async -> Double {
        await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: todayPredicate(),
                options: .cumulativeSum
            ) { _, statistics, _ in
                let value = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }
}
