//
//  APIError.swift
//  ios_template_project
//
//  Created by Hien Pham on 4/7/20.
//  Copyright © 2020 BraveSoft Vietnam. All rights reserved.
//

import Foundation
/**
 Error when calling api
 */
enum APIError: Error {
    case ignore(_ error: Error)
    case accessTokenExpired(_ error: Error)
    case refreshTokenFailed(_ error: Error)
    case serverError(_ detail: APIErrorDetail)
    case parseError
    case systemError
}

struct APIErrorDetail: Error, Codable {
    let code: String
    let message: String?
    
    var localizedDescription: String {
        return message ?? ""
    }
}
