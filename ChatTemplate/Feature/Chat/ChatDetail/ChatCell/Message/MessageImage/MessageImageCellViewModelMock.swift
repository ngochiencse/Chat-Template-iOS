//
//  MessageImageCellViewModelMock.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 7/1/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class MessageImageCellViewModelMock: MessageCellViewModelImpl, MessageImageCellViewModel {
    private(set) var imageSize: CGSize?
    private(set) var uploadingImage: BehaviorRelay<UIImage?>
    private(set) var imageUrl: BehaviorRelay<String?>
    
    override var messageType: MessageTypeNew {
        return .image
    }
        
    init(imageSize: CGSize?, uploadingImage: UIImage?, imageUrl: String?,
         messageId: MessageId?, localId: Int?, messageIdBefore: MessageId?,
         sender: ChatUser, createdAt: Date?, myUserId: ChatUserId?) {
        self.imageSize = imageSize
        self.uploadingImage = BehaviorRelay(value: uploadingImage)
        self.imageUrl = BehaviorRelay(value: imageUrl)
        super.init(messageId: messageId, localId: localId, messageIdBefore: messageIdBefore, sender: sender, createdAt: createdAt, myUserId: myUserId)
    }
        
    func didSendMessageSuccess(messageId: MessageId, imageSize: CGSize?, imageUrl: String?) {
        self.imageSize = imageSize
        self.imageUrl.accept(imageUrl)
        super.didSendMessageSuccess(messageId: messageId)
    }
}
