//
//  ChatDetailViewPhotoViewModelImpl.swift
//  WITHOUT_IOS
//
//  Created by Tai Ma on 7/3/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa

class ChatDetailViewPhotoViewModelImpl: NSObject , ChatDetailViewPhotoViewModel {
    let basicViewModel: BasicViewModel
    let showToast: PublishSubject<String> = PublishSubject()
    let urlString: String
    
    init(basicViewModel: BasicViewModel = BasicViewModelImpl(), urlString: String) {
        self.basicViewModel = basicViewModel
        self.urlString = urlString
        super.init()
    }
    
    func downloadImage() {
        self.basicViewModel.showProgressHUD.accept(true)
        SDWebImageManager.shared.loadImage(with: URL(string: urlString), options: .init(rawValue: 0), context: nil, progress: nil) {[weak self] (image, _, _, _, _, url) in
            guard let self = self else { return }
            if url?.absoluteString == self.urlString {
                if let image = image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                } else {
                    self.showToast.onNext("画像の保存に失敗しました。")
                }
                self.basicViewModel.showProgressHUD.accept(false)
            }
        }
    }


    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            showToast.onNext("画像の保存に失敗しました。")
        } else {
            showToast.onNext("画像が保存されました。")
        }
    }
}
