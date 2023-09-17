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
    static let TIMESTAMPMAXERROR = 60 // In minutes
}

// MARK: Chat
extension Constant {
    static let NOTIFICATIONDESELECTRANGETEXTVIEW: String = "NOTIFICATION_DESELECT_RANGE_TEXTVIEW"
    static let MAXLENGTHCHATMESSAGE: Int = 3000
}
