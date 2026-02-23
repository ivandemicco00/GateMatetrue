import SwiftUI
import PhotosUI
import AuthenticationServices
import CoreLocation
import Combine

let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)

class LocationFetcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    override init() { super.init(); manager.delegate = self; manager.requestWhenInUseAuthorization(); manager.startUpdatingLocation() }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { userLocation = locations.first; manager.stopUpdatingLocation() }
}
struct AirportDef: Hashable { let name: String; let location: CLLocation }

struct LoginView: View {
    @Binding var appleUserID: String
    @Binding var userName: String
    var onLoginSuccess: () -> Void
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack {
                Spacer()
                Text("Welcome to the Radar").font(.largeTitle).fontWeight(.heavy).foregroundColor(.black).padding(.bottom, 20)
                if appleUserID.isEmpty {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in request.requestedScopes = [.fullName, .email] },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                    appleUserID = appleIDCredential.user
                                    if let fullName = appleIDCredential.fullName, let givenName = fullName.givenName { userName = givenName; onLoginSuccess() }
                                }
                            case .failure(let error): print("Errore: \(error.localizedDescription)")
                            }
                        }
                    ).signInWithAppleButtonStyle(.black).frame(height: 55).padding(.horizontal, 40)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What's your name?").font(.headline).foregroundColor(.black)
                        TextField("Name", text: $userName).padding().background(Color.white).cornerRadius(15).foregroundColor(.black).submitLabel(.done)
                        ContinueButton(action: onLoginSuccess).disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty).opacity(userName.isEmpty ? 0.5 : 1.0).padding(.top, 20)
                    }.padding(40)
                }
                Spacer()
            }
        }
    }
}

struct AgeInputView: View {
    @Binding var age: String; var onContinue: () -> Void; var onBack: () -> Void;
    var isAdult: Bool { if let ageInt = Int(age), ageInt >= 18 { return true }; return false }
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack(alignment: .leading) {
                BackButton(action: onBack).padding(.top, 60).padding(.leading, 30); Spacer()
                VStack(alignment: .leading, spacing: 15) {
                    Text("How old are you?").font(.headline).fontWeight(.bold).foregroundColor(.black)
                    TextField("Age", text: $age).padding().frame(height: 55).background(Color.white).cornerRadius(25).foregroundColor(.black).keyboardType(.numberPad)
                    if !age.isEmpty && !isAdult { Text("You must be at least 18 years old to use the Radar.").font(.caption).foregroundColor(.red).bold() }
                }.padding(.horizontal, 40).padding(.bottom, 50)
                HStack { Spacer(); ContinueButton(action: onContinue).disabled(!isAdult).opacity(isAdult ? 1.0 : 0.4); Spacer() }.padding(.bottom, 50)
            }
        }
        .onChange(of: age) { oldValue, newValue in let filtered = newValue.filter { $0.isWholeNumber }; if newValue != filtered { age = filtered } }
    }
}

struct AirportInputView: View {
    @ObservedObject var ckService: CloudKitService
    @Binding var airport: String; var onContinue: () -> Void; var onBack: () -> Void
    @StateObject private var locationFetcher = LocationFetcher()
    
    let allAirports = [
        AirportDef(name: "Rome Fiumicino (FCO)", location: CLLocation(latitude: 41.7999, longitude: 12.2462)),
        AirportDef(name: "Milan Malpensa (MXP)", location: CLLocation(latitude: 45.6301, longitude: 8.7255)),
        AirportDef(name: "Naples Capodichino (NAP)", location: CLLocation(latitude: 40.8860, longitude: 14.2905)),
        AirportDef(name: "London Heathrow (LHR)", location: CLLocation(latitude: 51.4700, longitude: -0.4543))
    ]
    let maxDistanceInMeters: CLLocationDistance = 30000
    
    var closestAirportInfo: (name: String, distance: CLLocationDistance)? {
        guard let userLoc = locationFetcher.userLocation else { return nil }
        return allAirports.map { ($0.name, $0.location.distance(from: userLoc)) }.min(by: { $0.1 < $1.1 })
    }
    
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack(alignment: .leading) {
                BackButton(action: onBack).padding(.top, 60).padding(.leading, 30); Spacer()
                VStack(alignment: .leading, spacing: 15) {
                    Text("Select your closest Airport").font(.headline).bold().foregroundColor(.black)
                    if locationFetcher.userLocation == nil {
                        Text("Locating...").foregroundColor(.gray); ProgressView()
                    } else if let info = closestAirportInfo {
                        if info.distance <= maxDistanceInMeters {
                            Button(action: { airport = info.name; ckService.currentLocation = locationFetcher.userLocation }) {
                                HStack { Text(info.name).foregroundColor(airport == info.name ? .white : .black).padding(); Spacer(); if airport == info.name { Image(systemName: "checkmark").foregroundColor(.white).padding(.trailing) } }.frame(maxWidth: .infinity).background(airport == info.name ? Color.blue : Color.white.opacity(0.6)).cornerRadius(15)
                            }
                        } else {
                            Text("No airports found within 30km of your location.").font(.subheadline).foregroundColor(.red).padding().background(Color.white).cornerRadius(10)
                        }
                    }
                }.padding(.horizontal, 40).padding(.bottom, 50)
                HStack { Spacer(); ContinueButton(action: {
                    if airport.isEmpty && closestAirportInfo != nil && closestAirportInfo!.distance <= maxDistanceInMeters { airport = closestAirportInfo!.name; ckService.currentLocation = locationFetcher.userLocation }
                    onContinue()
                }).disabled(airport.isEmpty).opacity(airport.isEmpty ? 0.5 : 1.0); Spacer() }.padding(.bottom, 50)
            }
        }
    }
}

struct LanguagesInputView: View {
    @Binding var languages: String; var onContinue: () -> Void; var onBack: () -> Void
    let availableLanguages = ["English", "Italian", "Spanish", "French", "German", "Chinese"]
    @State private var selectedLangs: Set<String> = []
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack(alignment: .leading) {
                BackButton(action: onBack).padding(.top, 60).padding(.leading, 30); Spacer()
                VStack(alignment: .leading, spacing: 15) {
                    Text("Select languages you speak").font(.headline).bold().foregroundColor(.black)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(availableLanguages, id: \.self) { lang in Button(action: { if selectedLangs.contains(lang) { selectedLangs.remove(lang) } else { selectedLangs.insert(lang) }; languages = selectedLangs.joined(separator: ", ") }) { Text(lang).foregroundColor(selectedLangs.contains(lang) ? .white : .black).padding(.vertical, 10).padding(.horizontal, 15).background(selectedLangs.contains(lang) ? Color.blue : Color.white.opacity(0.6)).cornerRadius(15) } }
                    }
                }.padding(.horizontal, 40).padding(.bottom, 50)
                HStack { Spacer(); ContinueButton(action: onContinue); Spacer() }.padding(.bottom, 50)
            }
        }
    }
}

struct ProfileImageInputView: View {
    @Binding var imageData: Data?; var onContinue: () -> Void; var onBack: () -> Void
    @State private var selectedItem: PhotosPickerItem? = nil
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack(alignment: .leading) {
                BackButton(action: onBack).padding(.top, 60).padding(.leading, 30); Spacer()
                VStack(alignment: .center, spacing: 25) {
                    Text("Add a profile picture").font(.headline).bold().foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading)
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) { if let imageData = imageData, let uiImage = UIImage(data: imageData) { Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 150, height: 150).clipShape(Circle()).overlay(Circle().stroke(Color.white, lineWidth: 4)).shadow(radius: 5) } else { ZStack { Circle().fill(Color.white.opacity(0.8)).frame(width: 150, height: 150).shadow(radius: 5); Image(systemName: "camera.fill").font(.system(size: 50)).foregroundColor(.gray) } } }.onChange(of: selectedItem) { _, newItem in Task { if let data = try? await newItem?.loadTransferable(type: Data.self) { imageData = data } } }
                }.padding(.horizontal, 40).padding(.bottom, 50)
                HStack { Spacer(); ContinueButton(action: onContinue); Spacer() }.padding(.bottom, 50)
            }
        }
    }
}

struct FlightInputView: View { @Binding var flight: String; var onContinue: () -> Void; var onBack: () -> Void; var body: some View { BaseInputScreen(question: "What is your flight number?", placeholder: "e.g., AZ203", inputText: $flight, onContinue: onContinue, onBack: onBack) } }
struct DestinationInputView: View { @Binding var destination: String; var onContinue: () -> Void; var onBack: () -> Void; var body: some View { BaseInputScreen(question: "What is your final destination?", placeholder: "e.g., New York", inputText: $destination, onContinue: onContinue, onBack: onBack) } }
struct GenderInputView: View {
    @Binding var gender: String; var onContinue: () -> Void; var onBack: () -> Void
    let options = ["Male", "Female", "Non-binary", "Prefer not to say"]
    var body: some View { ZStack { BackgroundDesign(); VStack(alignment: .leading) { BackButton(action: onBack).padding(.top, 60).padding(.leading, 30); Spacer(); VStack(alignment: .leading, spacing: 15) { Text("What is your gender?").font(.headline).bold().foregroundColor(.black); VStack(spacing: 10) { ForEach(options, id: \.self) { option in Button(action: { gender = option }) { HStack { Text(option).foregroundColor(gender == option ? .white : .black); Spacer() }.padding().frame(height: 55).background(gender == option ? Color.blue : Color.white.opacity(0.6)).cornerRadius(25) } } } }.padding(.horizontal, 40).padding(.bottom, 50); HStack { Spacer(); ContinueButton(action: onContinue); Spacer() }.padding(.bottom, 50) } } }
}

struct TimeInputView: View {
    @Binding var time: Date; var onContinue: () -> Void; var onBack: () -> Void
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack(alignment: .leading) {
                BackButton(action: onBack).padding(.top, 60).padding(.leading, 30); Spacer()
                VStack(alignment: .leading, spacing: 15) {
                    Text("Departure Time").font(.largeTitle).bold().foregroundColor(.black)
                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .colorScheme(.light)
                        .frame(height: 180).frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    Text("⚠️ You will be automatically removed from the radar when your flight departs.")
                        .font(.caption).foregroundColor(.red).padding().background(Color.white).cornerRadius(10)
                }.padding(.horizontal, 40).padding(.bottom, 20)
                HStack { Spacer(); ContinueButton(action: onContinue); Spacer() }.padding(.bottom, 50)
            }
        }
    }
}

struct BaseInputScreen: View {
    let question: String; let placeholder: String; @Binding var inputText: String; var keyboardType: UIKeyboardType = .default; var onContinue: () -> Void; var onBack: () -> Void
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack(alignment: .leading) {
                BackButton(action: onBack).padding(.top, 60).padding(.leading, 30); Spacer();
                VStack(alignment: .leading, spacing: 15) {
                    Text(question).font(.headline).bold().foregroundColor(.black);
                    TextField(placeholder, text: $inputText)
                        .padding().frame(height: 55).background(Color.white).cornerRadius(25).foregroundColor(.black).keyboardType(keyboardType)
                        .submitLabel(.done) // Per chiudere comodamente la tastiera
                }.padding(.horizontal, 40).padding(.bottom, 50);
                HStack { Spacer(); ContinueButton(action: onContinue); Spacer() }.padding(.bottom, 50)
            }
        }
    }
}

struct BackgroundDesign: View { var body: some View { GeometryReader { geometry in ZStack { bgColor.edgesIgnoringSafeArea(.all); Circle().fill(Color.white).frame(width: geometry.size.width * 1.5, height: geometry.size.width * 1.5).position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.95); RealisticCloud().scaleEffect(1.8).position(x: 60, y: 150).opacity(0.9); RealisticCloud().scaleEffect(1.2).position(x: geometry.size.width - 50, y: geometry.size.height * 0.45); RealisticCloud().scaleEffect(0.8).position(x: geometry.size.width * 0.6, y: 100).opacity(0.8); RealisticCloud().scaleEffect(0.7).position(x: 40, y: geometry.size.height * 0.65) } }.edgesIgnoringSafeArea(.all) } }
struct RealisticCloud: View { var body: some View { ZStack { Image(systemName: "cloud.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 100).foregroundColor(.white).shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 4); Image(systemName: "cloud.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 90).foregroundColor(Color(white: 0.95)).offset(x: -5, y: -2) } } }
struct BackButton: View { var action: () -> Void; var body: some View { Button(action: action) { Image(systemName: "arrow.left").font(.system(size: 20, weight: .bold)).foregroundColor(.black).padding(12).background(Color.white.opacity(0.5)).clipShape(Circle()) } } }
struct ContinueButton: View { var action: () -> Void; var body: some View { Button(action: action) { Image(systemName: "arrow.right").font(.system(size: 24, weight: .bold)).foregroundColor(.black).frame(width: 60, height: 60).background(Color.white).clipShape(Circle()).shadow(radius: 5) } } }
