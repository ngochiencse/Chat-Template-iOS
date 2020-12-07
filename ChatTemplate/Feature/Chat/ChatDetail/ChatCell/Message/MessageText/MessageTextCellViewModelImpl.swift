//
//  MessageTextCellViewModelImpl.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

class MessageTextCellViewModelImpl: MessageCellViewModelImpl, MessageTextCellViewModel {
    let attributedText: NSAttributedString?
    override var messageType: MessageCellType {
        return .text
    }
    
    init(senderAvatar: AvatarImageViewModel?, createdAtStr: String?, attributedText: NSAttributedString?) {
        self.attributedText = attributedText
        super.init(senderAvatar: senderAvatar, createdAtStr: createdAtStr)
    }
}
