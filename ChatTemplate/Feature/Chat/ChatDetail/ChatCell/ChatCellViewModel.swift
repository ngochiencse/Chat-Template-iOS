//
//  ChatCellViewModel.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/30/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum ChatItemType: Int {
    case message
    case time
}

protocol ChatItemCellViewModel: class {
    var itemType: ChatItemType { get }
}

func isMessageAndSameSender(_ objA: ChatItemDetailViewModel?, _ objB: ChatItemDetailViewModel?) -> Bool {
    if let messageA = objA as? MessageCellDetailViewModel,
        let messageB = objB as? MessageCellDetailViewModel,
        messageA.senderId == messageB.senderId {
        return true
    }
    
    return false
}
