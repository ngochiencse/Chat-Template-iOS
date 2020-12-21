//
//  MessageLogicCellViewModel.swift
//  ChatTemplate
//
//  Created by Hien Pham on 12/2/20.
//  Copyright © 2020 Hien Pham. All rights reserved.
//

import Foundation

protocol MessageCellAdvancedViewModel: ChatItemAdvancedViewModel {
    var messageId: MessageId? { get set }

    var senderId: ChatUserId? { get }

    // Only use for local message
    var localId: Int? { get }

    // Id of the remote message which lies before the local message. Use to identify position display in chat screen.
    var messageIdBefore: MessageId? { get }

    var createdAt: Date? { get }

    var cell: MessageCellViewModel { get }
}
