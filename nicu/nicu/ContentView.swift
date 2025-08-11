import SwiftUI
import Charts

// MARK: - Data Model for Graphing
// A simple identifiable structure to hold data points for the charts.
struct VitalDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Main App Structure
// This is the entry point of the application.

struct HealthPassthroughApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.plain)

        ImmersiveSpace(id: "HealthMetrics") {
            HealthMetricsView()
        }
    }
}

// MARK: - Content View
// This view automatically opens the immersive space when it appears.
struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @State private var hasOpenedSpace = false

    var body: some View {
        VStack {
            Text("Loading Vitals...")
                .font(.title)
        }
        .onAppear {
            if !hasOpenedSpace {
                Task {
                    await openImmersiveSpace(id: "HealthMetrics")
                    hasOpenedSpace = true
                }
            }
        }
    }
}


// MARK: - Health Metrics View
// This view now includes graphs on the left and the stats panel on the right.
struct HealthMetricsView: View {
    // State variables for current vital signs
    @State private var heartRate: Double = 75
    @State private var spo2: Double = 98
    @State private var bloodPressureSystolic: Double = 120
    @State private var bloodPressureDiastolic: Double = 80
    @State private var temperature: Double = 98.6
    
    // State variables to hold historical data for graphs
    @State private var heartRateHistory: [VitalDataPoint] = []
    @State private var spo2History: [VitalDataPoint] = []
    @State private var bpSystolicHistory: [VitalDataPoint] = []
    @State private var bpDiastolicHistory: [VitalDataPoint] = []

    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 40) {
            // Left side: Graphs
            VStack(spacing: 20) {
                VitalGraphView(title: "Heart Rate (BPM)", data: heartRateHistory, color: .red)
                VitalGraphView(title: "SpO2 (%)", data: spo2History, color: .blue)
                BloodPressureGraphView(systolicData: bpSystolicHistory, diastolicData: bpDiastolicHistory)
            }
            .padding(30)
            .background(.thinMaterial)
            .cornerRadius(20)

            // Right side: Vitals Panel
            VStack(spacing: 20) {
                HealthMetricView(name: "Heart Rate", value: "\(Int(heartRate))", unit: "BPM", icon: "heart.fill", color: colorForHeartRate())
                HealthMetricView(name: "SpO2", value: "\(Int(spo2))", unit: "%", icon: "lungs.fill", color: colorForSpO2())
                HealthMetricView(name: "Blood Pressure", value: "\(Int(bloodPressureSystolic))/\(Int(bloodPressureDiastolic))", unit: "mmHg", icon: "waveform.path.ecg", color: colorForBloodPressure())
                HealthMetricView(name: "Temperature", value: String(format: "%.1f", temperature), unit: "°F", icon: "thermometer", color: colorForTemperature())
            }
            .padding(30)
            .background(.thinMaterial)
            .cornerRadius(20)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: setupInitialData)
        .onReceive(timer) { _ in
            updateVitals()
        }
    }
    
    // MARK: - Data and Color Logic
    
    func setupInitialData() {
        for _ in 0..<20 {
            updateVitals(isInitialSetup: true)
        }
    }
    
    func colorForHeartRate() -> Color { (60...100).contains(heartRate) ? .green : .red }
    func colorForSpO2() -> Color { (95...100).contains(spo2) ? .green : .red }
    func colorForBloodPressure() -> Color {
        let isSystolicNormal = (90...120).contains(bloodPressureSystolic)
        let isDiastolicNormal = (60...80).contains(bloodPressureDiastolic)
        return isSystolicNormal && isDiastolicNormal ? .green : .red
    }
    func colorForTemperature() -> Color { (97.8...99.1).contains(temperature) ? .green : .red }

    func updateVitals(isInitialSetup: Bool = false) {
        let updateAnimation: Animation? = isInitialSetup ? nil : .easeInOut
        
        withAnimation(updateAnimation) {
            // Generate new values
            if Int.random(in: 1...5) == 1 { heartRate = Bool.random() ? Double.random(in: 40...59) : Double.random(in: 101...140) } else { heartRate = Double.random(in: 60...100) }
            if Int.random(in: 1...5) == 1 { spo2 = Double.random(in: 90...94) } else { spo2 = Double.random(in: 95...100) }
            if Int.random(in: 1...5) == 1 {
                bloodPressureSystolic = Bool.random() ? Double.random(in: 80...89) : Double.random(in: 121...140)
                bloodPressureDiastolic = Bool.random() ? Double.random(in: 50...59) : Double.random(in: 81...90)
            } else {
                bloodPressureSystolic = Double.random(in: 90...120)
                bloodPressureDiastolic = Double.random(in: 60...80)
            }
            if Int.random(in: 1...5) == 1 { temperature = Bool.random() ? Double.random(in: 96.0...97.7) : Double.random(in: 99.2...100.4) } else { temperature = Double.random(in: 97.8...99.1) }

            // Update history arrays
            let now = Date()
            heartRateHistory.append(VitalDataPoint(date: now, value: heartRate))
            spo2History.append(VitalDataPoint(date: now, value: spo2))
            bpSystolicHistory.append(VitalDataPoint(date: now, value: bloodPressureSystolic))
            bpDiastolicHistory.append(VitalDataPoint(date: now, value: bloodPressureDiastolic))
            
            // Keep history to a fixed size
            if heartRateHistory.count > 20 { heartRateHistory.removeFirst() }
            if spo2History.count > 20 { spo2History.removeFirst() }
            if bpSystolicHistory.count > 20 { bpSystolicHistory.removeFirst() }
            if bpDiastolicHistory.count > 20 { bpDiastolicHistory.removeFirst() }
        }
    }
}


// MARK: - Health Metric View
// Reusable view for a single numerical health metric.
struct HealthMetricView: View {
    let name: String, value: String, unit: String, icon: String, color: Color

    var body: some View {
        HStack {
            Image(systemName: icon).font(.largeTitle).foregroundColor(color).frame(width: 60)
            VStack(alignment: .leading) {
                Text(name).font(.title2).foregroundColor(.secondary)
                Text(value).font(.system(size: 50, weight: .bold)).foregroundColor(color).contentTransition(.numericText())
            }
            Spacer()
            Text(unit).font(.title2).foregroundColor(.secondary).padding(.trailing)
        }
        .frame(width: 400, height: 100)
    }
}

// MARK: - Graph Views
// A reusable view for displaying a single-line vital graph.
struct VitalGraphView: View {
    let title: String
    let data: [VitalDataPoint]
    let color: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.title2).foregroundColor(.secondary)
            Chart(data) {
                LineMark(x: .value("Time", $0.date), y: .value("Value", $0.value))
                    .foregroundStyle(color)
                    .interpolationMethod(.catmullRom)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 100)
        }
        .frame(width: 400)
    }
}

// A specific view for the two-line blood pressure graph.
struct BloodPressureGraphView: View {
    let systolicData: [VitalDataPoint]
    let diastolicData: [VitalDataPoint]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Blood Pressure (mmHg)").font(.title2).foregroundColor(.secondary)
            Chart {
                ForEach(systolicData) {
                    LineMark(x: .value("Time", $0.date), y: .value("Systolic", $0.value))
                        .foregroundStyle(.orange)
                        .interpolationMethod(.catmullRom)
                }
                ForEach(diastolicData) {
                    LineMark(x: .value("Time", $0.date), y: .value("Diastolic", $0.value))
                        .foregroundStyle(.yellow)
                        .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 100)
        }
        .frame(width: 400)
    }
}

// MARK: - Preview
#Preview {
    HealthMetricsView()
}
