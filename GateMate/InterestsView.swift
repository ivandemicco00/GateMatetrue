import SwiftUI

struct InterestsView: View {
    @Binding var selectedInterests: Set<String>
    var onContinue: () -> Void
    var onBack: () -> Void
    
    let tags = [
        "Travel ✈️", "Business 💼", "Tech 💻", "Books 📚",
        "Soccer ⚽️", "Music 🎵", "Art 🎨", "Food 🍕",
        "Gaming 🎮", "Fashion 👗", "Fitness 🏋️", "Photo 📸"
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
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
            
            Text("Your Interests")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 10)
            
            Text("Select at least 1")
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 20)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(tags, id: \.self) { tag in
                        Button(action: {
                            if selectedInterests.contains(tag) {
                                selectedInterests.remove(tag)
                            } else {
                                selectedInterests.insert(tag)
                            }
                        }) {
                            Text(tag)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedInterests.contains(tag) ? Color.blue : Color.white.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: selectedInterests.contains(tag) ? 2 : 0)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: onContinue) {
                Text("Start Radar")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
            }
            .disabled(selectedInterests.isEmpty)
            .opacity(selectedInterests.isEmpty ? 0.6 : 1)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}
