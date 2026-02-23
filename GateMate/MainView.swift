import SwiftUI

struct MainTabView: View {
    @ObservedObject var ckService: CloudKitService
    
    var appleUserID: String
    var userName: String
    var userAge: String
    var userGender: String
    var userLanguages: String
    var userImage: Data?
    var userAirport: String
    var userDepartureTime: Date
    
    @State private var selectedTab = 1
    @State private var isRadarMatched = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeProfileView(userName: userName, userAge: userAge, userGender: userGender, userLanguages: userLanguages, userImage: userImage, userAirport: userAirport)
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(0)
            
            Group {
                if isRadarMatched {
                    WindowMatchView(targets: ckService.downloadedTargets, onRestart: {
                        isRadarMatched = false
                        ckService.startScanning(myAirport: userAirport, myTime: userDepartureTime, myUserID: appleUserID)
                    }, onChatRequested: {
                        selectedTab = 2
                    })
                } else {
                    RadarView(ckService: ckService,
                              appleUserID: appleUserID,
                              userAirport: userAirport,
                              userDepartureTime: userDepartureTime,
                              onFound: { isRadarMatched = true })
                }
            }
            .tabItem { Label("Radar", systemImage: "dot.radiowaves.left.and.right") }
            .tag(1)
            
            ChatView()
                .tabItem { Label("Chat", systemImage: "message.fill") }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

struct HomeProfileView: View {
    var userName: String, userAge: String, userGender: String, userLanguages: String, userImage: Data?, userAirport: String
    let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)
    
    var body: some View {
        ZStack {
            bgColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Your Profile").font(.largeTitle).bold().padding(.top, 40)
                if let data = userImage, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 150, height: 150).clipShape(Circle()).overlay(Circle().stroke(Color.white, lineWidth: 4)).shadow(radius: 5)
                } else {
                    Circle().fill(Color.white.opacity(0.8)).frame(width: 150, height: 150).overlay(Image(systemName: "person.fill").font(.system(size: 60)).foregroundColor(.gray))
                }
                Text(userName).font(.title).bold()
                Text("\(userAge) years old • \(userGender)").font(.headline).foregroundColor(.black.opacity(0.7))
                VStack(alignment: .leading, spacing: 10) {
                    HStack { Image(systemName: "airplane.departure"); Text(userAirport) }
                    HStack { Image(systemName: "mouth"); Text(userLanguages.isEmpty ? "No languages selected" : userLanguages) }
                }.padding().background(Color.white.opacity(0.6)).cornerRadius(15).padding(.horizontal, 40)
                Spacer()
            }
        }
    }
}

struct ChatView: View {
    let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)
    var body: some View {
        ZStack {
            bgColor.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Chats").font(.largeTitle).bold().padding(.top, 40)
                Spacer()
                Image(systemName: "bubble.left.and.bubble.right.fill").font(.system(size: 60)).foregroundColor(.white.opacity(0.8))
                Text("Your conversations will appear here.").font(.headline).foregroundColor(.black.opacity(0.6)).padding()
                Spacer()
            }
        }
    }
}

struct RadarView: View {
    @ObservedObject var ckService: CloudKitService
    var appleUserID: String
    var userAirport: String
    var userDepartureTime: Date
    var onFound: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(red: 168/255, green: 200/255, blue: 220/255).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text(ckService.isSearching ? "Searching passengers..." : "Targets Acquired!").font(.title2).bold().foregroundColor(.black)
                Spacer()
                ZStack {
                    Circle().stroke(Color.white.opacity(0.8), lineWidth: 1).frame(width: 150)
                    Circle().stroke(Color.white.opacity(0.6), lineWidth: 1).frame(width: 250)
                    if ckService.isSearching {
                        ForEach(0..<3) { i in
                            Circle().fill(Color.blue.opacity(0.6)).frame(width: 20, height: 20).offset(x: 125)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false).delay(Double(i)*0.5), value: isAnimating)
                        }
                    } else {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 80)).foregroundColor(.blue)
                    }
                }
                .onAppear {
                    isAnimating = true
                    ckService.startScanning(myAirport: userAirport, myTime: userDepartureTime, myUserID: appleUserID)
                }
                .onChange(of: ckService.isSearching) { oldValue, isSearching in
                    if !isSearching { DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { onFound() } }
                }
                Spacer()
            }
        }
    }
}

struct WindowMatchView: View {
    var targets: [Target]
    var onRestart: () -> Void
    var onChatRequested: () -> Void
    
    @State private var currentIndex = 0
    @State private var shadeOffset: CGFloat = -400
    @State private var isAnimating = false
    let windowWidth: CGFloat = 280
    let windowHeight: CGFloat = 480
    
    var body: some View {
        ZStack {
            Color(red: 176/255, green: 205/255, blue: 222/255).edgesIgnoringSafeArea(.all)
            
            if targets.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.slash.fill").font(.system(size: 60)).foregroundColor(.white.opacity(0.6))
                    Text("No passengers found nearby.").font(.headline).foregroundColor(.white)
                    Button("Try Again", action: onRestart).padding().background(Color.white).foregroundColor(.blue).cornerRadius(10)
                }
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Text("◀ Prev").font(.headline).foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("Next ▶").font(.headline).foregroundColor(.white.opacity(0.7))
                    }.frame(width: windowWidth).padding(.bottom, 10)
                    
                    ZStack(alignment: .top) {
                        ZStack(alignment: .top) {
                            if !isAnimating {
                                let user = targets[currentIndex]
                                VStack(spacing: 8) {
                                    HStack {
                                        Button(action: onChatRequested) { Image(systemName: "message.circle.fill").font(.system(size: 30)).foregroundColor(.white).padding() }
                                        Spacer()
                                        Menu { Button("Report User", role: .destructive) { }; Button("Block User", role: .destructive) { } } label: { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red.opacity(0.8)).padding() }
                                    }
                                    ZStack {
                                        Circle().fill(Color.white).frame(width: 120, height: 120)
                                        if let imageData = user.profileImageData, let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 110, height: 110).clipShape(Circle())
                                        } else {
                                            Image(systemName: "person.fill").resizable().scaledToFit().frame(width: 70, height: 70).foregroundColor(Color.blue.opacity(0.5))
                                        }
                                    }.overlay(Circle().stroke(Color.white, lineWidth: 5)).shadow(radius: 8)
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(user.name).font(.system(size: 26, weight: .bold)).foregroundColor(.white)
                                        Text(user.age).font(.title3).foregroundColor(.white.opacity(0.8))
                                    }
                                    if !user.airport.isEmpty { Text("📍 \(user.airport)").font(.subheadline).foregroundColor(.white.opacity(0.9)) }
                                    if !user.languages.isEmpty { Text("🗣️ \(user.languages)").font(.caption).foregroundColor(.white.opacity(0.8)).padding(.horizontal) }
                                    VStack(spacing: 5) {
                                        Text("✈️ \(user.flightInfo)").font(.headline).padding(.vertical, 6).padding(.horizontal, 15).background(Color.black.opacity(0.4)).cornerRadius(15).foregroundColor(.white)
                                        if !user.destination.isEmpty { Text("To: \(user.destination)").font(.subheadline).foregroundColor(.white.opacity(0.8)) }
                                    }.padding(.top, 5)
                                    Spacer()
                                }.frame(width: windowWidth, height: windowHeight + 50).background(Color.blue.opacity(0.6))
                            }
                            Rectangle().fill(Color(red: 220/255, green: 220/255, blue: 230/255)).frame(width: windowWidth, height: windowHeight + 20).offset(y: shadeOffset)
                        }.mask(RoundedRectangle(cornerRadius: 110).frame(width: windowWidth, height: windowHeight))
                        
                        RoundedRectangle(cornerRadius: 110).stroke(Color.white, lineWidth: 25).frame(width: windowWidth + 30, height: windowHeight + 30).shadow(radius: 10).contentShape(Rectangle())
                            .gesture(DragGesture().onEnded { v in
                                if v.translation.width < -40 { closeAndNextUser(forward: true) }
                                else if v.translation.width > 40 { closeAndNextUser(forward: false) }
                            })
                    }
                    Spacer()
                    Text("Swipe left or right to change passenger").font(.caption).fontWeight(.semibold).foregroundColor(.white.opacity(0.8)).padding(.bottom, 20)
                }
            }
        }
    }
    
    func closeAndNextUser(forward: Bool) {
        withAnimation(.easeIn(duration: 0.2)) { shadeOffset = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = true
            if forward { currentIndex = (currentIndex + 1) % targets.count } else { currentIndex = currentIndex == 0 ? targets.count - 1 : currentIndex - 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = false; withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { shadeOffset = -400 }
            }
        }
    }
}
