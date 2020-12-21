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
    var item: ChatItemCellViewModel {
        return cell
    }

    init(messageId: MessageId?, senderId: ChatUserId?, localId: Int?,
         messageIdBefore: MessageId?, createdAt: Date?, cell: MessageCellViewModel) {
        self.messageId = messageId
        self.senderId = senderId
        self.localId = localId
        self.messageIdBefore = messageIdBefore
        self.createdAt = createdAt
        self.cell = cell
        super.init()
        cell.onToggleLike.subscribe(onNext: { (_) in
            self.onToggleLike()
        }).disposed(by: rx.disposeBag)
    }

    private func onToggleLike() {
        cell.isLike.accept(!cell.isLike.value)
        // TODO: Call api here
    }
}
