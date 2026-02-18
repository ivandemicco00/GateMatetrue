import Foundation
import CloudKit
import CoreLocation
import Combine


struct Target: Identifiable {
    let id: String
    let name: String
    let flightInfo: String
    let location: CLLocation
    var color: String = "red" // Colore di default
}

class CloudKitService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // --- CLOUDKIT SETUP ---
    // Puntiamo ESPLICITAMENTE al tuo container specifico
    private let container = CKContainer(identifier: "iCloud.Targets")
    private let publicDB = CKContainer(identifier: "iCloud.Targets").publicCloudDatabase
    // --- GPS SETUP ---
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    
    // --- OUTPUT DATI ---
    @Published var nearbyTargets: [Target] = []
    @Published var isSearching = false
    @Published var permissionError = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    // --- 1. AVVIO SCANSIONE ---
    func startScanning() {
        self.isSearching = true
        self.nearbyTargets = [] // Resetta la lista
        
        // Se abbiamo già il GPS, cerchiamo subito. Altrimenti lo chiediamo.
        if let loc = locationManager.location {
            fetchFromCloudKit(center: loc)
        } else {
            locationManager.requestLocation()
        }
    }
    
    // --- 2. GESTIONE GPS ---
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
        // Abbiamo la posizione -> Cerchiamo su CloudKit
        fetchFromCloudKit(center: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errore GPS: \(error.localizedDescription)")
        self.isSearching = false
        self.permissionError = true
    }
    
    // --- 3. INTERROGAZIONE CLOUDKIT ---
    // --- VERSIONE DI DEBUG ---
    private func fetchFromCloudKit(center: CLLocation) {
        
        print("--- INIZIO RICERCA CLOUDKIT ---")
        print("La mia posizione simulata è: \(center.coordinate.latitude), \(center.coordinate.longitude)")
        
        // 1. PREDICATO "PRENDI TUTTO": Ignoriamo la distanza per ora.
        // Se questo funziona, il problema era il GPS.
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Target", predicate: predicate)
        // Rimuoviamo il sort per location che potrebbe fallire se la location è nil
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        publicDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 10) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let successData):
                    let matches = successData.matchResults
                    print("CloudKit ha restituito \(matches.count) risultati grezzi.")
                    
                    self.nearbyTargets = matches.compactMap { (recordID, recordResult) -> Target? in
                        switch recordResult {
                        case .success(let record):
                            // DEBUG: Stampa cosa c'è davvero nel record
                            print("-------------------------------------------------")
                            print("RECORD TROVATO: \(record.recordID.recordName)")
                            print("Chiavi disponibili: \(record.allKeys())")
                            
                            // Tentativo di estrazione
                            let name = record["name"] as? String
                            let flight = record["flightInfo"] as? String
                            let loc = record["location"] as? CLLocation
                            
                            // Debug degli errori
                            if name == nil { print("ERRORE: Campo 'name' nullo o nome sbagliato.") }
                            if flight == nil { print("ERRORE: Campo 'flightInfo' nullo o nome sbagliato.") }
                            if loc == nil { print("ERRORE: Campo 'location' nullo o nome sbagliato.") }
                            
                            guard let n = name, let f = flight, let l = loc else {
                                print("SCARTATO: Mancano dati obbligatori.")
                                return nil
                            }
                            
                            return Target(id: record.recordID.recordName, name: n, flightInfo: f, location: l)
                            
                        case .failure(let error):
                            print("Errore nel record singolo: \(error)")
                            return nil
                        }
                    }
                    
                case .failure(let error):
                    print("ERRORE CRITICO CLOUDKIT: \(error.localizedDescription)")
                }
                
                // Fine ricerca
                self.isSearching = false
                print("--- FINE RICERCA (Target validi: \(self.nearbyTargets.count)) ---")
            }
        }
    }
}
