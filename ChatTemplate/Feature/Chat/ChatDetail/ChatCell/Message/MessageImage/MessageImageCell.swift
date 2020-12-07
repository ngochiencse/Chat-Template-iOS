//
//  MessageImageCell.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/30/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MessageImageCell: MessageCell {
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var heightImageView: NSLayoutConstraint!
    @IBOutlet weak var widthImageView: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    private var disposables: [Disposable] = []
    
    override var viewModel: ChatItemCellViewModel? {
        willSet {
            unbindFromViewModel()
        }
        
        didSet {
            if viewModel != nil && (viewModel is MessageImageCellViewModel) == false {
                fatalError("Wrong viewModel type! Current is:\(String(describing: type(of: viewModel))). Must be: MessageImageCellViewModel")
            }

            refreshDisplay()
            bindToViewModel()
        }
    }

    private func bindToViewModel() {
        guard let viewModel = self.viewModel as? MessageImageCellViewModel else { return }
        do {
            let disposable = Observable.combineLatest(viewModel.uploadingImage.asObservable(), viewModel.imageUrl.asObservable())
                .observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (values) in
                    guard let self = self else { return }
                    self.refreshDisplay()
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }
        
        do {
            let disposable = viewModel.displaySide.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (displaySide) in
                guard let self = self else { return }
                
                self.indicatorView.transform = displaySide == .right ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform.identity
                self.messageImage.transform = displaySide == .right ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform.identity
            })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }
    }
    
    private func refreshDisplay() {
        guard let viewModel = viewModel as? MessageImageCellViewModel else { return }
        let image: UIImage? = viewModel.uploadingImage.value
        let imageUrlString: String? = viewModel.imageUrl.value

        if let urlStringUnwrapped = imageUrlString, let url: URL = URL(string: urlStringUnwrapped) {
            self.messageImage.sd_setImage(with: url, placeholderImage: viewModel.uploadingImage.value)
            let originImageSize: CGSize = viewModel.imageSize ?? .zero
            let displaySize: CGSize = calculateImageSizeForChat(width: originImageSize.width, height:originImageSize.height)
            self.heightImageView.constant = displaySize.height
            self.widthImageView.constant = displaySize.width
            self.blurView.isHidden = true
            self.indicatorView.stopAnimating()
            self.indicatorView.isHidden = true
        } else {
            self.messageImage.sd_cancelCurrentImageLoad()
            let originImageSize: CGSize = image?.size ?? .zero
            let displaySize: CGSize = calculateImageSizeForChat(width: originImageSize.width, height: originImageSize.height)
            self.heightImageView.constant = displaySize.height
            self.widthImageView.constant = displaySize.width
            self.messageImage.image = image
            self.blurView.isHidden = false
            self.indicatorView.startAnimating()
            self.indicatorView.isHidden = false
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func calculateImageSizeForChat(width: CGFloat, height: CGFloat) -> CGSize{
        if width >= height {
            let newWidth: CGFloat = UIScreen.main.bounds.width * 2 / 3
            let ratio: CGFloat = max(CGFloat(height) / CGFloat(width), 0.25)
            let newHeight = newWidth * ratio
            return CGSize(width: newWidth, height: newHeight)
        } else {
            let newHeight: CGFloat = UIScreen.main.bounds.height / 3
            let ratio: CGFloat = min(CGFloat(width) / CGFloat(height), 4)
            let newWidth: CGFloat = newHeight * ratio
            return CGSize(width: newWidth, height: newHeight)
        }
    }
}
