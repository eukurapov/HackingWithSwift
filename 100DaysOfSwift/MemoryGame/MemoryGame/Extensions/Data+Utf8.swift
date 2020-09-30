//
//  Data+Utf8.swift
//  Memorize
//
//  Created by Eugene Kurapov on 10.07.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import Foundation

extension Data {
    // just a simple converter from a Data to a String
    var utf8: String? { String(data: self, encoding: .utf8 ) }
}
