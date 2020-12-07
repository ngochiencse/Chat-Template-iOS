//
//  ChatDetailViewPhotoViewController.swift
//  ChatTemplate
//
//  Created by Cong Nguyen on 5/21/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage
import Toast_Swift

class ChatDetailViewPhotoViewController: BaseViewController {
    @IBOutlet weak var scv: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    let viewModel: ChatDetailViewPhotoViewModel
    
    init(viewModel: ChatDetailViewPhotoViewModel) {
        self.viewModel = viewModel
        super.init(basicViewModel: viewModel.basicViewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scv.delegate = self
        scv.minimumZoomScale = 1.0
        scv.maximumZoomScale = 10.0
        bindData()
        
        imageView.sd_setImage(with: URL(string: viewModel.urlString),
                              placeholderImage: nil,
                              options: SDWebImageOptions.retryFailed,
                              completed: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func bindData() {
        self.viewModel.showToast.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] message in
            guard let self = self else { return }
            self.view.makeToast(message)
        }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionDownload(_ sender: Any) {
        self.viewModel.downloadImage()
    }
}

extension ChatDetailViewPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
