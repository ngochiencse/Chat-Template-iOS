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

enum MessageDisplaySide {
    case left
    case right
}

protocol MessageCellViewModel: ChatItemCellViewModel {
//    var messageId: MessageId? { get }
//
//    // Only use for local message
//    var localId: Int? { get }
//
//    // Id of the remote message which lies before the local message. Use to identify position display in chat screen.
//    var messageIdBefore: MessageId? { get }
    
    var messageType: MessageCellType { get }
//    var senderId: ChatUserId { get }
    
    var createdAtStr: String? { get }
    var senderAvatar: AvatarImageViewModel? { get }
    var displaySide: BehaviorRelay<MessageDisplaySide> { get }
    var isSenderAvatarImageHidden: BehaviorRelay<Bool> { get }
    var isSenderAvatarSpaceHidden: BehaviorRelay<Bool> { get }
    var roundCorners: BehaviorRelay<UIRectCorner> { get }

//    func didSendMessageSuccess(messageId: MessageId)
    
//    // Like
//    var isLike: Bool { get }
//    var isLikeObs: Observable<Bool> { get }
//    func toggleLike()
    
    var data: Any? { get set }
}
