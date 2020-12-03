//
//  MessageCellDetailViewModelImpl.swift
//  ChatTemplate
//
//  Created by Hien Pham on 12/3/20.
//  Copyright © 2020 Hien Pham. All rights reserved.
//

import Foundation

class MessageCellAdvancedViewModelImpl: NSObject, MessageCellAdvancedViewModel {
    var messageId: MessageId?
    let senderId: ChatUserId?
    let localId: Int?
    let messageIdBefore: MessageId?
    let createdAt: Date?
    let cell: MessageCellViewModel
    
    init(messageId: MessageId?, senderId: ChatUserId?, localId: Int?,
         messageIdBefore: MessageId?, createdAt: Date?, uiViewModel: MessageCellViewModel) {
        self.messageId = messageId
        self.senderId = senderId
        self.localId = localId
        self.messageIdBefore = messageIdBefore
        self.createdAt = createdAt
        self.cell = uiViewModel
        super.init()
    }
}
