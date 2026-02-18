import SwiftUI
import CoreLocation

// 1. Definiamo i NUOVI passaggi sequenziali
enum AppStep {
    case welcome
    case login
    
    // --- NUOVI PASSI SINGOLI ---
    case inputName
    case inputAge
    case inputGender
    case inputFlight
    case inputDestination // "Arrivo"
    // ---------------------------
    
    case profileImage
    case interests
    case searching
    case matching
}

struct ContentView: View {
    @State private var currentStep: AppStep = .welcome
    @State private var foundTargets: [Target] = []
    
    // --- DATI UTENTE ---
    @State private var draftName: String = ""
    @State private var draftAge: String = ""
    @State private var draftGender: String = "" // Stringa vuota all'inizio
    @State private var draftFlight: String = ""
    @State private var draftDestination: String = "" // NUOVO
    
    @State private var selectedInterests: Set<String> = []
    @State private var profileImage: Image? = nil
    
    var body: some View {
        ZStack {
            // Sfondo Comune
            Color(red: 176/255, green: 205/255, blue: 222/255)
                .edgesIgnoringSafeArea(.all)
            
            switch currentStep {
            case .welcome:
                WelcomeView(onContinue: { currentStep = .login })
                
            case .login:
                LoginView(onSuccess: { currentStep = .inputName },
                          onBack: { currentStep = .welcome })
            
            // --- SEQUENZA INPUT ---
            case .inputName:
                NameInputView(name: $draftName,
                              onContinue: { currentStep = .inputAge },
                              onBack: { currentStep = .login })
                
            case .inputAge:
                AgeInputView(age: $draftAge,
                             onContinue: { currentStep = .inputGender },
                             onBack: { currentStep = .inputName })
                
            case .inputGender:
                GenderInputView(gender: $draftGender,
                                onContinue: { currentStep = .inputFlight },
                                onBack: { currentStep = .inputAge })
                
            case .inputFlight:
                FlightInputView(flight: $draftFlight,
                                onContinue: { currentStep = .inputDestination },
                                onBack: { currentStep = .inputGender })
                
            case .inputDestination:
                DestinationInputView(destination: $draftDestination,
                                     onContinue: { currentStep = .profileImage },
                                     onBack: { currentStep = .inputFlight })
            // ---------------------
                
            case .profileImage:
                ProfileImageView(selectedImage: $profileImage,
                                 onContinue: { currentStep = .interests },
                                 onBack: { currentStep = .inputDestination })
                
            case .interests:
                InterestsView(selectedInterests: $selectedInterests,
                              onContinue: { currentStep = .searching },
                              onBack: { currentStep = .profileImage })
                
            case .searching:
                RadarView(foundTargets: $foundTargets,
                          onFound: { currentStep = .matching },
                          onBack: { currentStep = .interests })
                
            case .matching:
                WindowMatchView(targets: foundTargets,
                                onRestart: { currentStep = .welcome })
            }
        }
        .animation(.easeInOut, value: currentStep)
    }
}
