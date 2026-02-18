import SwiftUI
import AuthenticationServices

struct LoginView: View {
    var onSuccess: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // White Card
            VStack(spacing: 30) {
                TextField("Email", text: .constant(""))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
                
                SecureField("Password", text: .constant(""))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
                
                Button(action: {
                    // Action for manual login
                }) {
                    Text("Sign In")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 160/255, green: 190/255, blue: 210/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("or").foregroundColor(.gray)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }
                
                // APPLE SIGN IN
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(_):
                            onSuccess()
                        case .failure(let error):
                            print("Login error: \(error)")
                        }
                    }
                )
                .frame(height: 50)
                .signInWithAppleButtonStyle(.black)
                
                // DEBUG BYPASS
                Button("🛠️ Skip for Testing") {
                    onSuccess()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(30)
            .padding()
            
            Spacer()
        }
    }
}
