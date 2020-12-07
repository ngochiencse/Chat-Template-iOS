//
//  MessageCellViewModelImpl.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CocoaLumberjack

class MessageCellViewModelImpl: NSObject, MessageCellViewModel {
    var messageType: MessageCellType {
        fatalError("Not implemented")
    }
    var itemType: ChatItemType {
        return .message
    }
    
    let createdAtStr: String?
    
    let isSenderAvatarImageHidden: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isSenderAvatarSpaceHidden: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let roundCorners: BehaviorRelay<UIRectCorner> = BehaviorRelay(value: [.topLeft, .topRight, .bottomRight])
    let displaySide: BehaviorRelay<MessageDisplaySide> = BehaviorRelay(value: .left)
    let senderAvatar: AvatarImageViewModel?
    var isButtonLikeHidden: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let isLike: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let onToggleLikePS: PublishSubject<Void> = PublishSubject()
    var onToggleLike: Observable<Void> {
        return onToggleLikePS.asObservable()
    }

    init(senderAvatar: AvatarImageViewModel?, createdAtStr: String?) {
        self.senderAvatar = senderAvatar
        self.createdAtStr = createdAtStr
        super.init()
    }
    
    
    func toggleLike() {
        onToggleLikePS.onNext(())
    }
}
