import SwiftUI

struct RadarView: View {
    @Binding var foundTargets: [Target]
    var onFound: () -> Void
    
    @StateObject private var ckService = CloudKitService()
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            // TESTI DI STATO
            if ckService.isSearching {
                Text("Scanning Area...")
                    .font(.headline)
                    .padding(.top, 60)
            } else if !ckService.nearbyTargets.isEmpty {
                Text("Targets Acquired!")
                    .font(.headline)
                    .foregroundColor(Color(red: 60/255, green: 80/255, blue: 100/255))
                    .padding(.top, 60)
            } else {
                Text("No targets found.")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top, 60)
            }
            
            Spacer()
            
            ZStack {
                // CERCHI RADAR
                Circle().stroke(Color.white.opacity(0.8), lineWidth: 1).frame(width: 150)
                Circle().stroke(Color.white.opacity(0.6), lineWidth: 1).frame(width: 250)
                
                if ckService.isSearching {
                    // PALLINE ANIMATE
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color(red: 100/255, green: 150/255, blue: 200/255).opacity(0.6))
                            .frame(width: 20, height: 20)
                            .offset(x: 125)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false).delay(Double(i)*0.5), value: isAnimating)
                    }
                } else if !ckService.nearbyTargets.isEmpty {
                    // ICONA SUCCESSO
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(red: 100/255, green: 180/255, blue: 120/255))
                        .shadow(radius: 10)
                } else {
                    // ICONA FALLIMENTO
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red.opacity(0.6))
                }
            }
            .onAppear {
                isAnimating = true
                ckService.startScanning()
            }
            // AUTOMAZIONE
            .onChange(of: ckService.isSearching) { oldValue, isSearching in
                if !isSearching && !ckService.nearbyTargets.isEmpty {
                    self.foundTargets = ckService.nearbyTargets
                    // Ritardo l'auto-navigazione per farti vedere la spunta verde
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onFound()
                    }
                }
            }
            
            Spacer()
            
            // --- PIANO B: BOTTONE MANUALE ---
            // Se l'automazione fallisce ma i dati ci sono, appare questo bottone
            if !ckService.isSearching && !ckService.nearbyTargets.isEmpty {
                Button(action: {
                    self.foundTargets = ckService.nearbyTargets
                    onFound()
                }) {
                    Text("View Targets Now")
                        .fontWeight(.bold)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .foregroundColor(Color(red: 60/255, green: 80/255, blue: 100/255))
                        .cornerRadius(30)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 50)
            }
            
            // TASTO RIPROVA (Se non trova nessuno)
            if !ckService.isSearching && ckService.nearbyTargets.isEmpty {
                Button("Try Again") {
                    ckService.startScanning()
                }
                .padding(.bottom, 50)
            }
        }
    }
}
