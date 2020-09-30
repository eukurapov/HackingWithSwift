//
//  Array+Only.swift
//  Memorize
//
//  Created by Evgeniy Kurapov on 31.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import Foundation

extension Array {

    var only: Element? {
        count == 1 ? first : nil
    }

}
