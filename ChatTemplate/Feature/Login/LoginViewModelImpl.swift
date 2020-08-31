//
//  LoginViewModel.swift
//  ios_template_project
//
//  Created by Hien Pham on 9/20/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import RxSwift
import RxCocoa
import NSObject_Rx

class LoginViewModelImpl: NSObject, LoginViewModel {
    private(set) var basicViewModel: BasicViewModel
    var email: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var password: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let exitEditing: PublishSubject<Void> = PublishSubject()
    let prefs: PrefsAccessToken
    let api: Provider<MultiTarget>
    let loginFinish: PublishSubject<Void> = PublishSubject()
    
    init(basicViewModel: BasicViewModel = BasicViewModelImpl(), prefs: PrefsAccessToken = PrefsImpl.default, api: Provider<MultiTarget> = ProviderAPIBasic<MultiTarget>()) {
        self.basicViewModel = basicViewModel
        self.prefs = prefs
        self.api = api
        super.init()
    }
        
    func login() {
        let emailClean: String = email.value?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
        if emailClean.count <= 0 {
            basicViewModel.alertModel.accept(AlertModel(message: "ログインIDもしくはパスワードが異なっています。"))
            return
        }
        
        let passwordClean: String = password.value ?? ""
        if passwordClean.count <= 0 {
            basicViewModel.alertModel.accept(AlertModel(message: "ログインIDもしくはパスワードが異なっています。"))
            return
        }

        basicViewModel.showProgressHUD.accept(true)
        api.request(MultiTarget(SampleTarget.login(email: emailClean, password: passwordClean))).subscribe {[weak self] event in
            guard let self = self else { return }
            switch event {
            case .success(_):
                // TODO: replace with real access token value
                self.prefs.saveAccessToken("Sample Access Token")
                
                self.loginFinish.onNext(())
                break
            case .error(let error):
                if case MoyaError.underlying(APIError.ignore(_), _) = error {} else {
                    self.basicViewModel.alertModel.accept(AlertModel(message: error.localizedDescription))
                }
                break
            }
            self.basicViewModel.showProgressHUD.accept(false)
        }.disposed(by: rx.disposeBag)
    }
}
