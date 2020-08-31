//
//  UserTarget.swift
//  MVVM_Template_Swift
//
//  Created by Hien Pham on 11/14/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Moya
import SwiftDate

enum UserTarget {
    // ユーザ検索
    case searchUser(limit: Int?, fromUserId: Int?, keyword: String?)
    // 自分の情報取得
    case getMyProfile
    // プロフィール編集
    case editProfile(icon: UIImage?, nickname: String, description: String?, website: String?, birthDay: Date?)
    // ユーザの情報取得
    case getUserInfo(userId: Int)
    // 自分の投稿動画取得
    case getMyPostedVideos(limit: Int?, fromVideoId: String?)
    // 動画削除
    case deleteVideo(videoId: String)
    // ユーザの投稿動画取得
    case getUserPostedVideos(userId: String, limit: Int?, fromVideoId: String?)
    // 自分のお気に入りにした動画取得
    case getMyFavoriteVideos(limit: Int?, fromVideoId: String?)
    // お気に入り動画登録
    case registerFavoriteVideo(videoId: String)
    // お気に入り動画解除
    case unFavoriteVideo(videoId: String)
    // ユーザのフォロー
    case followUser(userId: String)
    // フォロー解除
    case unfollowUser(userId: String)
    // ユーザのフォロー一覧取得
    case getUserFollowerList(userId: String, limit: Int?, fromUserId: Int?)
    // 自分のメールアドレス取得
    case getUserFollowList(userId: String, limit: Int?, fromUserId: Int?)
    // 自分のメールアドレス更新
    case getMyEmailAddress
    // パスワード変更
    case updateMyEmailAddress(mailAddress: String, authCode: String)
    // 通知取得
    case changePassword(oldPassword: String, newPassword: String)
    // お知らせの未読件数取得
    case getNotificationList(limit: Int?, fromNotificationId: Int?)
    // 自分のアメイジング取得
    case getNumberOfUnreadNotifications
    // 削除された音楽取得
    case getMyAmazing
    // ユーザの通報を送信
    case reportUser(userId: String)
    // 通知の既読
    case readNotifications(notificationIds: [Int])
}

// MARK: - TargetType Protocol Implementation
extension UserTarget: TargetType {
    var baseURL: URL {
        let host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        let baseURL: URL = URL(string: host + path)!
        return baseURL
    }
    
    var path: String {
        switch self {
        case .searchUser:
            return "users"
        case .getMyProfile:
            return "users/me"
        case .editProfile:
            return "users/me"
        case .getUserInfo(userId: let userId):
            return "users/\(userId)"
        case .getMyPostedVideos:
            return "users/me/posted-videos"
        case .deleteVideo(videoId: let videoId):
            return "users/me/posted-videos/\(videoId)"
        case .getUserPostedVideos(userId: let userId, _, _):
            return "users/\(userId)/posted-videos"
        case .getMyFavoriteVideos:
            return "users/me/favorite-videos"
        case .registerFavoriteVideo:
            return "users/me/favorite-videos"
        case .unFavoriteVideo(videoId: let videoId):
            return "users/me/favorite-videos/\(videoId)"
        case .followUser(userId: let userId), .unfollowUser(userId: let userId):
            return "users/me/follows/\(userId)"
        case .getUserFollowerList(userId: let userId, _, _):
            return "users/\(userId)/followers"
        case .getUserFollowList(userId: let userId, _, _):
            return "users/\(userId)/follows"
        case .getMyEmailAddress, .updateMyEmailAddress:
            return "users/me/mail-address"
        case .changePassword:
            return "users/me/password"
        case .getNotificationList:
            return "users/me/notifications"
        case .getNumberOfUnreadNotifications:
            return "users/me/notifications/un-read-count"
        case .getMyAmazing:
            return "users/me/amazing"
        case .reportUser(userId: let userId):
            return "users/\(userId)/reports"
        case .readNotifications:
            return "users/me/notification-read-histories"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchUser:
            return .get
        case .getMyProfile:
            return .get
        case .editProfile:
            return .post
        case .getUserInfo:
            return .get
        case .getMyPostedVideos:
            return .get
        case .deleteVideo:
            return .delete
        case .getUserPostedVideos:
            return .get
        case .getMyFavoriteVideos:
            return .get
        case .registerFavoriteVideo:
            return .post
        case .unFavoriteVideo:
            return .delete
        case .followUser:
            return .put
        case .unfollowUser:
            return .delete
        case .getUserFollowerList:
            return .get
        case .getUserFollowList:
            return .get
        case .getMyEmailAddress:
            return .get
        case .updateMyEmailAddress:
            return .put
        case .changePassword:
            return .put
        case .getNotificationList:
            return .get
        case .getNumberOfUnreadNotifications:
            return .get
        case .getMyAmazing:
            return .get
        case .reportUser:
            return .post
        case .readNotifications:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .searchUser(limit: let limit, fromUserId: let fromUserId, keyword: let keyword):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromUserId = fromUserId {
                parameters["from_user_id"] = fromUserId
            }
            if let keyword = keyword {
                parameters["keyword"] = keyword
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getMyProfile:
            return .requestPlain
        case .editProfile(icon: let icon, nickname: let nickname, description: let description, website: let website, birthDay: let birthDay):
            var formData: [MultipartFormData] = []
            if let icon = icon {
                let imageData = icon.jpegData(compressionQuality: 0.7)!
                formData.append(MultipartFormData(provider: .data(imageData), name: "icon", fileName: "icon.jpeg", mimeType: "image/jpeg"))
            }
            formData.append(MultipartFormData(provider: .data(nickname.utf8Encoded), name: "nickname"))
            formData.append(MultipartFormData(provider: .data((description ?? "").utf8Encoded), name: "description"))
            formData.append(MultipartFormData(provider: .data((website ?? "").utf8Encoded), name: "web_site"))
            formData.append(MultipartFormData(provider: .data((birthDay?.toString(.custom("yyyy-MM-dd")) ?? "").utf8Encoded), name: "birth_day"))
            return .uploadMultipart(formData)
        case .getUserInfo:
            return .requestPlain
        case .getMyPostedVideos(limit: let limit, fromVideoId: let fromVideoId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromVideoId = fromVideoId {
                parameters["from_video_id"] = fromVideoId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .deleteVideo:
            return .requestPlain
        case .getUserPostedVideos(_, limit: let limit, fromVideoId: let fromVideoId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromVideoId = fromVideoId {
                parameters["from_video_id"] = fromVideoId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getMyFavoriteVideos(limit: let limit, fromVideoId: let fromVideoId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromVideoId = fromVideoId {
                parameters["from_video_id"] = fromVideoId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .registerFavoriteVideo(videoId: let videoId):
            return .requestParameters(parameters: ["video_id": videoId], encoding: JSONEncoding.default)
        case .unFavoriteVideo:
            return .requestPlain
        case .followUser, .unfollowUser:
            return .requestPlain
        case .getUserFollowerList(_, limit: let limit, fromUserId: let fromUserId), .getUserFollowList(_, limit: let limit, fromUserId: let fromUserId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromUserId = fromUserId {
                parameters["from_user_id"] = fromUserId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getMyEmailAddress:
            return .requestPlain
        case .updateMyEmailAddress(mailAddress: let mailAddress, authCode: let authCode):
            return .requestParameters(parameters: ["mail_address": mailAddress, "auth_code": authCode], encoding: JSONEncoding.default)
        case .changePassword(oldPassword: let oldPassword, newPassword: let newPassword):
            return .requestParameters(parameters: ["old_password": oldPassword, "new_password": newPassword], encoding: JSONEncoding.default)
        case .getNotificationList(limit: let limit, fromNotificationId: let fromNotificationId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromNotificationId = fromNotificationId {
                parameters["from_notification_id"] = fromNotificationId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getNumberOfUnreadNotifications:
            return .requestPlain
        case .getMyAmazing:
            return .requestPlain
        case .reportUser:
            return .requestPlain
        case .readNotifications(notificationIds: let notificationIds):
            return .requestParameters(parameters: ["notification_ids": notificationIds], encoding: JSONEncoding.default)
        }
    }
    
    var sampleData: Data {
        switch self {
            case .searchUser:
                return
            """
            {
              "users": [
                {
                  "id": 1,
                  "icon_url": "http://example.com/user.png",
                  "nickname": "由紀チャンネル",
                  "description": "〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇",
                  "web_site": "https://example.com/",
                  "birth_day": "2000-01-01",
                  "apay": 1187000,
                  "follower_count": 9999,
                  "followee_count": 9999
                }
              ]
            }
            """.utf8Encoded
            case .getMyProfile:
                return
            """
            {
              "me": {
                "id": 1,
                "icon_url": "http://example.com/user.png",
                "nickname": "由紀チャンネル",
                "description": "〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇",
                "web_site": "https://example.com/",
                "birth_day": "2000-01-01",
                "apay": 1187000,
                "follower_count": 9999,
                "followee_count": 9999,
                "amazing": 95,
                "mail_address": "Segataro@example.com",
                "authorization_service": 0
              }
            }
            """.utf8Encoded
            case .editProfile:
                return "".utf8Encoded
            case .getUserInfo:
                return
            """
            {
              "user": {
                "id": 1,
                "icon_url": "http://example.com/user.png",
                "nickname": "由紀チャンネル",
                "description": "〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇",
                "web_site": "https://example.com/",
                "birth_day": "2000-01-01",
                "apay": 1187000,
                "follower_count": 9999,
                "followee_count": 9999
              },
              "is_following": true
            }
            """.utf8Encoded
            case .getMyPostedVideos:
                return dataFromResource(name: "api_videos_sample_response.json")
            case .deleteVideo:
                return "".utf8Encoded
            case .getUserPostedVideos:
            return dataFromResource(name: "api_videos_sample_response.json")
            case .getMyFavoriteVideos:
            return dataFromResource(name: "api_videos_sample_response.json")
            case .registerFavoriteVideo:
                return "".utf8Encoded
            case .unFavoriteVideo:
                return "".utf8Encoded
            case .followUser:
                return "".utf8Encoded
            case .unfollowUser:
            return "".utf8Encoded
            case .getUserFollowerList:
                return
                    """
                {
                  "followers": [
                    {
                      "user": {
                        "id": 1,
                        "icon_url": "http://example.com/user.png",
                        "nickname": "由紀チャンネル",
                        "description": "〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇",
                        "web_site": "https://example.com/",
                        "birth_day": "2000-01-01",
                        "apay": 1187000,
                        "follower_count": 9999,
                        "followee_count": 9999
                      },
                      "is_following": true
                    }
                  ]
                }
                """.utf8Encoded
            case .getUserFollowList:
                return
                    """
                    {
                      "follows": [
                        {
                          "user": {
                            "id": 1,
                            "icon_url": "http://example.com/user.png",
                            "nickname": "由紀チャンネル",
                            "description": "〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇〇",
                            "web_site": "https://example.com/",
                            "birth_day": "2000-01-01",
                            "apay": 1187000,
                            "follower_count": 9999,
                            "followee_count": 9999
                          },
                          "is_following": true
                        }
                      ]
                    }
                    """.utf8Encoded
            case .getMyEmailAddress:
                return
                    """
                {
                  "mail_address": "Segatystaro@example.com"
                }
                """.utf8Encoded
            case .updateMyEmailAddress:
                return "".utf8Encoded
            case .changePassword:
                return "".utf8Encoded
            case .getNotificationList:
                return dataFromResource(name: "api_notifications_sample_response.json")
            case .getNumberOfUnreadNotifications:
                return
                    """
                {
                  "un_read_count": 0
                }
                """.utf8Encoded
            case .getMyAmazing:
                return
                    """
                {
                  "amazing": 10
                }
                """.utf8Encoded
            case .reportUser:
                return "".utf8Encoded
            case .readNotifications:
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
        switch self {
        case .editProfile:
            return ["Content-type": "multipart/form-data"]
        default:
            return ["Content-type": "application/json"]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}

extension UserTarget: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
}
