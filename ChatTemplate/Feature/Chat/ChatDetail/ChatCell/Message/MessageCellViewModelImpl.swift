//
//  MessageCellViewModelImpl.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CocoaLumberjack

class MessageCellViewModelImpl: NSObject, MessageCellViewModel {    
//    private(set) var messageId: MessageId?
//    private(set) var localId: Int?
//    private(set) var messageIdBefore: MessageId?
    var messageType: MessageCellType {
        fatalError("Not implemented")
    }
//    let senderId: ChatUserId
//    let myUserId: ChatUserId?
    var itemType: ChatItemType {
        return .message
    }
    
    let createdAtStr: String?
    
    let isSenderAvatarImageHidden: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isSenderAvatarSpaceHidden: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let roundCorners: BehaviorRelay<UIRectCorner> = BehaviorRelay(value: [.topLeft, .topRight, .bottomRight])
    let displaySide: BehaviorRelay<MessageDisplaySide> = BehaviorRelay(value: .left)
    let senderAvatar: AvatarImageViewModel?
        
    var data: Any?
    
    init(senderAvatar: AvatarImageViewModel?, createdAtStr: String?) {
        self.senderAvatar = senderAvatar
        self.createdAtStr = createdAtStr
        super.init()
    }
}
