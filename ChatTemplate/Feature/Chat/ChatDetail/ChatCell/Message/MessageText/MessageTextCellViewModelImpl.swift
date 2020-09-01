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
    
    override var messageType: MessageTypeNew {
        return .text
    }
        
    init(text: String?, messageId: MessageId?, localId: Int?, messageIdBefore: MessageId?,
         sender: ChatUser, createdAt: Date?, myUserId: ChatUserId?) {
        self.text = text
        super.init(messageId: messageId, localId: localId, messageIdBefore: messageIdBefore,
                   sender: sender, createdAt: createdAt, myUserId: myUserId)
    }
}
