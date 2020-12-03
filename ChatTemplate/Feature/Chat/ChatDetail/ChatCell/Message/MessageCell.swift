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
            bindToViewModel()
        }
    }
    
    @IBOutlet weak var senderAvatar: AvatarImageView!
    @IBOutlet weak var background: CustomUIView?
    @IBOutlet weak var leftConstraintBackground: NSLayoutConstraint?
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var createdTimeLabel: UILabel!

    private func bindToViewModel() {
        guard let viewModel = self.viewModel as? MessageCellViewModel else { return }
        
        senderAvatar.viewModel = viewModel.senderAvatar

        do {
            let disposable = viewModel.roundCorners.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (roundCorners) in
                guard let self = self else { return }
                let topLeft: CGFloat = (roundCorners.contains(.topLeft) == true) ? 16 : 6
                let topRight: CGFloat = (roundCorners.contains(.topRight) == true) ? 16 : 6
                let bottomLeft: CGFloat = (roundCorners.contains(.bottomLeft) == true) ? 16 : 6
                let bottomRight: CGFloat = (roundCorners.contains(.bottomRight) == true) ? 16 : 6
                DispatchQueue.main.async {
                    self.background?.roundCorners(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
                }
            })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }
        
        do {
            if let leftConstraintBackground = leftConstraintBackground {
                let disposable = Observable.combineLatest(viewModel.isSenderAvatarSpaceHidden.asObservable(), viewModel.displaySide.asObservable())
                    .map { (values) -> CGFloat in
                        let (isSenderAvatarSpaceHidden, displaySide) = values
                        if displaySide == .left {
                            return (isSenderAvatarSpaceHidden == true) ? 24 : 56
                        } else {
                            return 24
                        }
                    }.bind(to: leftConstraintBackground.rx.constant)
                disposable.disposed(by: rx.disposeBag)
                disposables.append(disposable)
            }
        }

        do {
            if let avatarContainer = senderAvatar.superview {
                let disposable = viewModel.isSenderAvatarImageHidden.bind(to: avatarContainer.rx.isHidden)
                disposable.disposed(by: rx.disposeBag)
                disposables.append(disposable)
            }
        }
        
        createdTimeLabel.text = viewModel.createdAtStr

        do {
            let disposable = viewModel.displaySide.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (displaySide) in
                guard let self = self else { return }
                if displaySide == .right {
                    self.contentView.layer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
                    self.background?.backgroundColor = .white
                    self.background?.colorBorder = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
                    self.background?.widthBorder = 1
                    self.background?.setNeedsDisplay()
                    self.createdTimeLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
                } else {
                    self.contentView.layer.setAffineTransform(CGAffineTransform.identity)
                    self.background?.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
                    self.background?.colorBorder = nil
                    self.background?.widthBorder = nil
                    self.background?.setNeedsDisplay()
                    self.createdTimeLabel.transform = CGAffineTransform.identity
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
