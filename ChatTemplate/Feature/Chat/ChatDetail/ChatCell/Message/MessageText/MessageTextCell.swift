//
//  ChatTextCell.swift
//  Tavi
//
//  Created by Hien Pham on 12/15/17.
//  Copyright © 2017 Bravesoft VN. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MessageTextCell: MessageCell {
    @IBOutlet weak var tvContent: UITextView!

    override var viewModel: ChatItemCellViewModel? {
        willSet {
            unbindFromViewModel()
        }

        didSet {
            if viewModel != nil && (viewModel is MessageTextCellViewModel) == false {
                fatalError("Wrong viewModel type! Current is:" +
                            String(describing: type(of: viewModel)) +
                            ". Must be: MessageTextCellViewModel")
            }

            let viewModel = self.viewModel as? MessageTextCellViewModel
            displayWithViewModel(viewModel)
            bindToViewModel()
        }
    }
    private var disposables: [Disposable] = []

    private func displayWithViewModel(_ viewModel: MessageTextCellViewModel?) {
        self.tvContent.attributedText = viewModel?.attributedText
    }

    private func bindToViewModel() {
        guard let viewModel = self.viewModel as? MessageCellViewModel else { return }

        do {
            self.displayMessageSide(viewModel.displaySide.value)

            let disposable = viewModel.displaySide
                .skip(1).observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] (displaySide) in
                    guard let self = self else { return }

                    self.displayMessageSide(displaySide)
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }
    }

    private func displayMessageSide(_ displaySide: MessageDisplaySide) {
        if displaySide == .right {
            self.tvContent.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.tvContent.transform = CGAffineTransform.identity
        }
    }

    private func unbindFromViewModel() {
        disposables.forEach { (ele) in
            ele.dispose()
        }
        disposables.removeAll()
    }
}
