//
//  MapDriveViewModel.swift
//  Drive Limit
//
//  Created by Alexander Torres on 6/3/23.
//

import Foundation
import CoreLocation
import MapKit

class MapDriveViewModel: NSObject, ObservableObject {
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    private var timer: Timer?
    private var currentSpeedLimit:Int = -1
    private var currentSpeed:Int = -1
    private var warnings: Int = 0
    private var nextUpdate: Int = 6
    private var currentLong: Double = 0.0
    private var currentLat: Double = 0.0
    private var byWhat: Int = 0
    @Published var currentAddress:String?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    @Published var currentSpeedText: String?
    @Published var currentSpeedLimitText:String?
    
    public override init() {
        super.init()
        self.setupLocationManager()
        updateData()
    }
    
    deinit {
        //saveExceededSpeedInstance()
        stopTimer()
    }
    
    func startTimer() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [self] _ in
            
            let isSpeeding = checkSpeedLimit()
            
              if(isSpeeding) {
                  warnings = warnings + 1
                  if(warnings == 1) {
                      saveExceededSpeedInstance(latitude: currentLong, longitude: currentLat)
                  }
              } else {
                  warnings = 0
              }
            // should we warn the driver that they are speeding
            // driver should be warn every 4 to seconds
            if(warnings == 1 || warnings == nextUpdate) {
                // warn driver logic
                speakSpeedLimitExceeded()
            }
            if(warnings == nextUpdate) {
                nextUpdate = nextUpdate + 6
            }
          }
          timer?.tolerance = 10
          timer?.fire()
      }
    
    func stopTimer() {
         timer?.invalidate()
         timer = nil
     }
    
    func setupLocationManager() {
        let status = locationManager.authorizationStatus
        if status == .denied || status == .restricted {
            //error work on pop up
            
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 0.45 // meter
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension MapDriveViewModel: CLLocationManagerDelegate {
    
    
    func checkSpeedLimit()-> Bool {
        if (currentSpeed > -1 && currentSpeedLimit > -1) {
            if(currentSpeed > currentSpeedLimit) {
                return true
            }
        }
        return false
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            debugPrint("Error")
        }
    }
    
    fileprivate func getCurrendSpeed(_ location: CLLocation) {
        // get the current speed of the car
        let speed = Int(location.speed * 2.23694)
        currentSpeed = speed
        // now we must convert the speed into MPH
        self.currentSpeedText = speed >= 0 ? String("\(speed) MPH") : String("0 MPH")
    }
    
    fileprivate func getCurrentRegion(_ location: CLLocation) {
        self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    }
    
    fileprivate func updateGeoData(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            self?.currentAddress = "Road: \(placemark.thoroughfare ?? "Cannot get the address")"
            let latitude = placemark.location?.coordinate.latitude ?? 0.0
            let longitude = placemark.location?.coordinate.longitude ?? 0.0
            
            self?.retrieveSpeedLimitFromAPI(latitude: latitude, longitude: longitude)
        }
    }
    
    func retrieveSpeedLimitFromAPI(latitude: Double, longitude: Double) {
        let urlString = "https://www.overpass-api.de/api/interpreter?data=[out:json];way[maxspeed](around:10,\(latitude),\(longitude));out;"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error retrieving speed limit: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let elements = json?["elements"] as? [[String: Any]], let element = elements.first, let tags = element["tags"] as? [String: Any], let maxspeed = tags["maxspeed"] as? String {
                    DispatchQueue.main.async { [self] in
                        self?.currentSpeedLimitText = "Limit: \(maxspeed)"
                        self?.currentSpeedLimit = Int(maxspeed.filter { $0.isNumber }) ?? -1
                        print(self?.currentSpeedLimit ?? "-1")
                    }
                } else {
                    DispatchQueue.main.async {
                        if((self?.currentAddress?.contains("St")) != nil) {
                            self?.currentSpeedLimitText = "Limit: 30 MPH"
                        } else if((self?.currentAddress?.contains("S")) != nil) {
                            self?.currentSpeedLimitText = "Limit: 20 MPH"
                        } else if((self?.currentAddress?.contains("W")) != nil) {
                            self?.currentSpeedLimitText = "Limit: 20 MPH"
                        }else if((self?.currentAddress?.contains("N")) != nil) {
                            self?.currentSpeedLimitText = "Limit: 20 MPH"
                        } else if((self?.currentAddress?.contains("E")) != nil) {
                            self?.currentSpeedLimitText = "Limit: 20 MPH"
                        } else {
                            self?.currentSpeedLimitText = "Limit: 0 MPH"
                        }
                    }
                }
            } catch {
                print("Error parsing speed limit response: \(error.localizedDescription)")
            }
        }
        task.resume()

    }
    
    func saveExceededSpeedInstance(latitude: Double, longitude: Double) {
        
        let currentDate = getCurrentDateAsString()
        let address = currentAddress ?? ""
        byWhat = currentSpeed - currentSpeedLimit
        let exceededSpeedInstance = ["latitude": latitude, "longitude": longitude, "date": currentDate, "address": address,"byWhat": byWhat] as [String : Any]
        
        if var exceededSpeedInstances = UserDefaults.standard.array(forKey: "ExceededSpeedInstances") as? [[String: Any]] {
            exceededSpeedInstances.append(exceededSpeedInstance)
            UserDefaults.standard.set(exceededSpeedInstances, forKey: "ExceededSpeedInstances")
            print("save is sucessful")
        } else {
            UserDefaults.standard.set([exceededSpeedInstance], forKey: "ExceededSpeedInstances")
        }
    }

    
    func fetchExceededSpeedInstances() -> [[String: Any]] {
        if let exceededSpeedInstances = UserDefaults.standard.array(forKey: "ExceededSpeedInstances") as? [[String: Any]] {
            return exceededSpeedInstances
        }
        return []
    }
    
    func updateData() {
        
        allSpeedViolations = []
        
        let instances = fetchExceededSpeedInstances()
        
        print("count: \(instances.count)")
        for instance in instances {
            if let latitude = instance["latitude"] as? Double,
               let longitude = instance["longitude"] as? Double,
               let date = instance["date"] as? String,
               let address = instance["address"] as? String,
                let speed = instance["byWhat"] as? Int{
                allSpeedViolations.append(SpeedViolation(date: date, address: address, longitude: longitude, latitude: latitude,byWhat: speed,region: region))
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // stores our location data
        let location = locations[locations.count - 1]
        
        getCurrentRegion(location)
        getCurrendSpeed(location)
        updateGeoData(location)
        currentLat = location.coordinate.latitude
        currentLong = location.coordinate.longitude

    }
}
