//import SwiftUI

// Schermata di caricamento geofencing
import SwiftUI

struct CheckingAirportView: View {
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack(spacing: 20) {
                ProgressView().scaleEffect(2)
                Text("Locating nearest terminal...")
                    .font(.headline).foregroundColor(.black)
            }
        }
    }
}

// Sei in Aeroporto!
struct WelcomeAirportView: View {
    let airportName: String
    var onContinue: () -> Void
    
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack {
                Spacer()
                Text("Welcome to")
                    .font(.title2).foregroundColor(.black)
                Text(airportName)
                    .font(.largeTitle).bold().foregroundColor(.black).multilineTextAlignment(.center).padding(.horizontal)
                
                Text("Enter the Gate to find your flight companion.")
                    .foregroundColor(.black.opacity(0.8)).multilineTextAlignment(.center).padding()
                
                Spacer()
                Button(action: onContinue) {
                    Text("Enter Gate")
                        .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(25)
                }.padding(.horizontal, 40).padding(.bottom, 50)
            }
        }
    }
}

// Non sei in Aeroporto
struct SorryAirportView: View {
    var body: some View {
        ZStack {
            BackgroundDesign()
            VStack {
                Spacer()
                Image(systemName: "location.slash.fill").font(.system(size: 80)).foregroundColor(.black)
                Text("Sorry!")
                    .font(.largeTitle).bold().foregroundColor(.black).padding(.top)
                Text("GateMate only works inside airports. Get closer to a terminal to unlock the radar.")
                    .foregroundColor(.black.opacity(0.8)).multilineTextAlignment(.center).padding()
                Spacer()
            }
        }
    }
}
//  AirportView.swift
//  GateMate
//
//  Created by Ivan De Micco on 19/02/26.
//

