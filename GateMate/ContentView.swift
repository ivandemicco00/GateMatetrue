import SwiftUI

struct ContentView: View {
    @State private var currentStep: AppStep = .welcome
    
    // CAMBIATO: Da foundTravelers a foundTargets
    @State private var foundTargets: [Target] = []
    
    var body: some View {
        ZStack {
            Color(red: 176/255, green: 205/255, blue: 222/255)
                .edgesIgnoringSafeArea(.all)
            
            switch currentStep {
            case .welcome:
                WelcomeView(onContinue: { currentStep = .login })
            case .login:
                LoginView(onSuccess: { currentStep = .profile })
            case .profile:
                ProfileInputView(onConfirm: { currentStep = .searching })
            case .flightDetails:
                 EmptyView()
            case .searching:
                // CAMBIATO: Passiamo $foundTargets
                RadarView(foundTargets: $foundTargets, onFound: {
                    currentStep = .matching
                })
            case .matching:
                // CAMBIATO: Passiamo foundTargets alla vista successiva
                WindowMatchView(targets: foundTargets, onRestart: {
                    currentStep = .welcome
                })
            }
        }
        .animation(.easeInOut, value: currentStep)
    }
}
