//
//  Capital.swift
//  Project16
//
//  Created by Eugene Kurapov on 10.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import Foundation
import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
