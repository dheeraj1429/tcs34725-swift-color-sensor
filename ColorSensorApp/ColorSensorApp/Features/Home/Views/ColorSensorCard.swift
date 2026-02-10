import SwiftUI

struct ColorSensorCard: View {
    let data: SensorColorResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Text("Live Color Sensor")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "sensor.fill")
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack {
                Circle()
                    .fill(data.displayColor)
                    .frame(width: 60, height: 60)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 5)
                
                VStack(alignment: .leading) {
                    Text("Lux: \(Int(data.lux))")
                        .font(.title2)
                        .bold()
                    Text("Ambient Light Level")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
            
            Divider().background(Color.white.opacity(0.5))
            
            HStack(spacing: 20) {
                ValueLabel(label: "R", value: data.r, color: .red)
                ValueLabel(label: "G", value: data.g, color: .green)
                ValueLabel(label: "B", value: data.b, color: .blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(data.displayColor.opacity(0.3))
                .background(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .frame(width: 300)
        .padding()
    }
}

struct ValueLabel: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .bold()
                .foregroundColor(color)
            Text("\(Int(value))")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ColorSensorCard(data: SensorColorResponse(r: 45000, g: 12000, b: 50000, c: 1000, lux: 1200))
    }
}
