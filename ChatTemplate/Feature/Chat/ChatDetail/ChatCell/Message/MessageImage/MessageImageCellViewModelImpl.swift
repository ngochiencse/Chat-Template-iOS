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
    let imageSize: CGSize?
    let uploadingImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    private let imagePath: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let imageUrl: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let imageDomain: String?
    
    override var messageType: MessageCellType {
        return .image
    }
    
    init(senderAvatar: AvatarImageViewModel?, createdAtStr: String?,
         imageSize: CGSize?, imageDomain: String?) {
        self.imageSize = imageSize
        self.imageDomain = imageDomain
        super.init(senderAvatar: senderAvatar, createdAtStr: createdAtStr)
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
    
//    func didSendMessageSuccess(messageId: MessageId, imageSize: CGSize?, imageUrl: String?) {
//        self.imageSize = imageSize
//        self.imageUrl.accept(imageUrl)
//        super.didSendMessageSuccess(messageId: messageId)
//    }
}
