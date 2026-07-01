import SwiftUI

private let stepsColor = Color(red: 0.55, green: 0.80, blue: 1.00)
private let distanceColor = Color(red: 0.55, green: 1.00, blue: 0.70)

struct ContentView: View {
    @State private var health = HealthKitManager()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                VStack(spacing: 0) {
                    MetricView(label: "STEPS", value: stepsText, color: stepsColor)
                        .frame(height: geo.size.height / 2)
                    MetricView(label: distanceLabel, value: distanceText, color: distanceColor)
                        .frame(height: geo.size.height / 2)
                }
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geo.size.width - 32, height: 2)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .ignoresSafeArea()
        .task {
            await health.requestAuthorization()
        }
    }

    private var stepsText: String {
        health.steps.formatted(.number)
    }

    private var usesMetric: Bool {
        Locale.current.measurementSystem == .metric
    }

    private var distanceLabel: String {
        usesMetric ? "KILOMETERS" : "MILES"
    }

    private var distanceText: String {
        let value = usesMetric ? health.distanceMeters / 1000 : health.distanceMeters / 1609.344
        return String(format: "%.2f", value)
    }
}

private struct MetricView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .foregroundStyle(color.opacity(0.75))
            Text(value)
                .font(.system(size: 160, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.3)
                .lineLimit(1)
                .foregroundStyle(color)
                .padding(.horizontal, 16)
        }
    }
}

private struct PreviewLayout: View {
    let steps: String
    let distanceLabel: String
    let distance: String

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                VStack(spacing: 0) {
                    MetricView(label: "STEPS", value: steps, color: stepsColor)
                        .frame(height: geo.size.height / 2)
                    MetricView(label: distanceLabel, value: distance, color: distanceColor)
                        .frame(height: geo.size.height / 2)
                }
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geo.size.width - 32, height: 2)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview("Typical day") {
    PreviewLayout(steps: "4,247", distanceLabel: "MILES", distance: "1.47")
}

#Preview("Big numbers") {
    PreviewLayout(steps: "18,432", distanceLabel: "MILES", distance: "8.74")
}

#Preview("Metric") {
    PreviewLayout(steps: "4,247", distanceLabel: "KILOMETERS", distance: "2.37")
}

#Preview("Empty") {
    PreviewLayout(steps: "0", distanceLabel: "MILES", distance: "0.00")
}
