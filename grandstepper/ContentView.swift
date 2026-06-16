import SwiftUI

private let stepsColor = Color(red: 0.55, green: 0.80, blue: 1.00)
private let milesColor = Color(red: 0.55, green: 1.00, blue: 0.70)

struct ContentView: View {
    @State private var health = HealthKitManager()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                VStack(spacing: 0) {
                    MetricView(label: "STEPS", value: stepsText, color: stepsColor)
                        .frame(height: geo.size.height / 2)
                    MetricView(label: "MILES", value: milesText, color: milesColor)
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

    private var milesText: String {
        let miles = health.distanceMeters / 1609.344
        return String(format: "%.2f", miles)
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
    let miles: String

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                VStack(spacing: 0) {
                    MetricView(label: "STEPS", value: steps, color: stepsColor)
                        .frame(height: geo.size.height / 2)
                    MetricView(label: "MILES", value: miles, color: milesColor)
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
    PreviewLayout(steps: "4,247", miles: "1.47")
}

#Preview("Big numbers") {
    PreviewLayout(steps: "18,432", miles: "8.74")
}

#Preview("Empty") {
    PreviewLayout(steps: "0", miles: "0.00")
}
