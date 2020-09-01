//
//  MessageCellViewModelImpl.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CocoaLumberjack

class MessageCellViewModelImpl: NSObject, MessageCellViewModel {
    private(set) var messageId: MessageId?
    private(set) var localId: Int?
    private(set) var messageIdBefore: MessageId?
    var messageType: MessageTypeNew {
        fatalError("Not implemented")
    }
    let sender: ChatUser
    var isMyMessage: Bool {
        return sender.id == myUserId
    }
    let myUserId: ChatUserId?
    var itemType: ChatItemType {
        return .message
    }
    
    let createdAt: Date?
    let isLikeBS: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isLike: Bool {
        get {
            return isLikeBS.value
        }
        set {
            isLikeBS.accept(newValue)
        }
    }
    var isLikeObs: Observable<Bool> {
        return isLikeBS.asObservable()
    }
    let blockPosition: BehaviorRelay<MessageBlockPosition?> = BehaviorRelay(value: nil)
    private let onToggleLikePS: PublishSubject<Bool> = PublishSubject()
    var onToggleLike: Observable<Bool> {
        return onToggleLikePS.asObservable()
    }
    
    var data: Any?
    
    init(messageId: MessageId?, localId: Int?, messageIdBefore: MessageId?,
         sender: ChatUser, createdAt: Date?, myUserId: ChatUserId?) {
        self.messageId = messageId
        self.localId = localId
        self.messageIdBefore = messageIdBefore
        self.sender = sender
        self.myUserId = myUserId
        self.createdAt = createdAt
        super.init()
    }
    
    func toggleLike() {
        isLikeBS.accept(!isLikeBS.value)
    }
    
    func didSendMessageSuccess(messageId: MessageId) {
        self.messageId = messageId
    }    
}
