//
//  ChatScreenViewModelMock.swift
//  ChatTemplate
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
        return chatItemsBR.value
    }
    private let chatItemsBR: BehaviorRelay<[ChatItemCellViewModel]> = BehaviorRelay(value: [])
    private let chatItemsDetailBR: BehaviorRelay<[Any]> = BehaviorRelay(value: [])

    private(set) var showsInfiniteScrolling: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let didFinishLoadFirstTime: PublishSubject<Void> = PublishSubject()
    let didFinishLoadMore: PublishSubject<Void> = PublishSubject()
    let onSendMessagesStart: PublishSubject<Void> = PublishSubject()
    let onSendMessagesFinish: PublishSubject<Void> = PublishSubject()
    let onReceiveMessages: PublishSubject<Void> = PublishSubject()

    private(set) var isLoading: Bool = false
    private let messagesRemoteBR: BehaviorRelay<[MessageCellAdvancedViewModel]> = BehaviorRelay(value: [])
    private let messagesSendingBR: BehaviorRelay<[MessageCellAdvancedViewModel]> = BehaviorRelay(value: [])

    let userOtherId: ChatUserId = "8"
    let userMeId: ChatUserId = "19"

    private var queue: OperationQueue = OperationQueue()

    private var timerText: Timer?
    private var timerImage: Timer?

    private let maxPages: Int = 3
    private var currentPage: Int = 0

    init(basicViewModel: BasicViewModel = BasicViewModelImpl(),
         itemsModifier: ChatItemsModifier = ChatItemsModifierImpl()) {
        self.basicViewModel = basicViewModel
        self.itemsModifier = itemsModifier
        super.init()
        bindToEvents()
        simulateReceiveMessages()
    }

    private func bindToEvents() {
        Observable.combineLatest(messagesRemoteBR.asObservable(),
                                 messagesSendingBR.asObservable(),
                                 showsInfiniteScrolling.asObservable())
            .map {[weak self] (values) -> [Any] in
                guard let self = self else {
                    return []
                }
                let (messagesRemote, messagesSending, showsInfiniteScrolling) = values
                var chatItems: [ChatItemAdvancedViewModel] = messagesRemote + messagesSending
                chatItems = self.itemsModifier.checkAndInsertTimeIfNeeded(messagesRemote + messagesSending,
                                                                          insertTimeAtHead: !showsInfiniteScrolling)
                self.itemsModifier.updateMessageBlockPosition(chatItems)
                return chatItems
            }
            .bind(to: chatItemsDetailBR).disposed(by: rx.disposeBag)

        chatItemsDetailBR.map { (chatItemsDetail) -> [ChatItemCellViewModel] in
            return chatItemsDetail.map { (ele) -> ChatItemCellViewModel in
                if let unwrapped = ele as? MessageCellAdvancedViewModel {
                    return unwrapped.cell
                } else {
                    guard let unwrapped = ele as? ChatItemTimeCellViewModel else {
                        return ChatItemTimeCellViewModelImpl(time: nil)
                    }
                    return unwrapped
                }
            }
        }.bind(to: chatItemsBR).disposed(by: rx.disposeBag)

    }

    private func simulateReceiveMessages() {
        let otherAvatar: AvatarImageViewModel = AvatarImageViewModelImpl()
        otherAvatar.avatarUrlStr.accept("https://i.pinimg.com/236x/9f/80/ad/9f80ad4b76f76d54cc4e84bc1b0028bc.jpg")

        timerText = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            var messagesRemote = self.messagesRemoteBR.value

            let cell: MessageCellViewModel =
                MessageTextCellViewModelImpl(senderAvatar: otherAvatar,
                                             createdAtStr: Date().toFormat("hh:mm"),
                                             attributedText: self.attributedText(from: "Hello"))
            let message: MessageCellAdvancedViewModel =
                MessageCellAdvancedViewModelImpl(messageId: "123",
                                                 senderId: self.userOtherId,
                                                 localId: nil,
                                                 messageIdBefore: nil,
                                                 createdAt: Date(),
                                                 cell: cell)
            messagesRemote.append(message)
            self.messagesRemoteBR.accept(messagesRemote)
            self.onReceiveMessages.onNext(())
        }

        timerImage = Timer.scheduledTimer(withTimeInterval: 7, repeats: true) {[weak self] _ in
            guard let self = self else { return }
            var messagesRemote = self.messagesRemoteBR.value

            let cell: MessageImageCellViewModel =
                MessageImageCellViewModelImpl(senderAvatar: otherAvatar,
                                              createdAtStr: Date().toFormat("hh:mm"),
                                              imageSize: CGSize(width: 1067, height: 800))
            cell.imageUrl.accept("""
https://hoidulich.net/wp-content/uploads/2019/11/\
71118571_400051820571391_381023500722296458_n-1067x800.jpg
""")

            let message: MessageCellAdvancedViewModel =
                MessageCellAdvancedViewModelImpl(messageId: "456",
                                                 senderId: self.userOtherId,
                                                 localId: nil,
                                                 messageIdBefore: nil,
                                                 createdAt: Date(),
                                                 cell: cell)

            messagesRemote.append(message)
            self.messagesRemoteBR.accept(messagesRemote)
            self.onReceiveMessages.onNext(())
        }
    }

    func getMessages(loadMore: Bool) {
        guard isLoading == false else { return }
        isLoading = true
        if loadMore == false {
            basicViewModel.showIndicator.accept(true)
        }
        // TODO: Implement real api here

        var messagesRemote = messagesRemoteBR.value
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            guard let self = self else { return }
            let newMessages: [MessageCellAdvancedViewModel]
            if self.currentPage < self.maxPages {
                newMessages = self.mockData()
                self.currentPage += 1
            } else {
                newMessages = []
            }
            if loadMore == false {
                messagesRemote.removeAll()
            }
            messagesRemote.insert(contentsOf: newMessages, at: 0)
            self.messagesRemoteBR.accept(messagesRemote)
            self.showsInfiniteScrolling.accept(newMessages.count > 0)
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

        guard let remoteIdBefore = messagesRemoteBR.value.last?.messageId else { return }
        let localId: Int = (messagesSendingBR.value.last?.localId ?? 0) + 1

        // Set up view model
        let cell: MessageCellViewModel = MessageTextCellViewModelImpl(senderAvatar: nil,
                                                                      createdAtStr: Date().toFormat("hh:mm"),
                                                                      attributedText: attributedText(from: cleanedText))
        cell.displaySide.accept(.right)
        cell.isSenderAvatarImageHidden.accept(true)
        cell.isSenderAvatarSpaceHidden.accept(true)
        cell.isButtonLikeHidden.accept(true)

        let message: MessageCellAdvancedViewModel =
            MessageCellAdvancedViewModelImpl(messageId: nil,
                                             senderId: self.userOtherId,
                                             localId: localId,
                                             messageIdBefore: remoteIdBefore,
                                             createdAt: Date(),
                                             cell: cell)

        messagesSendingBR.accept(messagesSendingBR.value + [message])

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

    private func handleCompleteMessageOperation(_ operation: MessageOperationMock,
                                                onSuccess success:(
                                                    (_ cellViewModel: MessageCellAdvancedViewModel) -> Void)?) {
        let localId = operation.localId
        let remoteIdBefore = operation.remoteIdBefore

        var messagesSending = messagesSendingBR.value
        if let cellViewModel = messagesSending.first(where: { (ele) -> Bool in
            return (ele.localId == localId && ele.messageIdBefore == remoteIdBefore)
        }) {
            messagesSending.removeAll { (ele) -> Bool in
                return (ele.localId == localId && ele.messageIdBefore == remoteIdBefore)
            }
            messagesSendingBR.accept(messagesSending)
            if let error = operation.error {
                self.onSendMessagesFinish.onError(error)
            } else {
                var messagesRemote = messagesRemoteBR.value
                if let index = messagesRemote.lastIndex(where: { (ele) -> Bool in
                    return (ele.messageId == remoteIdBefore)
                }) {
                    messagesRemote.insert(cellViewModel, at: index + 1)
                }
                messagesRemoteBR.accept(messagesRemote)
                success?(cellViewModel)
                self.onSendMessagesFinish.onNext(())
            }
        }
    }

    func sendImage(_ image: UIImage) {
        guard let remoteIdBefore = messagesRemoteBR.value.last?.messageId else { return }
        let localId: Int = (messagesSendingBR.value.last?.localId ?? 0) + 1

        // Set up view model
        let cell: MessageImageCellViewModel = MessageImageCellViewModelImpl(senderAvatar: nil,
                                                                            createdAtStr: Date().toFormat("hh:mm"),
                                                                            imageSize: image.size)
        cell.uploadingImage.accept(image)
        cell.displaySide.accept(.right)
        cell.isSenderAvatarImageHidden.accept(true)
        cell.isSenderAvatarSpaceHidden.accept(true)
        cell.isButtonLikeHidden.accept(true)
        let message: MessageCellAdvancedViewModel =
            MessageCellAdvancedViewModelImpl(messageId: nil,
                                             senderId: self.userOtherId,
                                             localId: localId,
                                             messageIdBefore: remoteIdBefore,
                                             createdAt: Date(),
                                             cell: cell)

        messagesSendingBR.accept(messagesSendingBR.value + [message])

        // Set up operation
        let operation = MessageImageOperationMock(image: image, localId: localId, remoteIdBefore: remoteIdBefore)
        operation.completionBlock = {[weak self] in
            guard let self = self else { return }
            self.handleCompleteMessageOperation(operation) { (cellViewModel) in
                guard let remoteId = operation.remoteId else { return }
                cellViewModel.messageId = remoteId
                guard let cell = cellViewModel.cell as? MessageImageCellViewModel else { return }
                cell.imageUrl.accept(operation.remoteImageUrl)
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
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 1024, height: 1024),
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: {(result, _) -> Void in
                                thumbnail = result!
                             })
        return thumbnail
    }

    var roomName: String? {
        return "Mock chat room"
    }

    func attributedText(from messageText: String?) -> NSAttributedString? {
        var trimmedString: String
        if let unwrapped = messageText {
            if unwrapped.count > Constant.MAXLENGTHCHATMESSAGE {
                let start = unwrapped.startIndex
                let end = unwrapped.index(start, offsetBy: Constant.MAXLENGTHCHATMESSAGE)
                trimmedString = String(unwrapped[start..<end])
            } else {
                trimmedString = unwrapped
            }
        } else {
            trimmedString = ""
        }

        guard let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as?
                NSMutableParagraphStyle else {
            return NSAttributedString()
        }
        paragraphStyle.lineSpacing = 6
        let attrsDictionary: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.black
        ]

        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: trimmedString,
                                                                                  attributes: attrsDictionary)
        return attributedText
    }
}

extension ChatScreenViewModelMock {
    func mockData() -> [MessageCellAdvancedViewModel] {
        var newMessages: [MessageCellAdvancedViewModel] = Array()
        for index in 0..<5 {
            let createdAt = Date() - (index + 1).days
            let otherAvatar: AvatarImageViewModel = AvatarImageViewModelImpl()
            otherAvatar.avatarUrlStr.accept("https://i.pinimg.com/236x/9f/80/ad/9f80ad4b76f76d54cc4e84bc1b0028bc.jpg")
            do {
                let message: MessageCellAdvancedViewModel =
                    self.cellMessageText(createdAt: createdAt,
                                         text:
                                            """
                                            Lovely girls, they were very communicative\
                                            and left the place clean.\
                                            I'd definitely recommend them as guests!
                                            """,
                                         messageId: "1",
                                         senderId: userMeId,
                                         senderAvatar: nil)
                newMessages.append(message)
            }

            do {
                let message: MessageCellAdvancedViewModel = self.cellMessageText(createdAt: createdAt - 1.days,
                                                                                 text: "Good!",
                                                                                 messageId: "2",
                                                                                 senderId: nil,
                                                                                 senderAvatar: otherAvatar)
                newMessages.append(message)
            }
            do {
                let message: MessageCellAdvancedViewModel =
                    self.cellMessageText(createdAt: createdAt,
                                         text: "Glad you enjoy it ^^! https://ssd.userbenchmark.com/",
                                         messageId: "3",
                                         senderId: nil,
                                         senderAvatar: otherAvatar)
                newMessages.append(message)
            }
            do {
                let message: MessageCellAdvancedViewModel =
                    self.cellMessageImage(createdAt: createdAt,
                                          imageSize: CGSize(width: 1067, height: 800),
                                          imageUrl: """
                                                    https://hoidulich.net/wp-content/uploads/2019/11/71118571\
                                                    _400051820571391_381023500722296458_n-1067x800.jpg
                                                    """,
                                          messageId: "4",
                                          senderId: userMeId,
                                          senderAvatar: nil)
                newMessages.append(message)
            }
            do {
                let message: MessageCellAdvancedViewModel = self.cellMessageText(createdAt: createdAt,
                                                                                 text: "Here is a picture of us ^^",
                                                                                 messageId: "5",
                                                                                 senderId: userMeId,
                                                                                 senderAvatar: nil)
                newMessages.append(message)
            }
            do {
                let message: MessageCellAdvancedViewModel = self.cellMessageText(createdAt: createdAt,
                                                                                 text: "Oh it was so beautiful!",
                                                                                 messageId: "6",
                                                                                 senderId: nil,
                                                                                 senderAvatar: otherAvatar)
                newMessages.append(message)
            }
        }
        newMessages.forEach { (ele) in
            let isMyMessage: Bool = ele.senderId == userMeId
            ele.cell.displaySide.accept(isMyMessage ? .right : .left)
            ele.cell.isSenderAvatarImageHidden.accept(isMyMessage)
            ele.cell.isSenderAvatarSpaceHidden.accept(isMyMessage)
            ele.cell.isButtonLikeHidden.accept(isMyMessage)
        }
        newMessages = newMessages.shuffled()
        return newMessages
    }

    private func cellMessageText(createdAt: Date?,
                                 text: String?,
                                 messageId: MessageId,
                                 senderId: ChatUserId?,
                                 senderAvatar: AvatarImageViewModel?) -> MessageCellAdvancedViewModel {
        let cell: MessageTextCellViewModel =
            MessageTextCellViewModelImpl(senderAvatar: senderAvatar,
                                         createdAtStr: createdAt?.toFormat("hh:mm"),
                                         attributedText: attributedText(from: text))
        let message: MessageCellAdvancedViewModel =
            MessageCellAdvancedViewModelImpl(messageId: messageId,
                                             senderId: senderId,
                                             localId: nil,
                                             messageIdBefore: nil,
                                             createdAt: createdAt,
                                             cell: cell)
        return message
    }

    private func cellMessageImage(createdAt: Date?,
                                  imageSize: CGSize,
                                  imageUrl: String?,
                                  messageId: MessageId,
                                  senderId: ChatUserId?,
                                  senderAvatar: AvatarImageViewModel?) -> MessageCellAdvancedViewModel {
        let cell: MessageImageCellViewModel =
            MessageImageCellViewModelImpl(senderAvatar: senderAvatar,
                                          createdAtStr: createdAt?.toFormat("hh:mm"),
                                          imageSize: imageSize)
        cell.imageUrl.accept(imageUrl)
        let message: MessageCellAdvancedViewModel =
            MessageCellAdvancedViewModelImpl(messageId: messageId,
                                             senderId: senderId,
                                             localId: nil,
                                             messageIdBefore: nil,
                                             createdAt: createdAt,
                                             cell: cell)
        return message
    }
}
