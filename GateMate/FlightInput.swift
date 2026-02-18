import SwiftUI

struct FlightInputView: View {
    @Binding var date: Date
    var onConfirm: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Enter Your Flight Detail")
                .font(.headline)
                .padding(.bottom, 10)
            
            HStack {
                // Date Picker styled like your screenshot
                DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
                
                Text(date, style: .time)
                    .font(.system(size: 40, weight: .bold))
            }
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: onConfirm) {
                Text("Lets Start")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}
