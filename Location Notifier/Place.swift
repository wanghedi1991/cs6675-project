//
//  LocationEntity.swift
//  Location Notifier
//
//  Created by Hedi Wang on 3/25/18.
//  Copyright © 2018 Hedi Wang. All rights reserved.
//

import UIKit
class Place: Equatable{
    static func ==(lhs: Place, rhs: Place) -> Bool {
        if lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude && lhs.name == rhs.name{
            return true
        }
        return false
    }
    
    var name:String = ""
    var longitude:Double = 0.0
    var latitude:Double = 0.0
    var description = ""
    var category:String = ""
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.longitude  = longitude
        self.latitude = latitude
    }
    
    init(name: String, latitude: Double, longitude: Double, description: String, category: String) {
        self.name = name
        self.longitude  = longitude
        self.latitude = latitude
        self.category = category
        self.description = description
    }
    
}
