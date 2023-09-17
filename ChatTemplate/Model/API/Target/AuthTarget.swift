//
//  AuthTarget.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/13/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Moya

enum LoginService: Int {
    case mailAndPassword = 0
    case apple = 1
    case line = 3
}

// Correspond to Auth Section in api doc
enum AuthTarget {
    // メールアドレスでユーザ作成
    case createUserWithEmail(authCode: String, mailAddress: String?, password: String?)
    // その他のサービスを使用してユーザ作成
    case createUserWithOtherServices(service: LoginService, token: String)
    // 認証コードを送信
    case sendAuthCode(mailAddress: String)
    // 認証コード送信(メール登録等用)
    case sendAuthCodeForMailRegister(mailAddress: String)
    // 認証コードの確認
    case confirmAuthCode(mailAddress: String, authCode: String)
    // パスワードの変更
    case changePassword(newPassword: String, mailAddress: String, authCode: String)
    // ログインの実行
    case login(mailAddress: String?, password: String?, service: LoginService, token: String?)
    // リフレッシュトークン
    case refreshToken(refreshToken: String?)
}

// MARK: - TargetType Protocol Implementation
extension AuthTarget: TargetType {
    var baseURL: URL {
        let host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        let baseURL: URL = URL(string: host + path)!
        return baseURL
    }

    var path: String {
        switch self {
        case .createUserWithEmail:
            return "sign-up-with-mail"
        case .createUserWithOtherServices:
            return "sign-up-with-another-service"
        case .sendAuthCode:
            return "post-auth-code"
        case .sendAuthCodeForMailRegister:
            return "post-auth-code-for-mail-register"
        case .confirmAuthCode:
            return "verify-auth-code"
        case .changePassword:
            return "change-password"
        case .login:
            return "login"
        case .refreshToken:
            return "refresh-token"
        }
    }

    var method: Moya.Method {
        return .post
    }

    var task: Task {
        switch self {
        case .createUserWithEmail(authCode: let authCode, mailAddress: let mailAddress, password: let password):
            var parameters: [String: Any] = [:]
            parameters["auth_code"] = authCode
            if let mailAddress = mailAddress {
                parameters["mail_address"] = mailAddress
            }
            if let password = password {
                parameters["password"] = password
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .createUserWithOtherServices(service: let service, token: let token):
            return .requestParameters(parameters: [
                                        "authorization_service": service.rawValue,
                                        "token": token], encoding: JSONEncoding.default)
        case .sendAuthCode(mailAddress: let mailAddress):
            return .requestParameters(parameters: [
                "mail_address": mailAddress
            ], encoding: JSONEncoding.default)
        case .sendAuthCodeForMailRegister(mailAddress: let mailAddress):
            return .requestParameters(parameters: [
                "mail_address": mailAddress
            ], encoding: JSONEncoding.default)
        case .confirmAuthCode(mailAddress: let mailAddress, authCode: let authCode):
            return .requestParameters(parameters: [
                "mail_address": mailAddress,
                "auth_code": authCode
            ], encoding: JSONEncoding.default)
        case .changePassword(newPassword: let newPassword,
                             mailAddress: let mailAddress,
                             authCode: let authCode):
            return .requestParameters(parameters: [
                "new_password": newPassword,
                "mail_address": mailAddress,
                "auth_code": authCode
            ], encoding: JSONEncoding.default)
        case .login(mailAddress: let mailAddress,
                    password: let password,
                    service: let service,
                    token: let token):
            var parameters: [String: Any] = [:]
            if let mailAddress = mailAddress {
                parameters["mail_address"] = mailAddress
            }
            if let password = password {
                parameters["password"] = password
            }
            parameters["authorization_service"] = service.rawValue
            if let token = token {
                parameters["token"] = token
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .refreshToken(refreshToken: let refreshToken):
            var parameters: [String: Any] = [:]
            if let refreshToken = refreshToken {
                parameters["refresh_token"] = refreshToken
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }

    var sampleData: Data {
        switch self {
        case .createUserWithEmail:
            return
                """
            {
              "token": {
                "access_token": "access_token_example",
                "refresh_token": "refresh_token_example"
              },
              "me": {
                "id": 1,
                "icon_url": "https://example.com/default_icon.png",
                "nickname": null,
                "description": null,
                "web_site": null,
                "birth_day": null,
                "apay": 0,
                "follower_count": 0,
                "followee_count": 0,
                "amazing": 0
              }
            }
            """.utf8Encoded
        case .createUserWithOtherServices:
            return
                """
            {
              "token": {
                "access_token": "access_token_example",
                "refresh_token": "refresh_token_example"
              },
              "me": {
                "id": 1,
                "icon_url": "https://example.com/default_icon.png",
                "nickname": null,
                "description": null,
                "web_site": null,
                "birth_day": null,
                "apay": 0,
                "follower_count": 0,
                "followee_count": 0,
                "amazing": 0
              }
            }
            """.utf8Encoded
        case .sendAuthCode, .sendAuthCodeForMailRegister, .confirmAuthCode, .changePassword, .login:
            return "".utf8Encoded
        case .refreshToken:
            return
                """
            {
              "token": {
                "access_token": "access_token_example",
                "refresh_token": "refresh_token_example"
              }
            }
            """.utf8Encoded
        }
    }

    private func dataFromResource(name: String) -> Data {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil),
              let data = try? Data(contentsOf: url) else {
            return Data()
        }
        return data
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
