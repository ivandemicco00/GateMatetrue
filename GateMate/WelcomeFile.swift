import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "paperplane.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            Text("GateMate")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.white)
            
            Text("Find your Gate Mate")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 5)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}
