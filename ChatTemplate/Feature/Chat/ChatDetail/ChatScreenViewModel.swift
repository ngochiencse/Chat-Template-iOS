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

enum ScrollActionAfterReloadData {
    /// After reload data calculate scroll position from bottom, then calculate and
    /// set contentOffset matching with that scroll position from bottom
    case keepBottomSpace
    /// Always scroll to bottom
    case forceScrollToBottom
    /// If the table view is at bottom or near bottom then scroll to bottom, else keep current contentOffset
    case recoverScrollToBottom
}

protocol ChatScreenViewModel: class {
    var basicViewModel: BasicViewModel { get }
    var chatItems: [ChatItemCellViewModel] { get }
    var isTableViewHidden: BehaviorRelay<Bool> { get }

    // Load messages
    var showsInfiniteScrolling: BehaviorRelay<Bool> { get }
    func getMessages(loadMore: Bool)

    // Send messages
    var text: BehaviorRelay<String?> { get }
    func sendText()
    func sendImage(_ image: UIImage)
    func sendImages(_ assets: [PHAsset])

    var onReloadData: PublishSubject<(ScrollActionAfterReloadData, Bool)?> { get }
}
