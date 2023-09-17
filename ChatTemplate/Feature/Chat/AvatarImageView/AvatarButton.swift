//
//  AvatarButton.swift
//  Koibana
//
//  Created by Hien Pham on 10/9/20.
//  Copyright © 2020 Koibana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import RoundedUI

class AvatarButton: RoundedButton {
    var viewModel: AvatarImageViewModel? {
        willSet {
            unbindFromViewModel()
        }
        didSet {
            bindToViewModel()
        }
    }
    var disposables: [Disposable] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    func setUp() {
        imageView?.contentMode = .scaleAspectFill
    }

    func bindToViewModel() {
        guard let viewModel = viewModel else { return }
        do {
            let disposable = Observable
                .combineLatest(viewModel.avatarUrlStr.asObservable(), viewModel.defaultImage.asObservable())
                .subscribe(onNext: {[weak self] (values) in
                    guard let self = self else { return }
                    let (avatarUrlStr, defaultImage) = values
                    if let avatarUrlStr = avatarUrlStr, let url = URL(string: avatarUrlStr) {
                        self.sd_setImage(with: url, for: .normal)
                    } else {
                        self.sd_cancelCurrentImageLoad()
                        self.setImage(defaultImage, for: .normal)
                    }
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }
    }

    func unbindFromViewModel() {
        disposables.forEach { (ele) in
            ele.dispose()
        }
        disposables.removeAll()
    }
}
