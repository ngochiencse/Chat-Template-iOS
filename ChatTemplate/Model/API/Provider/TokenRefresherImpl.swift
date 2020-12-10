//
//  TokenRefresherImpl.swift
//  ios_template_project
//
//  Created by Hien Pham on 3/10/20.
//  Copyright © 2020 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift
import Moya

class TokenRefresherImpl: TokenRefresher {
    let prefs: PrefsRefreshToken & PrefsAccessToken
    let tokenProvider: ProviderAPIBasic<AuthTarget>
    private var sharedObservable: Observable<String>?
    static let shared: TokenRefresherImpl = TokenRefresherImpl()

    init(prefs: PrefsRefreshToken & PrefsAccessToken = PrefsImpl.default,
         tokenProvider: ProviderAPIBasic<AuthTarget> =
            ProviderAPIBasic<AuthTarget>(autoHandleNoInternetConnection: false,
                                         autoHandleAPIError: false)) {
        self.prefs = prefs
        self.tokenProvider = tokenProvider
    }

    func refreshAccessToken(_ refreshToken: String) -> Single<String> {
        let observable: Observable<String>
        if let unwrapped = sharedObservable {
            observable = unwrapped
        } else {
            sharedObservable = tokenProvider.request(.refreshToken(refreshToken: refreshToken))
                .flatMap { (response) -> Single<Response> in
                    let accessToken = try response.filterSuccessfulStatusCodes()
                        .map(String.self,
                             atKeyPath: "token.access_token",
                             using: JSONDecoder.decoderISO8601DateAPI(),
                             failsOnEmptyData: false)
                    self.prefs.saveAccessToken(accessToken)

                    let refreshToken = try response.filterSuccessfulStatusCodes()
                        .map(String.self,
                             atKeyPath: "token.refresh_token",
                             using: JSONDecoder.decoderISO8601DateAPI(),
                             failsOnEmptyData: false)
                    self.prefs.saveRefreshToken(refreshToken)
                    return Single.just(response)
                }
                .mapString(atKeyPath: "token.access_token")
                .do(onSuccess: {[weak self] (_) in
                    self?.sharedObservable = nil
                }, onError: {[weak self] (_) in
                    self?.sharedObservable = nil
                })
                .asObservable().share(replay: 1, scope: .forever)

            observable = sharedObservable!
        }

        let single = Single<String>.create { (single) -> Disposable in
            let disposable = observable.subscribe(onNext: { (newAccessToken) in
                single(.success(newAccessToken))
            }, onError: { (error) in
                single(.error(error))
            })
            return Disposables.create {
                disposable.dispose()
            }
        }
        return single
    }
}
