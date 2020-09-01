//
//  ChatItemsModifierImpl.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 7/7/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

class ChatItemsModifierImpl: NSObject, ChatItemsModifier {
    func checkAndInsertTimeIfNeeded(_ chatItems: [ChatItemCellViewModel], insertTimeAtHead: Bool) -> [ChatItemCellViewModel] {
        var result: [ChatItemCellViewModel] = Array(chatItems)
        for i in 0..<chatItems.count {
            let currentObject = chatItems[i]
            
            let nextObject = (i + 1 < chatItems.count) ? chatItems[i + 1] : nil
            
            guard let currentMessage = currentObject as? MessageCellViewModel else {
                continue
            }
            if i == 0 {
                result.insert(ChatItemTimeCellViewModelImpl(time: currentMessage.createdAt), at: 0)
                continue
            }
            guard let nextMessage = nextObject as? MessageCellViewModel else {
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
        
        if insertTimeAtHead == true, let message = result.first as? MessageCellViewModel {
            result.insert(ChatItemTimeCellViewModelImpl(time: message.createdAt), at: 0)
        }
        
        return result
    }
    
    func updateMessageBlockPosition(_ chatItems: [ChatItemCellViewModel]) {
        for i in 0..<chatItems.count {
            let currentObject = chatItems[i]
            let prevObject = (i - 1 < chatItems.count && i - 1 >= 0) ? chatItems[i - 1] : nil
            let nextObject = (i + 1 < chatItems.count) ? chatItems[i + 1] : nil
            
            guard let currentMessage = currentObject as? MessageCellViewModel else {
                continue
            }
            
            let sameSenderWithPrevious = isMessageAndSameSender(prevObject, currentMessage)
            let sameSenderWithNext = isMessageAndSameSender(nextObject, currentMessage)

            if sameSenderWithPrevious && sameSenderWithNext {
                currentMessage.blockPosition.accept(.middle)
            } else if sameSenderWithPrevious {
                currentMessage.blockPosition.accept(.bottom)
            } else if sameSenderWithNext {
                currentMessage.blockPosition.accept(.top)
            } else {
                currentMessage.blockPosition.accept(.top)
            }
        }
    }
}
