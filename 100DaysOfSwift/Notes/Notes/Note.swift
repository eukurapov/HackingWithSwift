//
//  Note.swift
//  Notes
//
//  Created by Eugene Kurapov on 16.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import Foundation

class Note: Identifiable, Codable {
    
    var id: UUID = UUID()
    var title: String {
        return text.components(separatedBy: .newlines).filter { !$0.isEmpty }.first ?? "Empty"
    }
    var text: String {
        didSet {
            lastEdit = Date()
        }
    }
    private(set) var lastEdit: Date = Date()
    
    init(text: String, lastEdit: Date? = nil) {
        self.text = text
        if lastEdit != nil { self.lastEdit = lastEdit! }
    }
    
}
