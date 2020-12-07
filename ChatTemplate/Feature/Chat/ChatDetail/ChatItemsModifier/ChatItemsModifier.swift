//
//  ChatItemsModifier.swift
//  ChatTemplate
//
//  Created by Hien Pham on 7/7/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

protocol ChatItemsModifier: class {
    func checkAndInsertTimeIfNeeded(_ chatItemDetails: [ChatItemAdvancedViewModel],
                                    insertTimeAtHead: Bool) -> [ChatItemAdvancedViewModel]
    func updateMessageBlockPosition(_ chatItemDetails: [ChatItemAdvancedViewModel])
}
