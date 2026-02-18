import SwiftUI

// --- COLORI E CONFIGURAZIONE ---
let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255) // Azzurro cielo esatto

// --- 1. SCHERMATA NOME ---
struct NameInputView: View {
    @Binding var name: String
    var onContinue: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        BaseInputScreen(
            question: "What should people call you?",
            placeholder: "Name",
            inputText: $name,
            onContinue: onContinue,
            onBack: onBack
        )
    }
}

// --- 2. SCHERMATA ETÀ ---
struct AgeInputView: View {
    @Binding var age: String
    var onContinue: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        BaseInputScreen(
            question: "How old are you?",
            placeholder: "Age",
            inputText: $age,
            keyboardType: .numberPad,
            onContinue: onContinue,
            onBack: onBack
        )
    }
}

// --- 3. SCHERMATA GENERE ---
struct GenderInputView: View {
    @Binding var gender: String
    var onContinue: () -> Void
    var onBack: () -> Void
    
    let options = ["Male", "Female", "Non-binary", "Prefer not to say"]
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            // 1. Sfondo e Decorazioni (Uguale per tutti)
            BackgroundDesign()
            
            // 2. Contenuto Specifico
            VStack(alignment: .leading) {
                // Tasto Indietro (In alto)
                BackButton(action: onBack)
                    .padding(.top, 60)
                    .padding(.leading, 30)
                
                Spacer()
                
                // Area Input (Spostata verso il centro-basso per allinearsi al cerchio bianco)
                VStack(alignment: .leading, spacing: 15) {
                    Text("What is your gender?")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    // Menu a tendina
                    Button(action: { showMenu.toggle() }) {
                        HStack {
                            Text(gender.isEmpty ? "Choose" : gender)
                                .foregroundColor(gender.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(height: 55)
                        .background(Color.white)
                        .cornerRadius(25) // Bordo molto arrotondato come il design
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50) // Spinge su il contenuto
                
                // Tasto Continua (In basso centrato nel cerchio bianco)
                HStack {
                    Spacer()
                    ContinueButton(action: onContinue, isDisabled: gender.isEmpty)
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .confirmationDialog("Select Gender", isPresented: $showMenu, titleVisibility: .visible) {
            ForEach(options, id: \.self) { option in
                Button(option) { gender = option }
            }
        }
    }
}

// --- 4. SCHERMATA VOLO ---
struct FlightInputView: View {
    @Binding var flight: String
    var onContinue: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        BaseInputScreen(
            question: "What is your flight number?",
            placeholder: "e.g., AZ203",
            inputText: $flight,
            onContinue: onContinue,
            onBack: onBack
        )
    }
}

// --- 5. SCHERMATA DESTINAZIONE ---
struct DestinationInputView: View {
    @Binding var destination: String
    var onContinue: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        BaseInputScreen(
            question: "What is your final destination?",
            placeholder: "e.g., New York",
            inputText: $destination,
            onContinue: onContinue,
            onBack: onBack
        )
    }
}

// ==========================================
// IL CUORE DEL DESIGN (Nuvole + Cerchio)
// ==========================================

struct BaseInputScreen: View {
    let question: String
    let placeholder: String
    @Binding var inputText: String
    var keyboardType: UIKeyboardType = .default
    var onContinue: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            // 1. Sfondo Comune
            BackgroundDesign()
            
            // 2. Contenuto
            VStack(alignment: .leading) {
                // Back Button
                BackButton(action: onBack)
                    .padding(.top, 60)
                    .padding(.leading, 30)
                
                Spacer()
                
                // Domanda e Input
                VStack(alignment: .leading, spacing: 15) {
                    Text(question)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    TextField(placeholder, text: $inputText)
                        .padding()
                        .frame(height: 55)
                        .background(Color.white)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundColor(.black)
                        .keyboardType(keyboardType)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                
                // Tasto Continua (Centrato in basso)
                HStack {
                    Spacer()
                    ContinueButton(action: onContinue, isDisabled: inputText.isEmpty)
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// --- COMPONENTE GRAFICO DI SFONDO ---
struct BackgroundDesign: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Colore Blu Cielo
                bgColor.edgesIgnoringSafeArea(.all)
                
                // 2. Cerchio Bianco Gigante (In basso)
                Circle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * 1.5, height: geometry.size.width * 1.5)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.95)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                
                // 3. NUVOLE (Posizionate come negli screenshot)
                
                // Nuvola Grande (Alto Sinistra)
                RealisticCloud()
                    .scaleEffect(1.8)
                    .position(x: 60, y: 150)
                    .opacity(0.9)
                
                // Nuvola Media (Destra, sopra il cerchio)
                RealisticCloud()
                    .scaleEffect(1.2)
                    .position(x: geometry.size.width - 50, y: geometry.size.height * 0.45)
                
                // Nuvolina Piccola (Centro-Alto)
                RealisticCloud()
                    .scaleEffect(0.8)
                    .position(x: geometry.size.width * 0.6, y: 100)
                    .opacity(0.8)
                
                // Nuvolina Bassa (Sinistra, vicino input)
                RealisticCloud()
                    .scaleEffect(0.7)
                    .position(x: 40, y: geometry.size.height * 0.65)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// --- NUVOLA REALISTICA (Simulata con SF Symbols) ---
struct RealisticCloud: View {
    var body: some View {
        ZStack {
            // Usiamo più icone "cloud.fill" sovrapposte per dare volume 3D
            Image(systemName: "cloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 4) // Ombra per effetto 3D
            
            Image(systemName: "cloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90)
                .foregroundColor(Color(white: 0.95)) // Leggermente più scura per profondità
                .offset(x: -5, y: -2)
        }
    }
}

// --- PULSANTI ---

struct BackButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left") // Freccia semplice
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black) // Nera
                .padding(12)
                // Niente cerchio, solo freccia come nei design moderni,
                // oppure aggiungi sfondo se preferisci. Nel tuo screen sembra non averlo o averlo bianco.
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
        }
    }
}

struct ContinueButton: View {
    var action: () -> Void
    var isDisabled: Bool
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black) // Freccia nera
                .frame(width: 60, height: 60)
                .background(Color.white) // Sfondo bianco
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

// Questa serve solo per evitare errori se hai cancellato il file ProfileInfoView
// ma ContentView cerca ancora CloudLabel. (Anche se in questo design non si usa)
struct CloudLabel: View {
    let text: String
    var body: some View { EmptyView() }
}
