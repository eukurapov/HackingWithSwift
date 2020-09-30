//
//  Array+Identifiable.swift
//  Memorize
//
//  Created by Evgeniy Kurapov on 31.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
    
    func firstIndexOf(_ element: Element) -> Int? {
        for index in self.indices {
            if self[index].id == element.id {
                return index
            }
        }
        return nil
    }
    
}
