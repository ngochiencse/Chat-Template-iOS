//
//  VideoTarget.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/13/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Moya
import SwiftDate

// Correspond to Top Section in api doc
enum VideoTarget {
    // ランキング取得
    case getRankingVideos(limit: Int?, offset: Int?)
    // おすすめ動画一覧取得
    case getRecommendedVideos(limit: Int?, offset: Int?)
    // tig動画一覧取得
    case tigVideoList(limit: Int?, fromVideoId: String?)
    // 新着動画一覧取得
    case newVideoList(limit: Int?, fromVideoId: String?)
    // 動画一覧取得
    case getVideoList(limit: Int?, fromVideoId: String?, hashTagName: String?, keyword: String?)
    // 動画投稿
    case postVideo(title: String, description: String?, thumbnail: UIImage, video: URL, musicId: String?, isPublic: Bool)
    // かおスタンプ取得
    case getStampList(limit: Int?, offset: Int?)
    // 削除されたかおスタンプ取得
    case getDeletedFaceStamp(fromDeletedAt: Date?)
    // おすすめのタグ一覧を取得
    case getRecommendedTagList
    // 動画詳細取得
    case getVideoDetail(videoId: String)
    // 動画編集
    case editVideo(videoId: String, title: String, description: String?, thumbnail: UIImage?, isPublic: Bool)
    // 動画詳細おすすめ動画取得
    case getRelatedVideos(videoId: String)
    // 動画詳細おすすめ動画取得
    // Create a video viewing history (history played for ○ seconds from viewing)
    case createVideoViewingHistory(videoId: String)
    // 動画視聴履歴作成
    // Create a history of all video viewing (history watched to the end)
    case createAllVideoViewingHistory(videoId: String)
    // 動画全視聴履歴作成
    // Send Amazing to the target video. Detailed processing order is described here (https://ota.dev.vc/ios_template_project/api-document/api-document.pdf).
    case sendAmazingHistoryToVideo(videoId: String)
    // 動画へアメイジング送信
    case getListMusic(limit: Int?, offset: Int?)
    // 音楽取得
    case getDeletedMusic(fromDeletedAt: Date?)
    // 動画の通報を送信
    case reportVideo(videoId: String)
    // 未チェックのアメイジング総数を取得
    case getUncheckedAmazingTotal(videoId: String)
    // 動画に付与されたアメイジングのチェック
    case checkAmazingGiveToTheVideo(videoId: String)
}

// MARK: - TargetType Protocol Implementation
extension VideoTarget: TargetType {
    var baseURL: URL {
        let host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        let baseURL: URL = URL(string: host + path)!
        return baseURL
    }
    
    var path: String {
        switch self {
        case .getRankingVideos:
            return "rankings"
        case .getRecommendedVideos:
            return "pickup-videos"
        case .tigVideoList:
            return "tig-videos"
        case .newVideoList:
            return "new-videos"
        case .getVideoList:
            return "videos"
        case .postVideo:
            return "videos"
        case .getStampList:
            return "face-stamps"
        case .getDeletedFaceStamp:
            return "deleted-face-stamps"
        case .getRecommendedTagList:
            return "pickup-hash-tags"
        case .getVideoDetail(videoId: let videoId):
            return "videos/\(videoId)"
        case .editVideo(videoId: let videoId, _, _, _, _):
            return "videos/\(videoId)"
        case .getRelatedVideos(videoId: let videoId):
            return "videos/\(videoId)/related-videos"
        case .createVideoViewingHistory(videoId: let videoId):
            return "videos/\(videoId)/view-histories"
        case .createAllVideoViewingHistory(videoId: let videoId):
            return "videos/\(videoId)/all-view-histories"
        case .sendAmazingHistoryToVideo(videoId: let videoId):
            return "videos/\(videoId)/amazing-histories"
        case .getListMusic:
            return "musics"
        case .getDeletedMusic:
            return "deleted-musics"
        case .reportVideo(videoId: let videoId):
            return "videos/\(videoId)/reports"
        case .getUncheckedAmazingTotal(videoId: let videoId):
            return "users/me/posted-videos/\(videoId)/unchecked-amazing"
        case .checkAmazingGiveToTheVideo(videoId: let videoId):
            return "users/me/posted-videos/\(videoId)/check-amazing"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getRankingVideos:
            return .get
        case .getRecommendedVideos:
            return .get
        case .tigVideoList:
            return .get
        case .newVideoList:
            return .get
        case .getVideoList:
            return .get
        case .postVideo:
            return .post
        case .getStampList:
            return .get
        case .getDeletedFaceStamp:
            return .get
        case .getRecommendedTagList:
            return .get
        case .getVideoDetail:
            return .get
        case .editVideo:
            return .post
        case .getRelatedVideos:
            return .get
        case .createVideoViewingHistory:
            return .post
        case .createAllVideoViewingHistory:
            return .post
        case .sendAmazingHistoryToVideo:
            return .post
        case .getListMusic:
            return .get
        case .getDeletedMusic:
            return .get
        case .reportVideo:
            return .post
        case .getUncheckedAmazingTotal:
            return .get
        case .checkAmazingGiveToTheVideo:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getRankingVideos(limit: let limit, offset: let offset):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let offset = offset {
                parameters["offset"] = offset
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getRecommendedVideos(limit: let limit, offset: let offset):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let offset = offset {
                parameters["offset"] = offset
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .tigVideoList(limit: let limit, fromVideoId: let fromVideoId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromVideoId = fromVideoId {
                parameters["from_video_id"] = fromVideoId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .newVideoList(limit: let limit, fromVideoId: let fromVideoId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromVideoId = fromVideoId {
                parameters["from_video_id"] = fromVideoId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getVideoList(limit: let limit, fromVideoId: let fromVideoId , hashTagName: let hashTagName, keyword: let keyword):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromVideoId = fromVideoId {
                parameters["from_video_id"] = fromVideoId
            }
            if let hashTagName = hashTagName {
                parameters["hash_tag_name"] = hashTagName
            }
            if let keyword = keyword {
                parameters["keyword"] = keyword
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .postVideo(title: let title, description: let description, thumbnail: let thumbnail, video: let video, musicId: let musicId, isPublic: let isPublic):
            var formData: [MultipartFormData] = []
            formData.append(MultipartFormData(provider: .data(title.utf8Encoded), name: "title"))
            if let description = description {
                formData.append(MultipartFormData(provider: .data(description.utf8Encoded), name: "description"))
            }
            let imageData = thumbnail.jpegData(compressionQuality: 0.7)!
            formData.append(MultipartFormData(provider: .data(imageData), name: "thumbnail", fileName: "thumbnail.jpeg", mimeType: "image/jpeg"))
            formData.append(MultipartFormData(provider: .file(video), name: "video", fileName: "video.mp4", mimeType: "video/mp4"))
            if let musicId = musicId {
                formData.append(MultipartFormData(provider: .data(musicId.utf8Encoded), name: "music_id"))
            }
            let isPublicStr: String = (isPublic == true) ? "0" : "1"
            formData.append(MultipartFormData(provider: .data(isPublicStr.utf8Encoded), name: "is_public"))
            return .uploadMultipart(formData)
        case .getStampList(limit: let limit, offset: let offset):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let offset = offset {
                parameters["offset"] = offset
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getDeletedFaceStamp(fromDeletedAt: let fromDeletedAt):
            var parameters: [String: Any] = [:]
            if let fromDeletedAt = fromDeletedAt {
                let dateString: String = fromDeletedAt.toString(.iso(.withInternetDateTime))
                parameters["from_deleted_at"] = dateString
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getRecommendedTagList:
            return .requestPlain
        case .getVideoDetail(videoId: let videoId):
            return .requestPlain
        case .editVideo(_, title: let title, description: let description, thumbnail: let thumbnail, isPublic: let isPublic):
            var formData: [MultipartFormData] = []
            formData.append(MultipartFormData(provider: .data(title.utf8Encoded), name: "title"))
            if let description = description {
                formData.append(MultipartFormData(provider: .data(description.utf8Encoded), name: "description"))
            }
            if let thumbnail = thumbnail {
                let imageData = thumbnail.jpegData(compressionQuality: 0.7)!
                formData.append(MultipartFormData(provider: .data(imageData), name: "thumbnail", fileName: "thumbnail.jpeg", mimeType: "image/jpeg"))
            }
            let isPublicStr: String = (isPublic == true) ? "0" : "1"
            formData.append(MultipartFormData(provider: .data(isPublicStr.utf8Encoded), name: "is_public"))
            return .uploadMultipart(formData)
        case .getRelatedVideos(videoId: let videoId):
            return .requestParameters(parameters: ["video_id": videoId], encoding: URLEncoding.default)
        case .createVideoViewingHistory:
            return .requestPlain
        case .createAllVideoViewingHistory:
            return .requestPlain
        case .sendAmazingHistoryToVideo:
            return .requestPlain
        case .getListMusic(limit: let limit, offset: let offset):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let offset = offset {
                parameters["offset"] = offset
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getDeletedMusic(fromDeletedAt: let fromDeletedAt):
            var parameters: [String: Any] = [:]
            if let fromDeletedAt = fromDeletedAt {
                let dateString: String = fromDeletedAt.toString(.iso(.withInternetDateTime))
                parameters["from_deleted_at"] = dateString
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .reportVideo:
            return .requestPlain
        case .getUncheckedAmazingTotal:
            return .requestPlain
        case .checkAmazingGiveToTheVideo:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getRankingVideos:
            return dataFromResource(name: "api_videos_ranking_sample_response.json")
        case .getRecommendedVideos, .tigVideoList, .newVideoList, .getVideoList:
            return dataFromResource(name: "api_videos_sample_response.json")
        case .postVideo:
            return "".utf8Encoded
        case .getStampList, .getDeletedFaceStamp:
            return dataFromResource(name: "api_stamp_list_sample_response.json")
        case .getRecommendedTagList:
            return
                """
                {
                  "hash_tags": [
                    {
                      "id": 1,
                      "name": "ダンスios_template_project"
                    },
                    {
                      "id": 2,
                      "name": "夏休み"
                    },
                    {
                      "id": 3,
                      "name": "早口言葉"
                    },
                    {
                      "id": 4,
                      "name": "AMAZING ios_template_project"
                    }
                  ]
                }
                """.utf8Encoded
        case .getVideoDetail:
            return dataFromResource(name: "api_video_detail_response_sample.json")
        case .editVideo:
            return "".utf8Encoded
        case .getRelatedVideos:
            return dataFromResource(name: "api_videos_sample_response.json")
        case .createVideoViewingHistory:
            return "".utf8Encoded
        case .createAllVideoViewingHistory:
            return "".utf8Encoded
        case .sendAmazingHistoryToVideo:
            return "".utf8Encoded
        case .getListMusic, .getDeletedMusic:
            return dataFromResource(name: "api_music_list_sample_response.json")
        case .reportVideo:
            return "".utf8Encoded
        case .getUncheckedAmazingTotal:
            return
                """
            {
                "unchecked_amazing": 0
            }
            """.utf8Encoded
        case .checkAmazingGiveToTheVideo:
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
        case .postVideo, .editVideo:
            return ["Content-type": "multipart/form-data"]
        default:
            return ["Content-type": "application/json"]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}

extension VideoTarget: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
}
