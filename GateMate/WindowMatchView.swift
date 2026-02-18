import SwiftUI

struct WindowMatchView: View {
    var targets: [Target]
    var onRestart: () -> Void
    
    @State private var currentIndex = 0
    @State private var shadeOffset: CGFloat = -400
    @State private var isAnimating = false
    
    // Dimensioni fisse per il finestrino interno
    let windowWidth: CGFloat = 260
    let windowHeight: CGFloat = 380
    
    var body: some View {
        ZStack {
            Color(red: 176/255, green: 205/255, blue: 222/255)
                .edgesIgnoringSafeArea(.all)
            
            if targets.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.6))
                    Text("No passengers found nearby.")
                        .font(.headline)
                        .foregroundColor(.white)
                    Button("Try Again", action: onRestart)
                        .padding().background(Color.white).foregroundColor(.blue).cornerRadius(10)
                }
            } else {
                VStack {
                    Spacer()
                    
                    // --- WINDOW AREA ---
                    ZStack(alignment: .top) {
                        
                        // === ZONA CONTENUTO MASCHERATO ===
                        // Tutto ciò che è qui dentro viene tagliato se esce dai bordi
                        ZStack(alignment: .top) {
                            // 1. PASSENGER CONTENT
                            if !isAnimating {
                                let user = targets[currentIndex]
                                VStack(spacing: 15) {
                                    Spacer().frame(height: 60) // Spazio extra in alto per la curva
                                    
                                    // Foto con frame
                                    ZStack {
                                        Circle().fill(Color.white).frame(width: 130, height: 130)
                                        Image(systemName: "person.fill")
                                            .resizable().scaledToFit().frame(width: 80, height: 80)
                                            .foregroundColor(Color.blue.opacity(0.5))
                                    }
                                    .overlay(Circle().stroke(Color.white, lineWidth: 5))
                                    .shadow(radius: 8)
                                    
                                    Text(user.name)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                    
                                    Text(user.flightInfo)
                                        .font(.headline)
                                        .padding(.vertical, 8).padding(.horizontal, 15)
                                        .background(Color.black.opacity(0.4)).cornerRadius(20)
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        Text("✈️ Travel").font(.caption).padding(6).background(Color.white.opacity(0.3)).cornerRadius(5)
                                        Text("⚽️ Soccer").font(.caption).padding(6).background(Color.white.opacity(0.3)).cornerRadius(5)
                                    }.foregroundColor(.white)
                                    Spacer()
                                }
                                .frame(width: windowWidth, height: windowHeight + 50) // +50 per sbordare sotto e non lasciare buchi
                                .background(Color.blue.opacity(0.6))
                            }
                            
                            // 2. THE SHADE
                            Rectangle()
                                .fill(Color(red: 220/255, green: 220/255, blue: 230/255))
                                // La tendina deve essere più alta del finestrino per coprirlo tutto quando scende
                                .frame(width: windowWidth, height: windowHeight + 20)
                                .offset(y: shadeOffset)
                        }
                        // *** IL FIX E' QUI ***
                        // Applichiamo una maschera a tutto il contenuto interno
                        .mask(
                            RoundedRectangle(cornerRadius: 110)
                                .frame(width: windowWidth, height: windowHeight)
                        )
                        // ==================================
                        
                        // 3. THE OUTER FRAME (Cornice sopra a tutto)
                        RoundedRectangle(cornerRadius: 110)
                            .stroke(Color.white, lineWidth: 25)
                            .frame(width: windowWidth + 30, height: windowHeight + 30)
                            .shadow(radius: 10)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.height > 0 {
                                            self.shadeOffset = -400 + value.translation.height
                                        }
                                    }
                                    .onEnded { value in
                                        if value.translation.height > 150 {
                                            closeAndNextUser()
                                        } else {
                                            withAnimation(.spring()) { self.shadeOffset = -400 }
                                        }
                                    }
                            )
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Image(systemName: "hand.draw.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                        Text("Pull down the shade for the next passenger")
                            .font(.caption).fontWeight(.semibold).foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    func closeAndNextUser() {
        withAnimation(.easeIn(duration: 0.2)) { self.shadeOffset = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isAnimating = true
            if self.currentIndex < self.targets.count - 1 { currentIndex += 1 } else { currentIndex = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isAnimating = false
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { self.shadeOffset = -400 }
            }
        }
    }
}
