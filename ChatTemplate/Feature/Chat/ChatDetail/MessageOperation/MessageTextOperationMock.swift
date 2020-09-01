//
//  MessageTextOperationMock.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MessageTextOperationMock: MessageOperationMock {
    let text: String
    private var disposable: Disposable?
    init(text: String, localId: Int, remoteIdBefore: MessageId) {
        self.text = text
        super.init(localId: localId, remoteIdBefore: remoteIdBefore)
    }
    
    override func main() {        
        disposable = Single.just(String(localId)).delay(.seconds(1), scheduler: MainScheduler.instance).subscribe {[weak self] (event) in
            guard let self = self else { return }
            switch event {
            case .success(let value):
                self.remoteId = value
            case .error(let error):
                self.error = error
            }
            self.state = .isFinished
        }
        disposable?.disposed(by: rx.disposeBag)
    }
    
    override func cancel() {
        disposable?.dispose()
    }
}
