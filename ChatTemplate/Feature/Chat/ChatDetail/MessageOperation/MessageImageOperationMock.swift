//
//  MessageImageOperationMock.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MessageImageOperationMock: MessageOperationMock {
    let image: UIImage
    
    private(set) var remoteImageUrl: String?
    private(set) var remoteImageSize: CGSize?
    
    private var disposable: Disposable?
        
    init(image: UIImage, localId: Int, remoteIdBefore: MessageId) {
        self.image = image
        super.init(localId: localId, remoteIdBefore: remoteIdBefore)
    }
        
    override func main() {
        disposable = Single.just(String(localId)).delay(.seconds(1), scheduler: MainScheduler.instance).subscribe({[weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .success(let messageId):
                    self.remoteImageUrl = "https://hoidulich.net/wp-content/uploads/2019/11/71118571_400051820571391_381023500722296458_n-1067x800.jpg"
                    self.remoteId = messageId
                    self.remoteImageSize = self.image.size
                case .error(let error):
                    self.error = error
                }
                self.state = .isFinished
            })
        disposable?.disposed(by: rx.disposeBag)
    }
    
    override func cancel() {
        disposable?.dispose()
    }
}
