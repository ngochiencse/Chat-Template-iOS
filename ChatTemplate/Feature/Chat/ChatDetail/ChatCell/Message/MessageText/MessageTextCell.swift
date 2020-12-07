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
                fatalError("Wrong viewModel type! Current is:\(String(describing: type(of: viewModel))). Must be: MessageTextCellViewModel")
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
            let disposable = viewModel.displaySide.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (displaySide) in
                guard let self = self else { return }
                
                if displaySide == .right {
                    self.tvContent.transform = CGAffineTransform(scaleX: -1, y: 1)
                } else {
                    self.tvContent.transform = CGAffineTransform.identity
                }
            })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }
    }

    private func unbindFromViewModel() {
        disposables.forEach { (ele) in
            ele.dispose()
        }
        disposables.removeAll()
    }

    private func refreshString(string: String, lineSpacing: CGFloat) -> NSAttributedString {
        let paragraphStyle : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineSpacing = lineSpacing
        let attrsDictionary : [NSAttributedString.Key: Any] = [.font : self.tvContent.font ?? UIFont.systemFont(ofSize: 14),
                                                                        .paragraphStyle : paragraphStyle,
                                                                        .foregroundColor : UIColor.black]
    
        let myString : NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: attrsDictionary)
        return myString
    }
}
