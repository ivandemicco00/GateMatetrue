import SwiftUI

enum AppStep {
    case login, inputAirport, inputAge, inputGender, inputLanguages, inputImage, inputFlight, inputDestination, inputTime, mainApp
}

struct ContentView: View {
    @StateObject var ckService = CloudKitService()
    
    @AppStorage("appleUserID") private var draftAppleID = ""
    @AppStorage("appleUserName") private var draftName = ""
    @AppStorage("savedAge") private var draftAge = ""
    @AppStorage("savedGender") private var draftGender = ""
    @AppStorage("savedLanguages") private var draftLanguages = ""
    
    @State private var draftImageData: Data? = UserDefaults.standard.data(forKey: "savedImageData")
    
    @State private var draftAirport = ""
    @State private var draftFlight = ""
    @State private var draftDestination = ""
    @State private var draftDepartureTime = Date()
    
    @State private var currentStep: AppStep = .login
    @State private var isSaving: Bool = false

    var body: some View {
        ZStack {
            Group {
                switch currentStep {
                case .login:
                    LoginView(appleUserID: $draftAppleID, userName: $draftName) {
                        if draftAge.isEmpty { currentStep = .inputAge } else { currentStep = .inputAirport }
                    }
                case .inputAge:
                    AgeInputView(age: $draftAge, onContinue: { currentStep = .inputGender }, onBack: { currentStep = .login })
                case .inputGender:
                    GenderInputView(gender: $draftGender, onContinue: { currentStep = .inputLanguages }, onBack: { currentStep = .inputAge })
                case .inputLanguages:
                    LanguagesInputView(languages: $draftLanguages, onContinue: { currentStep = .inputImage }, onBack: { currentStep = .inputGender })
                case .inputImage:
                    ProfileImageInputView(imageData: $draftImageData, onContinue: {
                        if let data = draftImageData { UserDefaults.standard.set(data, forKey: "savedImageData") }
                        currentStep = .inputAirport
                    }, onBack: { currentStep = .inputLanguages })
                    
                case .inputAirport:
                    AirportInputView(ckService: ckService, airport: $draftAirport, onContinue: { currentStep = .inputFlight }, onBack: { currentStep = draftAge.isEmpty ? .inputImage : .login })
                case .inputFlight:
                    FlightInputView(flight: $draftFlight, onContinue: { currentStep = .inputDestination }, onBack: { currentStep = .inputAirport })
                case .inputDestination:
                    DestinationInputView(destination: $draftDestination, onContinue: { currentStep = .inputTime }, onBack: { currentStep = .inputFlight })
                    
                case .inputTime:
                    TimeInputView(time: $draftDepartureTime, onContinue: {
                        isSaving = true
                        
                        ckService.saveMyProfile(appleUserID: draftAppleID, name: draftName, age: draftAge, gender: draftGender, languages: draftLanguages, imageData: draftImageData, airport: draftAirport, flight: draftFlight, destination: draftDestination, departureTime: draftDepartureTime) { success, errorMsg in
                            
                            isSaving = false
                            if success { print("✅ PROFILO SALVATO SU CLOUDKIT!") } else { print("❌ ERRORE: \(errorMsg ?? "")") }
                            
                            // Apre sempre la MainApp, non rimani mai bloccato
                            currentStep = .mainApp
                        }
                    }, onBack: { currentStep = .inputDestination })
                    
                case .mainApp:
                    MainTabView(ckService: ckService, appleUserID: draftAppleID, userName: draftName, userAge: draftAge, userGender: draftGender, userLanguages: draftLanguages, userImage: draftImageData, userAirport: draftAirport, userDepartureTime: draftDepartureTime)
                }
            }
            .disabled(isSaving)
            
            // SCHERMATA DI CARICAMENTO
            if isSaving {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    ProgressView().scaleEffect(1.5).progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Saving Profile...").font(.headline).foregroundColor(.white)
                }
                .padding(40)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
        }
        // FORZATA MODALITÀ CHIARA PER TEXTFIELD VISIBILI
        .preferredColorScheme(.light)
    }
}
