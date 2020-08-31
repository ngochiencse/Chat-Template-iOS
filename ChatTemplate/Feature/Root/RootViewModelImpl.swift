//
//  AppViewModel.swift
//  ios_template_project
//
//  Created by Hien Pham on 10/26/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RootViewModelImpl: RootViewModel {    
    var alertModel: BehaviorRelay<AlertModel?> = BehaviorRelay(value: nil)
    let onAccessTokenExpiredDismiss: PublishSubject<Void> = PublishSubject()
    let prefs: PrefsUserInfo & PrefsAccessToken
    var isAccessTokenExpired: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    init(prefs: PrefsUserInfo & PrefsAccessToken) {
        self.prefs = prefs
        setUpObserver()
    }
    
    func clearLocalData() {
        prefs.saveUserInfo(nil)
        prefs.saveAccessToken(nil)
    }
    
    func setUpObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccessTokenExpired), name: .AutoHandleAccessTokenExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAPIError(_:)), name: .AutoHandleAPIError, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleAccessTokenExpired() {
        isAccessTokenExpired.accept(true)
    }
    
    @objc func handleAPIError(_ notification: Notification) {
        if let error: Error = notification.object as? Error {
            alertModel.accept(AlertModel(message: error.localizedDescription))
        }
    }
    
    deinit {
        removeObserver()
    }
}
