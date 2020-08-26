//
//  Petition.swift
//  Project7
//
//  Created by Evgeniy Kurapov on 24.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
