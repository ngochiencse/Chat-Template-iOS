//
//  MessageOperationMock.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MessageOperationMock: AsyncOperation {
    let localId: Int
    let remoteIdBefore: MessageId
    
    var remoteId: MessageId?
    var error: Error?
    
    init(localId: Int, remoteIdBefore: MessageId) {
        self.localId = localId
        self.remoteIdBefore = remoteIdBefore
        super.init()
    }
}
