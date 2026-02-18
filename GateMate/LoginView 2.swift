import SwiftUI

struct LoginView: View {
    var onSuccess: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        VStack {
            // Back Button
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 50)
            
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            Text("Secure Login")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Sign in to connect with travelers")
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 40)
            
            Button(action: onSuccess) {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Sign in with Apple")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
