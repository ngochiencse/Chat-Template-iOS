//
//  MessageCell.swift
//  ChatTemplate
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
    public weak var delegate: MessageCellDelegate?
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
    @IBOutlet weak var btnHeart: UIButton!

    private func bindToViewModel() {
        guard let viewModel = self.viewModel as? MessageCellViewModel else { return }

        senderAvatar.viewModel = viewModel.senderAvatar

        do {
            displayRoundCorners(viewModel.roundCorners.value)

            let disposable = viewModel.roundCorners.skip(1).observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] (roundCorners) in
                    guard let self = self else { return }
                    self.displayRoundCorners(roundCorners)
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }

        do {
            displayLeftConstraintBackground(viewModel.isSenderAvatarSpaceHidden.value,
                                            viewModel.displaySide.value)

            let disposable = Observable.combineLatest(viewModel.isSenderAvatarSpaceHidden.asObservable(),
                                                      viewModel.displaySide.asObservable())
                .skip(1)
                .subscribe(onNext: {[weak self] (_) in
                    guard let self = self else { return }
                    self.displayLeftConstraintBackground(viewModel.isSenderAvatarSpaceHidden.value,
                                                         viewModel.displaySide.value)
                }, onError: nil, onCompleted: nil, onDisposed: nil)

            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }

        do {
            displaySenderAvatarImageHidden(viewModel.isSenderAvatarImageHidden.value)

            let disposable = viewModel.isSenderAvatarImageHidden
                .skip(1)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] (isSenderAvatarImageHidden) in
                    guard let self = self else { return }
                    self.displaySenderAvatarImageHidden(isSenderAvatarImageHidden)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }

        createdTimeLabel.text = viewModel.createdAtStr

        do {

            displayMessageSide(viewModel.displaySide.value)

            let disposable = viewModel.displaySide.skip(1)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] (displaySide) in
                    guard let self = self else { return }
                    self.displayMessageSide(displaySide)
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }

        do {
            displayButtonLikeImage(viewModel.isLike.value)

            let disposable = viewModel.isLike.skip(1)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] (isLike) in
                    guard let self = self else { return }
                    self.displayButtonLikeImage(isLike)
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }

        do {
            displayButtonLikeHidden(viewModel.isButtonLikeHidden.value)

            let disposable = viewModel.isButtonLikeHidden
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] (isButtonLikeHidden) in
                    guard let self = self else { return }
                    self.displayButtonLikeHidden(isButtonLikeHidden)
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }
    }

    private func displayRoundCorners(_ roundCorners: UIRectCorner) {
        let topLeft: CGFloat = (roundCorners.contains(.topLeft) == true) ? 16 : 6
        let topRight: CGFloat = (roundCorners.contains(.topRight) == true) ? 16 : 6
        let bottomLeft: CGFloat = (roundCorners.contains(.bottomLeft) == true) ? 16 : 6
        let bottomRight: CGFloat = (roundCorners.contains(.bottomRight) == true) ? 16 : 6
        self.background?.topLeft = topLeft
        self.background?.topRight = topRight
        self.background?.bottomLeft = bottomLeft
        self.background?.bottomRight = bottomRight
        self.background?.refreshDisplayRoundCorners()
    }

    private func displayLeftConstraintBackground(_ isSenderAvatarSpaceHidden: Bool, _ displaySide: MessageDisplaySide) {
        let constant: CGFloat
        if displaySide == .left {
            constant = (isSenderAvatarSpaceHidden == true) ? 24 : 56
        } else {
            constant = 24
        }
        leftConstraintBackground?.constant = constant
    }

    private func displaySenderAvatarImageHidden(_ isSenderAvatarImageHidden: Bool) {
        senderAvatar.superview?.isHidden = isSenderAvatarImageHidden
    }

    private func displayMessageSide(_ displaySide: MessageDisplaySide) {
        if displaySide == .right {
            self.contentView.layer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
            self.background?.backgroundColor = .white
            self.background?.colorBorder = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
            self.background?.widthBorder = 1
            self.background?.setNeedsDisplay()
            self.createdTimeLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.contentView.layer.setAffineTransform(CGAffineTransform.identity)
            self.background?.backgroundColor = UIColor(red: 243/255,
                                                       green: 243/255,
                                                       blue: 243/255,
                                                       alpha: 1)
            self.background?.colorBorder = nil
            self.background?.widthBorder = nil
            self.background?.setNeedsDisplay()
            self.createdTimeLabel.transform = CGAffineTransform.identity
        }
    }

    private func displayButtonLikeImage(_ isLike: Bool) {
        let imageName: String = (isLike == true) ? "icon16HeartSolidColoured" : "heart"
        let image: UIImage? = UIImage(named: imageName)
        btnHeart.setImage(image, for: .normal)
    }

    private func displayButtonLikeHidden(_ isButtonLikeHidden: Bool) {
        btnHeart.isHidden = isButtonLikeHidden
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
        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                     action: #selector(touchCellContent(sender:)))
        cellContentView.addGestureRecognizer(gesture)
        gesture.delegate = self

        btnHeart.addTarget(self, action: #selector(actionHeart(_:)), for: .touchUpInside)
    }

    @IBAction func actionHeart(_ sender: Any) {
        if let viewModel = self.viewModel as? MessageCellViewModel {
            viewModel.toggleLike()
        }
    }

    @objc private func touchCellContent(sender: Any?) {
        self.delegate?.messageCellDidClicked(self)
    }

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldRecognizeSimultaneouslyWith
                                        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
