//
//  MessageTextCellViewModelImpl.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

class MessageTextCellViewModelImpl: MessageCellViewModelImpl, MessageTextCellViewModel {
    private(set) var text: String?
    override var messageType: MessageCellType {
        return .text
    }
    
    init(senderAvatar: AvatarImageViewModel?, createdAtStr: String?, text: String?) {
        self.text = text
        super.init(senderAvatar: senderAvatar, createdAtStr: createdAtStr)
    }
}
