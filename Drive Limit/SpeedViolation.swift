//
//  SpeedViolation.swift
//  Drive Limit
//
//  Created by Alexander Torres on 6/5/23.
//

import Foundation
import MapKit
import CoreLocation
class SpeedViolation : Identifiable {
    var date: String
    var address: String
    var longitude: Double
    var latitude: Double
    var byWhat: Int
    var coordinate: CLLocationCoordinate2D
    var region: MKCoordinateRegion
    
    init(date: String, address: String, longitude: Double, latitude: Double, byWhat: Int, region: MKCoordinateRegion) {
        self.date = date
        self.address = address
        self.longitude = longitude
        self.latitude = latitude
        self.byWhat = byWhat
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.region = region
    }
    
    public func convertDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return date
    }
}
