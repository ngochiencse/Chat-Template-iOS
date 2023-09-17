//
//  SplashScreenViewModel.swift
//  ios_template_project
//
//  Created by Hien Pham on 9/20/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift

class SplashScreenViewModelImpl: SplashScreenViewModel {
    private var prefs: PrefsImpl
    let onFinish: PublishSubject<Void> = PublishSubject()
    init(prefs: PrefsImpl = .default) {
        self.prefs = prefs
    }
    func checkLocalData() {
        //        if prefs.getUserInfo()?.accessToken != nil {
        //            self.getUserInfo()
        //        } else {
        finish()
        //        }
    }

    fileprivate func finish() {
        onFinish.onNext(())
    }

    //    func getUserInfo() {
    //        let sv = GetUserInfoService()
    //        sv.progressHudContainer = nil
    //        sv.getUserInfo()
    //        sv.success = {(data : Any?) in
    //            if let userInfo = data as? UserInfo {
    //                if userInfo.status == .updateProfile {
    //                    self.finishWithNextAction(.homeScreen)
    //                } else {
    //                    self.finishWithNextAction(.updateProfileScreen)
    //                }
    //            } else {
    //                self.finishWithNextAction(.login1Screen)
    //            }
    //        }
    //        sv.logicError = {(logicError : Any?) in
    //            self.finishWithNextAction(.login1Screen)
    //        }
    //        sv.execute()
    //    }
}
