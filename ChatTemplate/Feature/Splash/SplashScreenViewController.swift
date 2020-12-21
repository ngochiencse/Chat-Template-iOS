//
//  SplashScreenViewController.swift
//  ios_template_project
//
//  Created by Hien Pham on 8/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import UIKit
import RxSwift

protocol SplashScreenViewControllerDelegate: class {
    func splashScreenDidFinish(splashScreen: SplashScreenViewController)
}

class SplashScreenViewController: BaseViewController {
    weak var delegate: SplashScreenViewControllerDelegate?
    private(set) var viewModel: SplashScreenViewModel

    init(viewModel: SplashScreenViewModel = SplashScreenViewModelImpl()) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindToViewModel()
    }

    func bindToViewModel() {
        viewModel.onFinish.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            self.delegate?.splashScreenDidFinish(splashScreen: self)
        }).disposed(by: rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.checkLocalData()
    }
}
