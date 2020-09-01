//
//  MessageCell.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/30/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import RxSwift
import RxCocoa
import RoundedUI

protocol MessageCellDelegate: NSObjectProtocol {
    func messageCellDidClicked(_ messageCell: MessageCell)
}

class MessageCell: ChatCell {
    public weak var delegate : MessageCellDelegate?
    private var disposables: [Disposable] = []

    override var viewModel: ChatItemCellViewModel? {
        willSet {
            unbindFromViewModel()
        }
        
        didSet {
            if viewModel != nil && (viewModel is MessageCellViewModel) == false {
                fatalError("Wrong viewModel type! Current is:\(String(describing: type(of: viewModel))). Must be: MessageCellViewModel")
            }
            
            let viewModel = self.viewModel as? MessageCellViewModel
            displayWithViewModel(viewModel)
            bindToViewModel()
        }
    }
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var background: MessageBackgroundView?
    @IBOutlet weak var leftConstraintBackground: NSLayoutConstraint?
    @IBOutlet weak var cellContentView: UIView!
    
    private func displayWithViewModel(_ viewModel: MessageCellViewModel?) {
        avatarImageView.image = nil
        if let unwrapped = viewModel?.sender.avatar {
            avatarImageView.sd_setImage(with: URL(string: unwrapped))
        } else {
            avatarImageView.image = nil
        }
        
        let isMyMessage: Bool = viewModel?.isMyMessage ?? false
        
        if isMyMessage {
            contentView.layer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
            background?.backgroundColor = UIColor(red: 71/255, green: 213/255, blue: 255/255, alpha: 1)
        } else {
            contentView.layer.setAffineTransform(CGAffineTransform.identity)
            background?.backgroundColor = UIColor(red: 242/255, green: 243/255, blue: 244/255, alpha: 1)
        }
        
        background?.roundedCornerRadius = 16
        background?.unroundedCornerRadius = 6

        let blockPosition = viewModel?.blockPosition.value ?? .top
        displayBlockPosition(blockPosition, isMyMessage)
                
        leftConstraintBackground?.constant = (isMyMessage == true) ? 16 : 56
    }
    
    private func displayBlockPosition(_ blockPosition: MessageBlockPosition, _ isMyMessage: Bool) {
        if isMyMessage == true {
            avatarImageView.superview?.isHidden = isMyMessage
        } else {
            avatarImageView.superview?.isHidden = (blockPosition != .top)
        }

        switch blockPosition {
        case .top:
            background?.corners = [.topLeft, .topRight, .bottomRight]
        case .middle:
            background?.corners = [.topRight, .bottomRight]
        case .bottom:
            background?.corners = [.topRight, .bottomRight, .bottomLeft]
        }
    }
    
    private func bindToViewModel() {
        guard let viewModel = self.viewModel as? MessageCellViewModel else { return }
        
        do {
            let disposable = viewModel.blockPosition
                .observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (blockPosition) in
                    guard let self = self else { return }
                    self.displayBlockPosition(blockPosition ?? .top, viewModel.isMyMessage)
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        let gesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchCellContent(sender:)))
        cellContentView.addGestureRecognizer(gesture)
        gesture.delegate = self
    }

    @objc private func touchCellContent(sender: Any?) {
        self.delegate?.messageCellDidClicked(self)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
