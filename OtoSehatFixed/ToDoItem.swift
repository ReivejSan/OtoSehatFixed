//
//  ToDoItem.swift
//  OtoSehatFixed
//
//  Created by Jevier Izza Maulana on 11/04/22.
//

import UIKit
import Foundation

struct ToDoItem: Codable {
    var name: String
    var date: Date
    var notes: String
    var reminderSet: Bool
    var notificationID: String?
}
