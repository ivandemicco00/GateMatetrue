import Foundation
import CoreLocation

struct Target: Identifiable {
    let id = UUID()
    
    var appleUserID: String
    var name: String
    var age: String
    var gender: String
    var languages: String
    var profileImageData: Data?
    var airport: String
    var flightInfo: String
    var destination: String
    var departureTime: Date?
    var location: CLLocation?
}
