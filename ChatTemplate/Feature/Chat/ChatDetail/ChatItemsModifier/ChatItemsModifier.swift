//
//  ChatItemsModifier.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 7/7/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

protocol ChatItemsModifier: class {
    func checkAndInsertTimeIfNeeded(_ chatItems: [ChatItemCellViewModel], insertTimeAtHead: Bool) -> [ChatItemCellViewModel]
    func updateMessageBlockPosition(_ chatItems: [ChatItemCellViewModel])
}
