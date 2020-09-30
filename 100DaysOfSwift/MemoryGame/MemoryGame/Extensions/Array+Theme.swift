//
//  Array+Theme.swift
//  Memorize
//
//  Created by Eugene Kurapov on 16.07.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import Foundation

extension Array where Element == Theme {
    
    var asDataArray: [Data] {
        var data = [Data]()
        for element in self {
            if let json = element.json {
                data.append(json)
            }
        }
        return data
    }
    
    init(fromDataArray data: [Data]) {
        self.init()
        for json in data {
            if let theme = Theme.init(from: json) {
                self.append(theme)
            }
        }
    }
    
}
