import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            // --- INIZIO ILLUSTRAZIONE CUSTOM ---
            ZStack {
                // 1. IL CIELO (Sfondo del finestrino)
                RoundedRectangle(cornerRadius: 100) // Forma del finestrino (oblunga)
                    .fill(Color(red: 200/255, green: 230/255, blue: 255/255)) // Azzurro cielo
                    .frame(width: 240, height: 340)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.white, lineWidth: 12) // Bordo bianco spesso
                    )
                    .shadow(radius: 10, x: 0, y: 5) // Ombra per dare profondità
                
                // Maschera per ritagliare tutto ciò che esce dal finestrino
                ZStack {
                    // 2. LE NUVOLE (Cerchi bianchi semi-trasparenti)
                    Group {
                        Circle().fill(Color.white.opacity(0.6)).frame(width: 100).offset(x: -60, y: -80)
                        Circle().fill(Color.white.opacity(0.6)).frame(width: 120).offset(x: 50, y: -100)
                        Circle().fill(Color.white.opacity(0.4)).frame(width: 80).offset(x: 20, y: 50)
                    }
                    
                    // 3. GLI ALBERI (Visti dall'alto/lontano)
                    // Usiamo SF Symbols per creare una foresta in basso
                    HStack(spacing: -10) {
                        Image(systemName: "tree.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 100/255, green: 160/255, blue: 180/255)) // Verde/Bluastro
                            .offset(y: 80)
                        Image(systemName: "tree.fill")
                            .font(.system(size: 55))
                            .foregroundColor(Color(red: 90/255, green: 150/255, blue: 170/255))
                            .offset(y: 90)
                        Image(systemName: "tree.fill")
                            .font(.system(size: 45))
                            .foregroundColor(Color(red: 100/255, green: 160/255, blue: 180/255))
                            .offset(y: 80)
                    }
                    .offset(x: -40, y: 40) // Posizioniamo la foresta in basso a sinistra
                    
                    // 4. L'ALA DELL'AEREO (Forma geometrica custom)
                    WingShape()
                        .fill(Color.white) // Ala bianca
                        .frame(width: 280, height: 150)
                        .shadow(radius: 5)
                        .rotationEffect(.degrees(10)) // Leggera inclinazione
                        .offset(x: 40, y: 20) // Posizionata a destra
                }
                .mask(RoundedRectangle(cornerRadius: 100).frame(width: 240, height: 340)) // Taglia tutto ciò che esce dai bordi
                
            }
            .padding(.top, 40)
            // --- FINE ILLUSTRAZIONE ---
            
            Text("Welcome to GateMate")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 60/255, green: 80/255, blue: 100/255)) // Blu scuro elegante
                .padding(.top, 40)
            
            Text("Turn your layover into a connection.\nFind people, fly together.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 5)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color(red: 100/255, green: 150/255, blue: 200/255)) // Testo azzurro
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}

// --- FORMA PERSONALIZZATA PER L'ALA ---
struct WingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Disegno un'ala stilizzata
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY + 50)) // Inizio in alto a destra
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 40)) // Punta dell'ala
        path.addLine(to: CGPoint(x: rect.minX + 80, y: rect.maxY)) // Parte sotto
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Ritorno alla fusoliera
        path.closeSubpath()
        return path
    }
}

// Preview per vedere il risultato subito
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 176/255, green: 205/255, blue: 222/255).edgesIgnoringSafeArea(.all)
            WelcomeView(onContinue: {})
        }
    }
}
