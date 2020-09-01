//
//  ChatItemTimeCellViewModelImpl.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

class ChatItemTimeCellViewModelImpl: NSObject, ChatItemTimeCellViewModel {
    var itemType: ChatItemType {
        return .time
    }
    
    let time: Date?
    init(time: Date?) {
        self.time = time
        super.init()
    }
}
