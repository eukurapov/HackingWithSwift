//
//  Country.swift
//  Countries
//
//  Created by Eugene Kurapov on 10.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import Foundation

struct Country: Codable {
    
    var name: String
    var capital: City
    var flag: String
    var population: Int
    var area: Int
    var currency: String
    var isoCode: String
    
    var flagUrl: URL? { URL(string: flag) }
    
    struct City: Codable {
        var name: String
        var population: Int
        var area: Int
    }
    
}
