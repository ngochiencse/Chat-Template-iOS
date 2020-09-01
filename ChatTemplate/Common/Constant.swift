//
//  Constant.swift
//  ios_template_project
//
//  Created by Hien Pham on 8/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import UIKit

class Constant {
}

// Notification
extension Notification.Name {
    static let AppWillBecomeActive: Notification.Name = Notification.Name(rawValue: "AppDidBecomeActive")
    static let LoginSuccess: Notification.Name = Notification.Name(rawValue: "LoginSuccess")
}

// API constant
extension Constant {
    static let TIMESTAMP_MAX_ERROR = 60 // In minutes
}

// MARK: Chat
extension Constant {
    static let NOTIFICATION_DESELECT_RANGE_TEXTVIEW : String = "NOTIFICATION_DESELECT_RANGE_TEXTVIEW"
    static let MAX_LENGTH_CHAT_MESSAGE : Int = 3000
}
