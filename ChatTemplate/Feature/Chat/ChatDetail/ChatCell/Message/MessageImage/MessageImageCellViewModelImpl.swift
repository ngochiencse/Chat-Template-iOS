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

class MessageImageCellViewModelImpl: MessageCellViewModelImpl, MessageImageCellViewModel {
    let imageSize: CGSize?
    let uploadingImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    let imageUrl: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    override var messageType: MessageCellType {
        return .image
    }
        
    init(senderAvatar: AvatarImageViewModel?, createdAtStr: String?, imageSize: CGSize?) {
        self.imageSize = imageSize
        super.init(senderAvatar: senderAvatar, createdAtStr: createdAtStr)
    }
}
