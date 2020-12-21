//
//  ChatItemsModifierImpl.swift
//  ChatTemplate
//
//  Created by Hien Pham on 7/7/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

class ChatItemsModifierImpl: NSObject, ChatItemsModifier {
    func checkAndInsertTimeIfNeeded(_ chatItemDetails: [ChatItemAdvancedViewModel],
                                    insertTimeAtHead: Bool) -> [ChatItemAdvancedViewModel] {
        var result: [ChatItemAdvancedViewModel] = Array(chatItemDetails)
        for index in 0..<chatItemDetails.count {
            let currentObject = chatItemDetails[index]

            let nextObject = (index + 1 < chatItemDetails.count) ? chatItemDetails[index + 1] : nil

            guard let currentMessage = currentObject as? MessageCellAdvancedViewModel else {
                continue
            }
            if index == 0 {
                result.insert(ChatItemTimeCellViewModelImpl(time: currentMessage.createdAt), at: 0)
                continue
            }
            guard let nextMessage = nextObject as? MessageCellAdvancedViewModel else {
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

        if insertTimeAtHead == true, let message = result.first as? MessageCellAdvancedViewModel {
            result.insert(ChatItemTimeCellViewModelImpl(time: message.createdAt), at: 0)
        }

        return result
    }

    func updateMessageBlockPosition(_ chatItemDetails: [ChatItemAdvancedViewModel]) {
        for index in 0..<chatItemDetails.count {
            let currentObject = chatItemDetails[index]
            let prevObject = (index - 1 < chatItemDetails.count && index - 1 >= 0) ? chatItemDetails[index - 1] : nil
            let nextObject = (index + 1 < chatItemDetails.count) ? chatItemDetails[index + 1] : nil

            guard let currentMessage = currentObject as? MessageCellAdvancedViewModel else {
                continue
            }

            let sameSenderWithPrevious = isMessageAndSameSender(prevObject, currentMessage)
            let sameSenderWithNext = isMessageAndSameSender(nextObject, currentMessage)

            if sameSenderWithPrevious && sameSenderWithNext {
                // Middle
                currentMessage.cell.roundCorners.accept(.allCorners)
                if currentMessage.cell.displaySide.value == .left {
                    currentMessage.cell.isSenderAvatarImageHidden.accept(true)
                }
            } else if sameSenderWithPrevious {
                // Bottom
                currentMessage.cell.roundCorners.accept([.topRight, .bottomRight, .bottomLeft])
                if currentMessage.cell.displaySide.value == .left {
                    currentMessage.cell.isSenderAvatarImageHidden.accept(false)
                }
            } else if sameSenderWithNext {
                // Top
                currentMessage.cell.roundCorners.accept([.topLeft, .topRight, .bottomRight])
                if currentMessage.cell.displaySide.value == .left {
                    currentMessage.cell.isSenderAvatarImageHidden.accept(true)
                }
            } else {
                // Single
                currentMessage.cell.roundCorners.accept([.topLeft, .topRight, .bottomRight])
                if currentMessage.cell.displaySide.value == .left {
                    currentMessage.cell.isSenderAvatarImageHidden.accept(false)
                }
            }
        }
    }
}
