//
//  ChatScreenViewModel.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/30/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

protocol ChatScreenViewModel: class {
    var basicViewModel: BasicViewModel { get }
    var chatItems: [ChatItemCellViewModel] { get }
        
    // Load messages
    var showsInfiniteScrolling: BehaviorRelay<Bool> { get }
    var didFinishLoadFirstTime: PublishSubject<Void> { get }
    var didFinishLoadMore: PublishSubject<Void> { get }
    func getMessages(loadMore : Bool)
    
    // Send messages
    func sendText(_ text: String)
    func sendImage(_ image: UIImage)
    func sendImages(_ assets: [PHAsset])
    var onSendMessagesStart: PublishSubject<Void> { get }
    var onSendMessagesFinish: PublishSubject<Void> { get }
    
    // Receive message
    var onReceiveMessages: PublishSubject<Void> { get }
}
