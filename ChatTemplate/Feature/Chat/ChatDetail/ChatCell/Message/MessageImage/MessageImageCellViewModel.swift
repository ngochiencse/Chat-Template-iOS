//
//  MessageImageCellViewModel.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol MessageImageCellViewModel: MessageCellViewModel {
    var imageSize: CGSize? { get }
    var uploadingImage: BehaviorRelay<UIImage?> { get }
    var imageUrl: BehaviorRelay<String?> { get }
    
    func didSendMessageSuccess(messageId: MessageId, imageSize: CGSize?, imageUrl: String?)
}
