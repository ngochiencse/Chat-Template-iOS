//
//  MessageCellViewModel.swift
//  ChatTemplate
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
    var messageType: MessageCellType { get }

    var createdAtStr: String? { get }
    var senderAvatar: AvatarImageViewModel? { get }
    var displaySide: BehaviorRelay<MessageDisplaySide> { get }
    var isSenderAvatarImageHidden: BehaviorRelay<Bool> { get }
    var isSenderAvatarSpaceHidden: BehaviorRelay<Bool> { get }
    var roundCorners: BehaviorRelay<UIRectCorner> { get }

    // Like
    var isButtonLikeHidden: BehaviorRelay<Bool> { get }
    var isLike: BehaviorRelay<Bool> { get }
    var onToggleLike: Observable<Void> { get }
    func toggleLike()
}
