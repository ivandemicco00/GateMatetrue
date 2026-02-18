import SwiftUI

struct WindowMatchView: View {
    // CAMBIATO: Accetta array di Target
    var targets: [Target]
    var onRestart: () -> Void
    
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            if targets.isEmpty {
                Text("No targets in range.")
                Button("Scan Again", action: onRestart)
            } else {
                // Prendi il target corrente
                let target = targets[currentIndex]
                
                ZStack {
                    // Contenuto Finestrino
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        
                        Text(target.name)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text(target.flightInfo)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .frame(width: 260, height: 380)
                    .background(Color.red.opacity(0.6)) // Sfondo rosso per "Target"
                    
                    // Cornice Finestrino
                    RoundedRectangle(cornerRadius: 110)
                        .stroke(Color.white, lineWidth: 25)
                        .frame(width: 290, height: 410)
                }
                
                // Controlli
                HStack {
                    Button(action: { if currentIndex > 0 { currentIndex -= 1 } }) {
                        Image(systemName: "arrow.left.circle.fill").font(.largeTitle)
                    }.disabled(currentIndex == 0)
                    
                    Spacer()
                    
                    Button(action: { if currentIndex < targets.count - 1 { currentIndex += 1 } }) {
                        Image(systemName: "arrow.right.circle.fill").font(.largeTitle)
                    }.disabled(currentIndex == targets.count - 1)
                }
                .padding(.horizontal, 50)
                .padding(.top, 20)
            }
        }
    }
}
