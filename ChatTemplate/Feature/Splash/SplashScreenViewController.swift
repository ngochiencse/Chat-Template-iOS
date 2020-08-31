//
//  SplashScreenViewController.swift
//  ios_template_project
//
//  Created by Hien Pham on 8/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import UIKit

class SplashScreenViewController: BaseViewController {
    private(set) var viewModel: SplashScreenViewModel
    
    init(viewModel: SplashScreenViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.checkLocalData()
    }
}
