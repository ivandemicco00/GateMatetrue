import SwiftUI

struct ProfileInputView: View {
    var onConfirm: () -> Void
    
    // --- STATI DI NAVIGAZIONE ---
    @State private var currentStep = 0
    // 0: Name, 1: Age, 2: Languages, 3: Gender, 4: Interests
    
    // --- DATI UTENTE ---
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var selectedLanguages: Set<String> = [] // Set per selezione multipla
    @State private var selectedGender: String = ""
    @State private var selectedInterest: String = ""
    
    // --- DATI PER LE LISTE ---
    let genders = ["Male", "Female", "Non-binary", "Prefer not to say"]
    let interests = ["Travel", "Technology", "Music", "Sports", "Reading", "Photography", "Gaming", "Cooking"]
    
    // Lingue comuni
    let commonLanguages = [
        "English", "Italian", "Spanish", "French", "German",
        "Portuguese", "Chinese", "Japanese", "Russian", "Arabic"
    ]
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND (Azzurro cielo)
            Color(red: 176/255, green: 205/255, blue: 222/255)
                .edgesIgnoringSafeArea(.all)
            
            // 2. ELEMENTI DECORATIVI (Nuvole)
            // Posizionate fisse per dare continuità
            CloudDecorationView()
            
            // 3. CONTENUTO CHE CAMBIA (Wizard)
            VStack {
                Spacer()
                
                // Area del cerchio bianco (Contenitore domande)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .scaleEffect(1.5) // Cerchio enorme
                        .offset(y: 100) // Spostato in basso
                    
                    // IL CONTENUTO DELLE DOMANDE
                    VStack {
                        // Switch per mostrare la domanda giusta in base allo step
                        switch currentStep {
                        case 0:
                            StepView(title: "What should people call you?", placeholder: "Name", text: $name)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        case 1:
                            StepView(title: "How old are you?", placeholder: "Age", text: $age, isNumber: true)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        case 2:
                            LanguageStepView(selectedLanguages: $selectedLanguages, languages: commonLanguages)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        case 3:
                            SelectionStepView(title: "What is your gender?", options: genders, selected: $selectedGender)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        case 4:
                            SelectionStepView(title: "What are your interests?", options: interests, selected: $selectedInterest)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 100) // Spazio per non sovrapporsi al cerchio troppo in basso
                }
                .frame(height: 500) // Altezza dell'area bianca
            }
            .edgesIgnoringSafeArea(.bottom)
            
            // 4. BOTTONE "AVANTI" (Freccia)
            VStack {
                Spacer()
                Button(action: nextStep) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(canProceed() ? Color.black : Color.gray)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }
                .padding(.bottom, 50)
                .disabled(!canProceed()) // Disabilita se il campo è vuoto
                .opacity(canProceed() ? 1.0 : 0.6)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: currentStep) // Animazione fluida tra gli step
    }
    
    // --- LOGICA DI NAVIGAZIONE ---
    func nextStep() {
        if currentStep < 4 {
            currentStep += 1
        } else {
            // Se siamo all'ultimo step, completiamo
            onConfirm()
        }
    }
    
    // Controllo se l'utente ha compilato il campo per attivare la freccia
    func canProceed() -> Bool {
        switch currentStep {
        case 0: return !name.isEmpty
        case 1: return !age.isEmpty
        case 2: return !selectedLanguages.isEmpty
        case 3: return !selectedGender.isEmpty
        case 4: return !selectedInterest.isEmpty
        default: return false
        }
    }
}

// --- SOTTO-VISTE PER I DIVERSI TIPI DI DOMANDE ---

// 1. Input Testo Semplice (Nome, Età)
struct StepView: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var isNumber: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            TextField(placeholder, text: $text)
                .keyboardType(isNumber ? .numberPad : .default)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .frame(width: 280)
                .multilineTextAlignment(.center)
        }
    }
}

// 2. Selezione Multipla (Lingue) - MODIFICATO PER MULTI-SELECT
struct LanguageStepView: View {
    @Binding var selectedLanguages: Set<String>
    let languages: [String]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Which languages do you speak?")
                .font(.headline)
                .foregroundColor(.black)
            
            Text("(Select all that apply)")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Griglia o Lista scorrevole per le lingue
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(languages, id: \.self) { lang in
                        Button(action: {
                            if selectedLanguages.contains(lang) {
                                selectedLanguages.remove(lang)
                            } else {
                                selectedLanguages.insert(lang)
                            }
                        }) {
                            HStack {
                                Text(lang)
                                    .fontWeight(.medium)
                                Spacer()
                                if selectedLanguages.contains(lang) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 176/255, green: 205/255, blue: 222/255))
                                }
                            }
                            .padding()
                            .frame(width: 280)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedLanguages.contains(lang) ? Color(red: 176/255, green: 205/255, blue: 222/255) : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .foregroundColor(.black)
                        }
                    }
                }
                .padding(.vertical)
            }
            .frame(height: 250) // Limita l'altezza per non occupare tutto
        }
    }
}

// 3. Selezione Singola (Genere, Interessi) - stile "Dropdown" finto
struct SelectionStepView: View {
    var title: String
    var options: [String]
    @Binding var selected: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selected = option
                    }
                }
            } label: {
                HStack {
                    Text(selected.isEmpty ? "Choose" : selected)
                        .foregroundColor(selected.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(width: 280)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// --- COMPONENTE DECORATIVO NUVOLE ---
struct CloudDecorationView: View {
    var body: some View {
        ZStack {
            // Nuvola in alto a sinistra
            Image(systemName: "cloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .foregroundColor(.white.opacity(0.9))
                .shadow(radius: 5)
                .offset(x: -120, y: -250)
            
            // Nuvola in alto a destra
            Image(systemName: "cloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80)
                .foregroundColor(.white.opacity(0.8))
                .shadow(radius: 5)
                .offset(x: 120, y: -300)
            
            // Nuvola centrale piccola
            Image(systemName: "cloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60)
                .foregroundColor(.white.opacity(0.7))
                .offset(x: 40, y: -200)
            
            // Nuvola decorativa bassa
            Image(systemName: "cloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120)
                .foregroundColor(.white.opacity(0.9))
                .shadow(radius: 5)
                .offset(x: 100, y: 150) // Appare sopra il cerchio bianco
        }
    }
}

struct ProfileInputView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileInputView(onConfirm: {})
    }
}
