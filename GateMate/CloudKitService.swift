import Foundation
import CloudKit
import CoreLocation
import Combine

class CloudKitService: ObservableObject {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    @Published var currentLocation: CLLocation? = nil
    @Published var isSearching: Bool = false
    @Published var downloadedTargets: [Target] = []
    
    // --- 1. SALVATAGGIO PROFILO ---
    func saveMyProfile(appleUserID: String, name: String, age: String, gender: String, languages: String, imageData: Data?, airport: String, flight: String, destination: String, departureTime: Date, completion: @escaping (Bool, String?) -> Void) {
        
        let locationToSave = currentLocation ?? CLLocation(latitude: 0, longitude: 0)
        let recordID = CKRecord.ID(recordName: appleUserID)
        
        // ATTENZIONE: IL NOME DELLA TABELLA È "Target" (Singolare)
        let myRecord = CKRecord(recordType: "Target", recordID: recordID)
        
        myRecord["appleUserID"] = appleUserID
        myRecord["name"] = name
        myRecord["age"] = age
        myRecord["gender"] = gender
        myRecord["languages"] = languages
        myRecord["airport"] = airport
        myRecord["flightInfo"] = flight
        myRecord["destination"] = destination
        myRecord["departureTime"] = departureTime
        myRecord["location"] = locationToSave
        
        if let data = imageData {
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            do {
                try data.write(to: fileURL)
                let asset = CKAsset(fileURL: fileURL)
                myRecord["profileImage"] = asset
            } catch { print("⚠️ Impossibile preparare l'immagine: \(error)") }
        }
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [myRecord], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .allKeys
        modifyOperation.modifyRecordsResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success: completion(true, nil)
                case .failure(let error): completion(false, error.localizedDescription)
                }
            }
        }
        publicDB.add(modifyOperation)
    }
    
    // --- 2. RICERCA CON IL RADAR ---
    func startScanning(myAirport: String, myTime: Date, myUserID: String) {
        self.isSearching = true
        fetchNearbyTargets(myAirport: myAirport, myTime: myTime, myUserID: myUserID) { targets in
            DispatchQueue.main.async {
                self.downloadedTargets = targets
                self.isSearching = false
            }
        }
    }
    
    // --- 3. DOWNLOAD DA CLOUDKIT E FILTRAGGIO LOCALE ---
    private func fetchNearbyTargets(myAirport: String, myTime: Date, myUserID: String, completion: @escaping ([Target]) -> Void) {
        
        // Chiediamo a CloudKit SOLO chi è in questo aeroporto (meno possibilità di crash server)
        let predicate = NSPredicate(format: "airport == %@", myAirport)
        let query = CKQuery(recordType: "Target", predicate: predicate)
        
        publicDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 50) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let matchResults):
                    var targetsFound: [Target] = []
                    
                    for (_, recordResult) in matchResults.matchResults {
                        if case .success(let record) = recordResult {
                            let appleUserID = record["appleUserID"] as? String ?? ""
                            
                            // 1. Scarta te stesso
                            if appleUserID == myUserID { continue }
                            
                            let departureTime = record["departureTime"] as? Date
                            
                            // 2. Filtro Orario: Mostra solo chi ha un volo a +/- 4 ore di differenza dal tuo
                            if let depTime = departureTime {
                                let timeDifference = abs(depTime.timeIntervalSince(myTime))
                                if timeDifference > (4 * 3600) { continue } // 4 ore = 14400 secondi
                            }
                            
                            let name = record["name"] as? String ?? "Passeggero"
                            let age = record["age"] as? String ?? ""
                            let gender = record["gender"] as? String ?? ""
                            let languages = record["languages"] as? String ?? ""
                            let airport = record["airport"] as? String ?? ""
                            let flightInfo = record["flightInfo"] as? String ?? ""
                            let destination = record["destination"] as? String ?? ""
                            let location = record["location"] as? CLLocation
                            
                            var fetchedImageData: Data? = nil
                            if let asset = record["profileImage"] as? CKAsset, let fileURL = asset.fileURL {
                                fetchedImageData = try? Data(contentsOf: fileURL)
                            }
                            
                            let target = Target(appleUserID: appleUserID, name: name, age: age, gender: gender, languages: languages, profileImageData: fetchedImageData, airport: airport, flightInfo: flightInfo, destination: destination, departureTime: departureTime, location: location)
                            targetsFound.append(target)
                        }
                    }
                    
                    // 3. Ordina per vicinanza fisica (GPS)
                    if let myLoc = self.currentLocation {
                        targetsFound.sort { t1, t2 in
                            let distance1 = t1.location?.distance(from: myLoc) ?? Double.infinity
                            let distance2 = t2.location?.distance(from: myLoc) ?? Double.infinity
                            return distance1 < distance2
                        }
                    }
                    
                    completion(targetsFound)
                    
                case .failure(let error):
                    print("❌ ERRORE DOWNLOAD CLOUDKIT: \(error.localizedDescription)")
                    completion([])
                }
            }
        }
    }
}
