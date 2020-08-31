//
//  LoginViewController.swift
//  ios_template_project
//
//  Created by Hien Pham on 8/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import RxSwift
import NSObject_Rx
import RxBiBinding

protocol LoginViewControllerDelegate: class {
    func loginViewControllerDidFinish(_ loginViewController: LoginViewController)
}

class LoginViewController: BaseViewController {
    weak var delegate: LoginViewControllerDelegate?
    var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel = LoginViewModelImpl()) {
        self.viewModel = viewModel
        super.init(basicViewModel: viewModel.basicViewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // Outlet for controlling layout
    @IBOutlet weak var usernameTopSpaceConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bindToViewModel()
        
        self.navigationItem.hidesBackButton = true
        let screenHeight: CGFloat = UIScreen.main.bounds.size.height
        if screenHeight <= 568 {
            self.usernameTopSpaceConstraint.constant = 40
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    private func bindToViewModel() {
        (self.textFieldEmail.rx.text <-> viewModel.email).disposed(by: rx.disposeBag)
        (self.textFieldPassword.rx.text <-> viewModel.password).disposed(by: rx.disposeBag)
        viewModel.loginFinish.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            NotificationCenter.default.post(name: .LoginSuccess, object: nil)
            self.delegate?.loginViewControllerDidFinish(self)
        }).disposed(by: rx.disposeBag)
    }
        
    @IBAction func tapButtonLogin(_ sender: Any) {
        viewModel.login()
    }
}
