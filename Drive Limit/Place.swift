//
//  Place.swift
//  Drive Limit
//
//  Created by Alexander Torres on 6/3/23.
//

import Foundation
import MapKit

struct Location: Identifiable, Codable, Equatable {
    var id: UUID
    var title:String
    var latitude:Double
    var longitude:Double
    
    
}
