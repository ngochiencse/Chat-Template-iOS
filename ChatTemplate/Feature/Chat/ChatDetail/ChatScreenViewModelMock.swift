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
        var chatItems: [ChatItemCellViewModel] = messagesRemote + messagesSending
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
    private var messagesRemote: [MessageCellViewModel] = []
    private var messagesSending: [MessageCellViewModel] = []
    private let userOther: ChatUser = ChatUser(id: "8",
                                               avatar: "https://i.pinimg.com/236x/9f/80/ad/9f80ad4b76f76d54cc4e84bc1b0028bc.jpg")
    private let userMe: ChatUser = ChatUser(id: "19",
                                               avatar: nil)
    
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
        timerText = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            let message: MessageCellViewModel = MessageTextCellViewModelImpl(text: "Hello",
                                                                             messageId: "123",
                                                                             localId: nil,
                                                                             messageIdBefore: nil,
                                                                             sender: self.userOther,
                                                                             createdAt: Date(),
                                                                             myUserId: self.userMe.id)
            self.messagesRemote.append(message)
            self.onReceiveMessages.onNext(())
        }
        
        timerImage = Timer.scheduledTimer(withTimeInterval: 7, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            let message: MessageImageCellViewModel = MessageImageCellViewModelMock(imageSize: CGSize(width: 1067, height: 800),
                                                                              uploadingImage: nil,
                                                                              imageUrl: "https://hoidulich.net/wp-content/uploads/2019/11/71118571_400051820571391_381023500722296458_n-1067x800.jpg",
                                                                              messageId: "456",
                                                                              localId: nil,
                                                                              messageIdBefore: nil,
                                                                              sender: self.userOther,
                                                                              createdAt: Date(),
                                                                              myUserId: self.userMe.id)
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
        let message: MessageCellViewModel = MessageTextCellViewModelImpl(text: cleanedText,
                                                                         messageId: nil,
                                                                         localId: localId,
                                                                         messageIdBefore: remoteIdBefore,
                                                                         sender: userMe,
                                                                         createdAt: Date(),
                                                                         myUserId: userMe.id)
        messagesSending.append(message)
        
        // Set up operation
        let operation = MessageTextOperationMock(text: cleanedText, localId: localId, remoteIdBefore: remoteIdBefore)
        operation.completionBlock = {[weak self] in
            guard let self = self else { return }
            self.handleCompleteMessageOperation(operation) { (cellViewModel) in
                guard let remoteId = operation.remoteId else { return }
                cellViewModel.didSendMessageSuccess(messageId: remoteId)
            }
        }
        queue.addOperation(operation)
        
        onSendMessagesStart.onNext(())
    }
    
    func likeToggle(isLike: Bool, messageId: String) {
        
    }

    private func handleCompleteMessageOperation(_ operation: MessageOperationMock, onSuccess success:((_ cellViewModel: MessageCellViewModel) -> Void)?) {
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
        let message: MessageImageCellViewModel = MessageImageCellViewModelMock(imageSize: nil,
                                                                               uploadingImage: image,
                                                                               imageUrl: nil,
                                                                               messageId: nil,
                                                                               localId: localId,
                                                                               messageIdBefore: remoteIdBefore,
                                                                               sender: userMe,
                                                                               createdAt: Date(),
                                                                               myUserId: userMe.id)
        messagesSending.append(message)
        
        // Set up operation
        let operation = MessageImageOperationMock(image: image, localId: localId, remoteIdBefore: remoteIdBefore)
        operation.completionBlock = {[weak self] in
            guard let self = self else { return }
            self.handleCompleteMessageOperation(operation) { (cellViewModel) in
                guard let remoteId = operation.remoteId else { return }
                guard let cellViewModel = cellViewModel as? MessageImageCellViewModel else { return }
                cellViewModel.didSendMessageSuccess(messageId: remoteId, imageSize: operation.remoteImageSize, imageUrl: operation.remoteImageUrl)
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
    func mockData() -> [MessageCellViewModel] {
        var newMessages: [MessageCellViewModel] = Array()
        for _ in 0..<5 {
            let yesterday = Date() - 1.days
            
            newMessages.append(MessageTextCellViewModelImpl(text: "Lovely girls, they were very communicative\nand left the place clean.\nI'd definitely recommend them as guests!",
                                                               messageId: "1",
                                                               localId: nil,
                                                               messageIdBefore: nil,
                                                               sender: userMe,
                                                               createdAt: yesterday,
                                                               myUserId: userMe.id))
            
            newMessages.append(MessageTextCellViewModelImpl(text: "Good!",
                                                               messageId: "2",
                                                               localId: nil,
                                                               messageIdBefore: nil,
                                                               sender: userOther,
                                                               createdAt: yesterday,
                                                               myUserId: userMe.id))
            
            newMessages.append(MessageTextCellViewModelImpl(text: "Glad you enjoy it ^^!",
                                                               messageId: "3",
                                                               localId: nil,
                                                               messageIdBefore: nil,
                                                               sender: userOther,
                                                               createdAt: yesterday,
                                                               myUserId: userMe.id))
            
            newMessages.append(MessageImageCellViewModelMock(imageSize: CGSize(width: 1067, height: 800),
                                                                uploadingImage: nil,
                                                                imageUrl: "https://hoidulich.net/wp-content/uploads/2019/11/71118571_400051820571391_381023500722296458_n-1067x800.jpg",
                                                                messageId: "4",
                                                                localId: nil,
                                                                messageIdBefore: nil,
                                                                sender: userMe,
                                                                createdAt: yesterday,
                                                                myUserId: userMe.id))
            
            newMessages.append(MessageTextCellViewModelImpl(text: "Here is a picture of us ^^",
                                                               messageId: "5",
                                                               localId: nil,
                                                               messageIdBefore: nil,
                                                               sender: userMe,
                                                               createdAt: yesterday,
                                                               myUserId: userMe.id))
            
            newMessages.append(MessageTextCellViewModelImpl(text: "Oh it was so beautiful!",
                                                               messageId: "6",
                                                               localId: nil,
                                                               messageIdBefore: nil,
                                                               sender: userMe,
                                                               createdAt: yesterday,
                                                               myUserId: userMe.id))
            
        }
        
        
        return newMessages
    }
}
