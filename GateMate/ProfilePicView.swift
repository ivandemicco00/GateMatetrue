import SwiftUI

struct ProfileImageView: View {
    @Binding var selectedImage: Image?
    var onContinue: () -> Void
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
            
            Text("Add a Photo")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("Make yourself recognizable")
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 30)
            
            // Photo Circle
            Button(action: {
                // Simulate selecting a photo
                selectedImage = Image(systemName: "person.crop.circle.fill")
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 200, height: 200)
                    
                    if let img = selectedImage {
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                }
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4)
                )
            }
            
            Spacer()
            
            Button(action: onContinue) {
                Text(selectedImage == nil ? "Skip for now" : "Continue")
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
