//
//  MessageImageCellViewModelImpl.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class MessageImageCellViewModelImpl: MessageCellViewModelImpl, MessageImageCellViewModel {
    private(set) var imageSize: CGSize?
    private(set) var uploadingImage: BehaviorRelay<UIImage?>
    private var imagePath: BehaviorRelay<String?>
    private(set) var imageUrl: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let imageDomain: String?
    
    override var messageType: MessageTypeNew {
        return .image
    }
    
    init(imageSize: CGSize?, uploadingImage: UIImage?, imagePath: String?,
         messageId: MessageId?, localId: Int?, messageIdBefore: MessageId?,
         sender: ChatUser, createdAt: Date?, myUserId: ChatUserId?, imageDomain: String?) {
        self.imageSize = imageSize
        self.uploadingImage = BehaviorRelay(value: uploadingImage)
        self.imageDomain = imageDomain
        self.imagePath = BehaviorRelay(value: imagePath)
        super.init(messageId: messageId, localId: localId, messageIdBefore: messageIdBefore, sender: sender, createdAt: createdAt, myUserId: myUserId)
        bindToEvents()
    }
    
    private func bindToEvents() {
        imagePath.subscribe(onNext: {[weak self] (imagePath) in
            guard let self = self else { return }
            if let imageDomain = self.imageDomain, let imagePath = imagePath {
                self.imageUrl.accept(imageDomain + imagePath)
            } else {
                self.imageUrl.accept(nil)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func didSendMessageSuccess(messageId: MessageId, imageSize: CGSize?, imageUrl: String?) {
        self.imageSize = imageSize
        self.imageUrl.accept(imageUrl)
        super.didSendMessageSuccess(messageId: messageId)
    }
}
