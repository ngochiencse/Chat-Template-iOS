//
//  APIProvider.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/16/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire

/**
 Base class for api provider. Do not use this class directly but has to through subclass.
 */
class Provider<Target> where Target: Moya.TargetType {
    func request(_ token: Target) -> Single<Moya.Response> {
        fatalError("This class is used directly which is forbidden")
    }
}

extension Single where Element: Moya.Response {
    func handleCommonError(_ error: Error, autoHandleNoInternetConnection: Bool, autoHandleAPIError: Bool, autoHandleAccountSuspendedStop: Bool) -> Single<Element> {
        guard case MoyaError.underlying(let underlyingError, _) = error else {
            return Single<Element>.error(error)
        }
        // Handle no internet connection automatically if needed
        if case AFError.sessionTaskFailed(error: let sessionError) = underlyingError,
            let urlError = sessionError as? URLError,
            urlError.code == URLError.Code.notConnectedToInternet ||
            urlError.code == URLError.Code.timedOut {
            if autoHandleNoInternetConnection == true {
                NotificationCenter.default.post(name: .AutoHandleNoInternetConnectionError, object: error)
                return Single<Element>.error(APIError.ignore(error))
            } else {
                return Single<Element>.error(error)
            }
        }
        else if autoHandleAccountSuspendedStop == true,
            case APIError.serverError(let detail) = underlyingError,
            ["403006","403001"].contains(detail.code) {
                NotificationCenter.default.post(name: .AccountSuspendedStop, object: error)
                return Single<Element>.error(APIError.ignore(error))
        }
        // Handle api error automatically if needed
        else if autoHandleAPIError == true {
            NotificationCenter.default.post(name: .AutoHandleAPIError, object: error)
            return Single<Element>.error(APIError.ignore(error))
        } else {
            return Single<Element>.error(error)
        }
    }
    
    func catchCommonError(autoHandleNoInternetConnection: Bool, autoHandleAPIError: Bool, autoHandleAccountSuspendedStop: Bool) -> PrimitiveSequence<Trait, Element> {
        return catchError {(error) in
            let catched = self.handleCommonError(error, autoHandleNoInternetConnection: autoHandleNoInternetConnection, autoHandleAPIError: autoHandleAPIError, autoHandleAccountSuspendedStop: autoHandleAccountSuspendedStop) as! PrimitiveSequence<Trait, Element>
            return catched
        }
    }
}
