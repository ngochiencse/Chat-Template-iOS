//
//  Message.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

enum MessageCellType: Int {
    case text = 0
    case image
}

typealias MessageId = String

enum MessageBlockPosition: Int {
    case top
    case middle
    case bottom
}
