import SwiftUI

// MARK: - Main App Structure
// This is the entry point of the application.
// It sets up the main window group and the immersive space for the health data display.

struct HealthPassthroughApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Using .plain window style to make the initial launching window less intrusive.
        .windowStyle(.plain)

        // Define the immersive space where the health data will be displayed.
        ImmersiveSpace(id: "HealthMetrics") {
            HealthMetricsView()
        }
    }
}

// MARK: - Content View
// This view now automatically opens the immersive space when it appears.
struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @State private var hasOpenedSpace = false

    var body: some View {
        VStack {
            // This text will be briefly visible as the immersive space launches.
            Text("Loading Vitals...")
                .font(.title)
        }
        .onAppear {
            // We check if the space has already been opened to avoid trying to open it multiple times.
            if !hasOpenedSpace {
                Task {
                    // Asynchronously open the immersive space.
                    await openImmersiveSpace(id: "HealthMetrics")
                    hasOpenedSpace = true
                }
            }
        }
    }
}


// MARK: - Health Metrics View
// This view now positions the stats panel on the right side of the screen.
struct HealthMetricsView: View {
    // State variables to hold the randomly generated health data.
    @State private var heartRate: Double = 75
    @State private var spo2: Double = 98
    @State private var bloodPressureSystolic: Double = 120
    @State private var bloodPressureDiastolic: Double = 80
    @State private var temperature: Double = 98.6

    // Use a timer to periodically refresh the health data every 2 seconds.
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        // We use an HStack with a Spacer to push the content to the right.
        HStack {
            Spacer() // This spacer expands to push the VStack to the far right.

            VStack(spacing: 20) {
                // Display each vital sign in its own view, using the state variables.
                HealthMetricView(name: "Heart Rate", value: "\(Int(heartRate))", unit: "BPM", icon: "heart.fill")
                HealthMetricView(name: "SpO2", value: "\(Int(spo2))", unit: "%", icon: "lungs.fill")
                HealthMetricView(name: "Blood Pressure", value: "\(Int(bloodPressureSystolic))/\(Int(bloodPressureDiastolic))", unit: "mmHg", icon: "waveform.path.ecg")
                HealthMetricView(name: "Temperature", value: String(format: "%.1f", temperature), unit: "°F", icon: "thermometer")
            }
            .padding(30)
            .background(.thinMaterial) // This creates the glassmorphism effect.
            .cornerRadius(20)
        }
        // Add padding to the whole container to keep it from the screen edges.
        .padding(.trailing, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the HStack fills the available space.
        .onAppear(perform: updateVitals) // Set initial values when the view appears.
        .onReceive(timer) { _ in
            // Update values every time the timer fires.
            updateVitals()
        }
    }
    
    // This function generates new random values for each vital sign
    // within a typical healthy range.
    func updateVitals() {
        withAnimation {
            heartRate = Double.random(in: 60...100)
            spo2 = Double.random(in: 95...100)
            bloodPressureSystolic = Double.random(in: 110...130)
            bloodPressureDiastolic = Double.random(in: 70...85)
            temperature = Double.random(in: 97.8...99.1)
        }
    }
}


// MARK: - Health Metric View
// A reusable view to display a single health metric.
// This view remains unchanged as its role is purely for display.
struct HealthMetricView: View {
    let name: String
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.cyan) // Changed color for visual flair
                .frame(width: 60)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(value)
                    .font(.system(size: 50, weight: .bold))
                    .contentTransition(.numericText()) // Animate number changes
            }
            
            Spacer()
            
            Text(unit)
                .font(.title2)
                .foregroundColor(.white)
                .padding(.trailing)
        }
        .frame(width: 400, height: 100)
    }
}

// MARK: - Preview
// This struct provides the preview for Xcode's canvas.
// By separating it from the main App struct, we avoid the multiple-entry-point error.
#Preview {
    HealthMetricsView()
}

