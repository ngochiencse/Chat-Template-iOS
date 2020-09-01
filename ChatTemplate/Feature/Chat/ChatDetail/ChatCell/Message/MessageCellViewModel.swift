//
//  MessageCellViewModel.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MessageCellViewModel: ChatItemCellViewModel {
    var messageId: MessageId? { get }
    
    // Only use for local message
    var localId: Int? { get }
    
    // Id of the remote message which lies before the local message. Use to identify position display in chat screen.
    var messageIdBefore: MessageId? { get }
    
    var messageType: MessageTypeNew { get }
    var sender: ChatUser { get }
    
    var isMyMessage: Bool { get }
    var createdAt: Date? { get }
    var blockPosition: BehaviorRelay<MessageBlockPosition?> { get }
    func didSendMessageSuccess(messageId: MessageId)
}

extension MessageCellViewModel {
    func isTheSameSender(with other: MessageCellViewModel) -> Bool {
        return sender.id == other.sender.id
    }
}
