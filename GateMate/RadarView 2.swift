import SwiftUI

struct RadarView: View {
    @Binding var foundTargets: [Target]
    var onFound: () -> Void
    var onBack: () -> Void
    
    @StateObject private var ckService = CloudKitService()
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            // Back Button (Cancel Search)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 50)
            
            // Status Text
            if ckService.isSearching {
                Text("Scanning Area...")
                    .font(.headline)
                    .padding(.top, 20)
            } else if !ckService.nearbyTargets.isEmpty {
                Text("Targets Acquired!")
                    .font(.headline)
                    .foregroundColor(Color(red: 60/255, green: 80/255, blue: 100/255))
                    .padding(.top, 20)
            } else {
                Text("No targets nearby.")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            // Radar UI
            ZStack {
                Circle().stroke(Color.white.opacity(0.8), lineWidth: 1).frame(width: 150)
                Circle().stroke(Color.white.opacity(0.6), lineWidth: 1).frame(width: 250)
                
                if ckService.isSearching {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color(red: 100/255, green: 150/255, blue: 200/255).opacity(0.6))
                            .frame(width: 20, height: 20)
                            .offset(x: 125)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false).delay(Double(i)*0.5), value: isAnimating)
                    }
                } else if !ckService.nearbyTargets.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(red: 100/255, green: 180/255, blue: 120/255))
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red.opacity(0.6))
                }
            }
            .onAppear {
                isAnimating = true
                ckService.startScanning()
            }
            .onChange(of: ckService.isSearching) { oldValue, isSearching in
                if !isSearching && !ckService.nearbyTargets.isEmpty {
                    self.foundTargets = ckService.nearbyTargets
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onFound()
                    }
                }
            }
            
            Spacer()
            
            // Manual Retry Button
            if !ckService.isSearching && ckService.nearbyTargets.isEmpty {
                Button("Try Again") {
                    ckService.startScanning()
                }
                .padding(.bottom, 50)
            }
        }
    }
}
