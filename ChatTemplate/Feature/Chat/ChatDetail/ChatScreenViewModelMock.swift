//
//  ChatScreenViewModelMock.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos
import SwiftDate

class ChatScreenViewModelMock: NSObject, ChatScreenViewModel {
    let otherUser: BehaviorRelay<User?> = BehaviorRelay(value: nil)
    let basicViewModel: BasicViewModel
    let itemsModifier: ChatItemsModifier
    var chatItems: [ChatItemCellViewModel] {
        return chatItemsDetail.map { (ele) -> ChatItemCellViewModel in
            if let unwrapped = ele as? MessageCellDetailViewModel {
                return unwrapped.uiViewModel
            } else {
                let unwrapped = ele as! ChatItemTimeCellViewModel
                return unwrapped
            }
        }
    }
    var chatItemsDetail: [Any] {
        var chatItems: [ChatItemDetailViewModel] = messagesRemote + messagesSending
        chatItems = itemsModifier.checkAndInsertTimeIfNeeded(messagesRemote + messagesSending, insertTimeAtHead: !showsInfiniteScrolling.value)
        itemsModifier.updateMessageBlockPosition(chatItems)
        return chatItems
    }
    
    private(set) var showsInfiniteScrolling: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let didFinishLoadFirstTime: PublishSubject<Void> = PublishSubject()
    let didFinishLoadMore: PublishSubject<Void> = PublishSubject()
    let onSendMessagesStart: PublishSubject<Void> = PublishSubject()
    let onSendMessagesFinish: PublishSubject<Void> = PublishSubject()
    let onReceiveMessages: PublishSubject<Void> = PublishSubject()
    var onUpdateMessagesFinish: PublishSubject<Void> = PublishSubject()

    private(set) var isLoading: Bool = false
    private var messagesRemote: [MessageCellDetailViewModel] = []
    private var messagesSending: [MessageCellDetailViewModel] = []

    let userOtherId: ChatUserId = "8"
    let userMeId: ChatUserId = "19"
    
    private var queue: OperationQueue = OperationQueue()
    
    private var timerText: Timer?
    private var timerImage: Timer?

    init(basicViewModel: BasicViewModel = BasicViewModelImpl(),
         itemsModifier: ChatItemsModifier = ChatItemsModifierImpl()) {
        self.basicViewModel = basicViewModel
        self.itemsModifier = itemsModifier
        super.init()
//        simulateReceiveMessages()
    }
    
    private func simulateReceiveMessages() {
        let otherAvatar: AvatarImageViewModel = AvatarImageViewModelImpl()
        otherAvatar.avatarUrlStr.accept("https://i.pinimg.com/236x/9f/80/ad/9f80ad4b76f76d54cc4e84bc1b0028bc.jpg")
        
        timerText = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            let uiViewModel: MessageCellViewModel = MessageTextCellViewModelImpl(senderAvatar: otherAvatar,
                                                                             createdAtStr: Date().toFormat("hh:mm"),
                                                                             text: "Hello")
            let message: MessageCellDetailViewModel =
                MessageCellDetailViewModelImpl(messageId: "123",
                                               senderId: self.userOtherId,
                                               localId: nil,
                                               messageIdBefore: nil,
                                               createdAt: Date(),
                                               uiViewModel: uiViewModel)
            self.messagesRemote.append(message)
            self.onReceiveMessages.onNext(())
        }
        
        timerImage = Timer.scheduledTimer(withTimeInterval: 7, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            let uiViewModel: MessageImageCellViewModel =
                MessageImageCellViewModelMock(senderAvatar: otherAvatar,
                                              createdAtStr: Date().toFormat("hh:mm"),
                                              imageSize: CGSize(width: 1067, height: 800))
            uiViewModel.imageUrl.accept("https://hoidulich.net/wp-content/uploads/2019/11/71118571_400051820571391_381023500722296458_n-1067x800.jpg")
            
            let message: MessageCellDetailViewModel =
                MessageCellDetailViewModelImpl(messageId: "456",
                                               senderId: self.userOtherId,
                                               localId: nil,
                                               messageIdBefore: nil,
                                               createdAt: Date(),
                                               uiViewModel: uiViewModel)

            self.messagesRemote.append(message)
            
            self.onReceiveMessages.onNext(())
        }
    }
    
    func getMessages(loadMore: Bool) {
        guard isLoading == false else { return }
        isLoading = true
        if loadMore == false {
            basicViewModel.showIndicator.accept(true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            let newMessages = self.mockData()
            if loadMore == false {
                self.messagesRemote.removeAll()
            }
            self.messagesRemote.insert(contentsOf: newMessages, at: 0)
            self.showsInfiniteScrolling.accept(true)
            self.basicViewModel.showIndicator.accept(false)
            self.isLoading = false
            
            if loadMore == true {
                self.didFinishLoadMore.onNext(())
            } else {
                self.didFinishLoadFirstTime.onNext(())
            }
        }
    }
    
    func sendText(_ text: String) {
        let cleanedText: String = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanedText.isEmpty == false else { return }
        
        guard let remoteIdBefore = messagesRemote.last?.messageId else { return }
        let localId: Int = (messagesSending.last?.localId ?? 0) + 1
        
        // Set up view model
        let uiViewModel: MessageCellViewModel = MessageTextCellViewModelImpl(senderAvatar: nil,
                                                                         createdAtStr: Date().toFormat("hh:mm"),
                                                                         text: cleanedText)
        uiViewModel.displaySide.accept(.right)
        uiViewModel.isSenderAvatarImageHidden.accept(true)
        uiViewModel.isSenderAvatarSpaceHidden.accept(true)
        
        let message: MessageCellDetailViewModel =
            MessageCellDetailViewModelImpl(messageId: nil,
                                           senderId: self.userOtherId,
                                           localId: localId,
                                           messageIdBefore: remoteIdBefore,
                                           createdAt: Date(),
                                           uiViewModel: uiViewModel)

        messagesSending.append(message)
        
        // Set up operation
        let operation = MessageTextOperationMock(text: cleanedText, localId: localId, remoteIdBefore: remoteIdBefore)
        operation.completionBlock = {[weak self] in
            guard let self = self else { return }
            self.handleCompleteMessageOperation(operation) { (cellViewModel) in
                guard let remoteId = operation.remoteId else { return }
                cellViewModel.messageId = remoteId
            }
        }
        queue.addOperation(operation)
        
        onSendMessagesStart.onNext(())
    }
    
    func likeToggle(isLike: Bool, messageId: String) {
        
    }

    private func handleCompleteMessageOperation(_ operation: MessageOperationMock, onSuccess success:((_ cellViewModel: MessageCellDetailViewModel) -> Void)?) {
        let localId = operation.localId
        let remoteIdBefore = operation.remoteIdBefore

        if let cellViewModel = self.messagesSending.first(where: { (ele) -> Bool in
            return (ele.localId == localId && ele.messageIdBefore == remoteIdBefore)
        }) {
            self.messagesSending.removeAll { (ele) -> Bool in
                return (ele.localId == localId && ele.messageIdBefore == remoteIdBefore)
            }
            if let error = operation.error {
                self.onSendMessagesFinish.onError(error)
            } else {
                if let index = self.messagesRemote.lastIndex(where: { (ele) -> Bool in
                    return (ele.messageId == remoteIdBefore)
                }) {
                    self.messagesRemote.insert(cellViewModel, at: index + 1)
                }
                success?(cellViewModel)
                self.onSendMessagesFinish.onNext(())
            }
        }
    }

    func sendImage(_ image: UIImage) {
        guard let remoteIdBefore = messagesRemote.last?.messageId else { return }
        let localId: Int = (messagesSending.last?.localId ?? 0) + 1

        // Set up view model
        let uiViewModel: MessageImageCellViewModel = MessageImageCellViewModelMock(senderAvatar: nil, createdAtStr: Date().toFormat("hh:mm"), imageSize: image.size)
        uiViewModel.uploadingImage.accept(image)
        uiViewModel.displaySide.accept(.right)
        uiViewModel.isSenderAvatarImageHidden.accept(true)
        uiViewModel.isSenderAvatarSpaceHidden.accept(true)
        let message: MessageCellDetailViewModel =
            MessageCellDetailViewModelImpl(messageId: nil,
                                           senderId: self.userOtherId,
                                           localId: localId,
                                           messageIdBefore: remoteIdBefore,
                                           createdAt: Date(),
                                           uiViewModel: uiViewModel)

        messagesSending.append(message)
        
        // Set up operation
        let operation = MessageImageOperationMock(image: image, localId: localId, remoteIdBefore: remoteIdBefore)
        operation.completionBlock = {[weak self] in
            guard let self = self else { return }
            self.handleCompleteMessageOperation(operation) { (cellViewModel) in
                guard let remoteId = operation.remoteId else { return }
                cellViewModel.messageId = remoteId
                guard let uiViewModel = cellViewModel.uiViewModel as? MessageImageCellViewModel else { return }
                uiViewModel.imageUrl.accept(operation.remoteImageUrl)
            }
        }
        queue.addOperation(operation)

        onSendMessagesStart.onNext(())
    }
    
    func sendImages(_ assets: [PHAsset]) {
        assets.forEach { (ele) in
            let image: UIImage = getAssetThumbnail(asset: ele)
            sendImage(image)
        }
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }

    var roomName: String? {
       return "Mock chat room"
    }
}

extension ChatScreenViewModelMock {
    func mockData() -> [MessageCellDetailViewModel] {
        var newMessages: [MessageCellDetailViewModel] = Array()
        for i in 0..<5 {
            let createdAt = Date() - (i + 1).days
            
            let otherAvatar: AvatarImageViewModel = AvatarImageViewModelImpl()
            otherAvatar.avatarUrlStr.accept("https://i.pinimg.com/236x/9f/80/ad/9f80ad4b76f76d54cc4e84bc1b0028bc.jpg")

            do {
                let uiViewModel: MessageTextCellViewModel =
                    MessageTextCellViewModelImpl(senderAvatar: nil,
                                                 createdAtStr: createdAt.toFormat("hh:mm"),
                                                 text: "Lovely girls, they were very communicative\nand left the place clean.\nI'd definitely recommend them as guests!")
                let message: MessageCellDetailViewModel =
                    MessageCellDetailViewModelImpl(messageId: "1",
                                                   senderId: self.userMeId,
                                                   localId: nil,
                                                   messageIdBefore: nil,
                                                   createdAt: createdAt,
                                                   uiViewModel: uiViewModel)
                newMessages.append(message)
            }
            
            do {
                let uiViewModel: MessageTextCellViewModel =
                    MessageTextCellViewModelImpl(senderAvatar: otherAvatar,
                                                 createdAtStr: createdAt.toFormat("hh:mm"),
                                                 text: "Good!")
                let message: MessageCellDetailViewModel =
                    MessageCellDetailViewModelImpl(messageId: "2",
                                                   senderId: self.userOtherId,
                                                   localId: nil,
                                                   messageIdBefore: nil,
                                                   createdAt: createdAt,
                                                   uiViewModel: uiViewModel)
                newMessages.append(message)
            }
            
            do {
                let uiViewModel: MessageTextCellViewModel =
                    MessageTextCellViewModelImpl(senderAvatar: otherAvatar,
                                                 createdAtStr: createdAt.toFormat("hh:mm"),
                                                 text: "Glad you enjoy it ^^!")
                let message: MessageCellDetailViewModel =
                    MessageCellDetailViewModelImpl(messageId: "3",
                                                   senderId: self.userOtherId,
                                                   localId: nil,
                                                   messageIdBefore: nil,
                                                   createdAt: createdAt,
                                                   uiViewModel: uiViewModel)
                newMessages.append(message)
            }
            
            do {
                let uiViewModel: MessageImageCellViewModel =
                    MessageImageCellViewModelMock(senderAvatar: nil,
                                                  createdAtStr: Date().toFormat("hh:mm"),
                                                  imageSize: CGSize(width: 1067, height: 800))
                uiViewModel.imageUrl.accept("https://hoidulich.net/wp-content/uploads/2019/11/71118571_400051820571391_381023500722296458_n-1067x800.jpg")
                let message: MessageCellDetailViewModel =
                    MessageCellDetailViewModelImpl(messageId: "4",
                                                   senderId: self.userMeId,
                                                   localId: nil,
                                                   messageIdBefore: nil,
                                                   createdAt: createdAt,
                                                   uiViewModel: uiViewModel)
                newMessages.append(message)
            }

            do {
                let uiViewModel: MessageTextCellViewModel =
                    MessageTextCellViewModelImpl(senderAvatar: nil,
                                                 createdAtStr: createdAt.toFormat("hh:mm"),
                                                 text: "Here is a picture of us ^^")
                let message: MessageCellDetailViewModel =
                    MessageCellDetailViewModelImpl(messageId: "5",
                                                   senderId: self.userMeId,
                                                   localId: nil,
                                                   messageIdBefore: nil,
                                                   createdAt: createdAt,
                                                   uiViewModel: uiViewModel)
                newMessages.append(message)
            }
            
            do {
                let uiViewModel: MessageTextCellViewModel =
                    MessageTextCellViewModelImpl(senderAvatar: nil,
                                                 createdAtStr: createdAt.toFormat("hh:mm"),
                                                 text: "Oh it was so beautiful!")
                let message: MessageCellDetailViewModel =
                    MessageCellDetailViewModelImpl(messageId: "6",
                                                   senderId: self.userMeId,
                                                   localId: nil,
                                                   messageIdBefore: nil,
                                                   createdAt: createdAt,
                                                   uiViewModel: uiViewModel)
                newMessages.append(message)
            }
        }
        
        newMessages.forEach { (ele) in
            let isMyMessage: Bool = ele.senderId == userMeId
            ele.uiViewModel.displaySide.accept(isMyMessage ? .right : .left)
            ele.uiViewModel.isSenderAvatarImageHidden.accept(isMyMessage)
            ele.uiViewModel.isSenderAvatarSpaceHidden.accept(isMyMessage)
        }
        
        return newMessages
    }
}
