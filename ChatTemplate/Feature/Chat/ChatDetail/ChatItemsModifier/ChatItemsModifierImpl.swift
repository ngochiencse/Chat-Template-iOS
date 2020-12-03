//
//  ChatItemsModifierImpl.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 7/7/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

class ChatItemsModifierImpl: NSObject, ChatItemsModifier {
    func checkAndInsertTimeIfNeeded(_ chatItemDetails: [ChatItemDetailViewModel],
                                    insertTimeAtHead: Bool) -> [ChatItemDetailViewModel] {
        var result: [ChatItemDetailViewModel] = Array(chatItemDetails)
        for i in 0..<chatItemDetails.count {
            let currentObject = chatItemDetails[i]
            
            let nextObject = (i + 1 < chatItemDetails.count) ? chatItemDetails[i + 1] : nil
            
            guard let currentMessage = currentObject as? MessageCellDetailViewModel else {
                continue
            }
            if i == 0 {
                result.insert(ChatItemTimeCellViewModelImpl(time: currentMessage.createdAt), at: 0)
                continue
            }
            guard let nextMessage = nextObject as? MessageCellDetailViewModel else {
                continue
            }
            guard let currentTime = currentMessage.createdAt else {
                continue
            }
            guard let nextTime = nextMessage.createdAt else {
                continue
            }
            
            guard currentTime.compare(.isSameDay(nextTime)) == false else {
                continue
            }
            
            if let insertIndex = result.firstIndex(where: { (element) -> Bool in
                return (element === nextMessage)
            }) {
                result.insert(ChatItemTimeCellViewModelImpl(time: nextTime), at: insertIndex)
            }
        }
        
        if insertTimeAtHead == true, let message = result.first as? MessageCellDetailViewModel {
            result.insert(ChatItemTimeCellViewModelImpl(time: message.createdAt), at: 0)
        }
        
        return result
    }
    
    func updateMessageBlockPosition(_ chatItemDetails: [ChatItemDetailViewModel]) {
        for i in 0..<chatItemDetails.count {
            let currentObject = chatItemDetails[i]
            let prevObject = (i - 1 < chatItemDetails.count && i - 1 >= 0) ? chatItemDetails[i - 1] : nil
            let nextObject = (i + 1 < chatItemDetails.count) ? chatItemDetails[i + 1] : nil
            
            guard let currentMessage = currentObject as? MessageCellDetailViewModel else {
                continue
            }
            
            let sameSenderWithPrevious = isMessageAndSameSender(prevObject, currentMessage)
            let sameSenderWithNext = isMessageAndSameSender(nextObject, currentMessage)

            if sameSenderWithPrevious && sameSenderWithNext {
                // Middle
                currentMessage.uiViewModel.roundCorners.accept(.allCorners)
                if currentMessage.uiViewModel.displaySide.value == .left {
                    currentMessage.uiViewModel.isSenderAvatarImageHidden.accept(true)
                }
            } else if sameSenderWithPrevious {
                // Bottom
                currentMessage.uiViewModel.roundCorners.accept([.topRight, .bottomRight, .bottomLeft])
                if currentMessage.uiViewModel.displaySide.value == .left {
                    currentMessage.uiViewModel.isSenderAvatarImageHidden.accept(false)
                }
            } else if sameSenderWithNext {
                // Top
                currentMessage.uiViewModel.roundCorners.accept([.topLeft, .topRight, .bottomRight])
                if currentMessage.uiViewModel.displaySide.value == .left {
                    currentMessage.uiViewModel.isSenderAvatarImageHidden.accept(true)
                }
            } else {
                // Single
                currentMessage.uiViewModel.roundCorners.accept([.topLeft, .topRight, .bottomRight])
                if currentMessage.uiViewModel.displaySide.value == .left {
                    currentMessage.uiViewModel.isSenderAvatarImageHidden.accept(false)
                }
            }
        }
    }
}
