//
//  AvatarImageViewModelImpl.swift
//  Koibana
//
//  Created by Hien Pham on 10/9/20.
//  Copyright © 2020 Koibana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AvatarImageViewModelImpl: NSObject, AvatarImageViewModel {
    let avatarUrlStr: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let defaultImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    var onTapImageView: PublishSubject<Void> = PublishSubject()
    func didTapOnImageView() {
        onTapImageView.onNext(())
    }
}
