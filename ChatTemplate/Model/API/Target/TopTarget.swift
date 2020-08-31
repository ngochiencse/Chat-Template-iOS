//
//  TopTarget.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/13/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Moya

// Correspond to Top Section in api doc
enum TopTarget {
    // アプリトップ画面用エンドポイント
    case top
    // 起動時ポップアップを取得
    case getStartupPopup
    // 起動時ポップアップのリンククリックのイベントを送信
    case sendClickOnStartupPopup(startUpPopupId: String)
    // 未読のボーナスの取得
    case getUnreadBonus(limit: Int?, fromBonusId: Int?)
    // 認証コードの確認
    case sendBonusRead(bonusIDs: [Int])
    // ボーナス既読の送信
    case registerPushToken(token: String)
    // プッシュトークンの登録
    case deleletePushToken(token: String)
}

// MARK: - TargetType Protocol Implementation
extension TopTarget: TargetType {
    var baseURL: URL {
        let host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        let baseURL: URL = URL(string: host + path)!
        return baseURL
    }
    
    var path: String {
        switch self {
        case .top:
            return "top"
        case .getStartupPopup:
            return "start-up-popups"
        case .sendClickOnStartupPopup(startUpPopupId: let startUpPopupId):
            return "start-up-popups/\(startUpPopupId)/click-histories"
        case .getUnreadBonus:
            return "users/me/unread-bonuses"
        case .sendBonusRead:
            return "users/me/bonus-read-histories"
        case .registerPushToken(token: let token), .deleletePushToken(token: let token):
            return "users/me/push-tokens/\(token)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .top:
            return .get
        case .getStartupPopup:
            return .get
        case .sendClickOnStartupPopup:
            return .post
        case .getUnreadBonus:
            return .get
        case .sendBonusRead:
            return .post
        case .registerPushToken:
            return .put
        case .deleletePushToken:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .top:
            return .requestPlain
        case .getStartupPopup:
            return .requestPlain
        case .sendClickOnStartupPopup:
            return .requestPlain
        case .getUnreadBonus(limit: let limit, fromBonusId: let fromBonusId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromBonusId = fromBonusId {
                parameters["from_bonus_id"] = fromBonusId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .sendBonusRead(bonusIDs: let bonusIDs):
            return .requestParameters(parameters: ["bonus_ids": bonusIDs], encoding: JSONEncoding.default)
        case .registerPushToken(token: let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
        case .deleletePushToken(token: let token):
            return .requestParameters(parameters: ["token": token], encoding: JSONEncoding.default)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .top:
            return dataFromResource(name: "api_top_sample_response.json")
        case .getStartupPopup:
            return
                """
            {
              "start_up_popup": {
              "id": 1,
              "image_url": "https://example.com/image.png",
              "content_text": "ポップアップテキストポップアップテキストポップアップテキスト ポップアップテキストポップアップテキストポップアップテキスト ポップアップテキストポップアップテキストポップアップテキスト",
              "video_id": 0,
              "link_url": "https://example.com/"
              }
            }
            """.utf8Encoded
        case .sendClickOnStartupPopup:
            return "".utf8Encoded
        case .getUnreadBonus:
            return
                """
                    {
                      "bonuses": [
                        {
                          "id": 1,
                          "bonus_name": "XXXXXボーナス",
                          "point": 10
                        },
                        {
                          "id": 2,
                          "bonus_name": "ポップアップテキストポップアップテキストポップアップテキスト ポップアップテキストポップアップテキストポップアップテキスト ポップアップテキストポップアップテキストポップアップテキスト〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス",
                          "point": 20
                        },
                        {
                          "id": 3,
                          "bonus_name": "〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇ボーナス",
                          "point": 30
                        }
                      ]
                    }
                    """.utf8Encoded
        case .sendBonusRead:
            return "".utf8Encoded
        case .registerPushToken:
            return "".utf8Encoded
        case .deleletePushToken:
            return "".utf8Encoded
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

extension TopTarget: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
}
