//
//  APIProviderWithAuth.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/16/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import NSObject_Rx

extension Notification.Name {
    static let AutoHandleAPIError: Notification.Name = Notification.Name("AutoHandleAPIError")
    static let AutoHandleNoInternetConnectionError: Notification.Name =
        Notification.Name("AutoHandleNoInternetConnectionError")
    static let AutoHandleAccessTokenExpired: Notification.Name = Notification.Name("AutoHandleAccessTokenExpired")
    static let AccountSuspendedStop: Notification.Name = Notification.Name("AccountSuspendedStop")
}

/**
 Similiar to `ProviderAPIWithRefreshToken` but including refresh token flow
 */
class ProviderAPIWithRefreshToken<Target>: Provider<Target> where Target: Moya.TargetType {
    let provider: MoyaProvider<Target>
    let prefs: PrefsAccessToken & PrefsRefreshToken
    let tokenRefresher: TokenRefresher?
    let autoHandleAccessTokenExpired: Bool
    let autoHandleAPIError: Bool
    let autoHandleNoInternetConnection: Bool
    let autoHandleAccountSuspendedStop: Bool

    /**
     Init Provider, similiar to Moya.
     - Parameter prefs: Access token storage
     - Parameter autoHandleAccessTokenExpired: If `true` then errors which caused the app to auto logout will be handled automatically, and will be transformed into `APIError.ignore`
     - Parameter autoHandleAccountSuspendedStop: If `true` then errors which caused the app to auto logout will be handled automatically, and will be transformed into `APIError.ignore`
     - Parameter autoHandleAPIError: If `true` then any error thrown will be handled automatically, and will be transformed into `APIError.ignore`
     */
    init(prefs: PrefsAccessToken & PrefsRefreshToken = PrefsImpl.default,
         autoHandleAccountSuspendedStop: Bool = true,
         autoHandleAccessTokenExpired: Bool = true,
         autoHandleNoInternetConnection: Bool = true,
         autoHandleAPIError: Bool = true,
         tokenRefresher: TokenRefresher? = TokenRefresherImpl.shared,
         endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         session: Session = DefaultAlamofireManager.shared,
         plugins: [PluginType] = [],
         trackInflights: Bool = false) {
        self.prefs = prefs
        self.tokenRefresher = tokenRefresher
        self.autoHandleAccessTokenExpired = autoHandleAccessTokenExpired
        self.autoHandleAPIError = autoHandleAPIError
        self.autoHandleNoInternetConnection = autoHandleNoInternetConnection
        self.autoHandleAccountSuspendedStop = autoHandleAccountSuspendedStop

        // Set up plugins
        var mutablePlugins: [PluginType] = plugins
        let errorProcessPlugin: APIErrorProcessPlugin = APIErrorProcessPlugin()
        mutablePlugins.append(errorProcessPlugin)
        #if DEBUG
        mutablePlugins.append(
            NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
        )
        #endif
        let accessTokenPlugin: AccessTokenPlugin = AccessTokenPlugin { (_) -> String in
            return prefs.getAccessToken() ?? ""
        }
        mutablePlugins.append(accessTokenPlugin)

        provider = MoyaProvider(endpointClosure: endpointClosure,
                                requestClosure: requestClosure,
                                stubClosure: stubClosure,
                                session: session,
                                plugins: mutablePlugins,
                                trackInflights: trackInflights)
    }

    override func request(_ token: Target) -> Single<Moya.Response> {
        return request(token, currentAccessToken: prefs.getAccessToken(), refreshedAccessToken: nil)
    }

    private func request(_ token: Target, currentAccessToken: String?,
                         refreshedAccessToken: String?) -> Single<Moya.Response> {
        let request = provider.rx.request(token)
        return request
            .catchError({ (error) in
                if case MoyaError.underlying(let underlyingError, let response) = error,
                   case APIError.serverError(let detail) = underlyingError,
                   let unwrappedResponse = response {
                    let needRefreshToken: Bool = (detail.code == "401003")
                    guard
                        // Only refresh token if the error http status code and error code match with required case
                        needRefreshToken == true,
                        // Prevent refresh token after already refreshed
                        refreshedAccessToken == nil else {
                        return Single.error(error)
                    }

                    if let prefsAccessToken = self.prefs.getAccessToken(), prefsAccessToken != currentAccessToken {
                        return self.request(token,
                                            currentAccessToken: currentAccessToken,
                                            refreshedAccessToken: prefsAccessToken)
                    } else {
                        if let tokenRefresher = self.tokenRefresher, let refreshToken = self.prefs.getRefreshToken() {
                            return tokenRefresher.refreshAccessToken(refreshToken).do(onSuccess: { (newAccessToken) in
                                self.prefs.saveAccessToken(newAccessToken)
                            }).catchError({ (error) in
                                return Single.error(MoyaError.underlying(
                                                        APIError.refreshTokenFailed(error), unwrappedResponse))
                            }).flatMap { (newAccessToken) in
                                return self.request(token,
                                                    currentAccessToken: currentAccessToken,
                                                    refreshedAccessToken: newAccessToken)
                            }
                        } else {
                            return Single.error(MoyaError.underlying(
                                                    APIError.accessTokenExpired(error), unwrappedResponse))
                        }
                    }
                } else {
                    return Single.error(error)
                }
            })
            .catchError({ (error) in
                // Handle access token expired
                if case MoyaError.underlying(APIError.accessTokenExpired(_), _) = error,
                   self.autoHandleAccessTokenExpired == true {
                    NotificationCenter.default.post(name: .AutoHandleAccessTokenExpired, object: nil)
                    return Single.error(APIError.ignore(error))
                } else {
                    return Single.error(error)
                }
            })
            .catchError({ (error) in
                // Check if is refresh token expired
                let isRefreshTokenExpired: Bool
                if case MoyaError.underlying(let underlyingError, _) = error {
                    if case APIError.refreshTokenFailed(_) = underlyingError {
                        isRefreshTokenExpired = true
                    } else if let detail = underlyingError as? APIErrorDetail,
                              ["401002", "401003", "401004", "403001"].contains(detail.code) {
                        isRefreshTokenExpired = true
                    } else {
                        isRefreshTokenExpired = false
                    }
                } else {
                    isRefreshTokenExpired = false
                }

                // Handle access token expired automatically if required, fall to auto handle api error if not
                if isRefreshTokenExpired == true {
                    if self.autoHandleAccessTokenExpired {
                        NotificationCenter.default.post(name: .AutoHandleAccessTokenExpired, object: nil)
                        return Single.error(APIError.ignore(error))
                    } else {
                        return Single.error(error)
                    }
                } else {
                    return Single.error(error)
                }
            })
            .catchCommonError(autoHandleNoInternetConnection: autoHandleNoInternetConnection,
                              autoHandleAPIError: autoHandleAPIError,
                              autoHandleAccountSuspendedStop: autoHandleAccountSuspendedStop)
    }
}
