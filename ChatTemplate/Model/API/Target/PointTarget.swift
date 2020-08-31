//
//  PointTarget.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/14/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Moya

// Correspond to Auth Section in api doc
enum PointTarget {
    // Apay交換可能商品を取得
    case getApayProducts(limit: Int?, fromApayProductId: Int?)
    // Apay交換可能商品の詳細取得
    case getApayProductDetail(apayProductId: String)
    // Apayの交換履歴取得
    case getApayExchangeHistories(limit: Int?, fromApayExchangeHistoryId: Int?)
    // Apay交換
    case apayExchange(apayProductId: String)
    // Apay交換履歴詳細取得
    case getApayExchangeHistoryDetail(apayExchangeHistoryId: Int)
}

// MARK: - TargetType Protocol Implementation
extension PointTarget: TargetType {
    var baseURL: URL {
        let host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        let baseURL: URL = URL(string: host + path)!
        return baseURL
    }
    
    var path: String {
        switch self {
        case .getApayProducts:
            return "apay-products"
        case .getApayProductDetail(apayProductId: let apayProductId):
            return "apay-products/\(apayProductId)"
        case .getApayExchangeHistories:
            return "users/me/apay-exchange-histories"
        case .apayExchange:
            return "users/me/apay-exchange-histories"
        case .getApayExchangeHistoryDetail(apayExchangeHistoryId: let apayExchangeHistoryId):
            return "users/me/apay-exchange-histories/\(apayExchangeHistoryId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getApayProducts:
                return .get
            case .getApayProductDetail:
                return .get
            case .getApayExchangeHistories:
                return .get
            case .apayExchange:
                return .post
            case .getApayExchangeHistoryDetail:
                return .get
        }
    }
    
    var task: Task {
        switch self {
            case .getApayProducts(limit: let limit, fromApayProductId: let fromApayProductId):
                var parameters: [String: Any] = [:]
                if let limit = limit {
                    parameters["limit"] = limit
                }
                if let fromApayProductId = fromApayProductId {
                    parameters["from_apay_product_id"] = fromApayProductId
                }
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            case .getApayProductDetail:
                return .requestPlain
            case .getApayExchangeHistories(limit: let limit, fromApayExchangeHistoryId: let fromApayExchangeHistoryId):
                var parameters: [String: Any] = [:]
                if let limit = limit {
                    parameters["limit"] = limit
                }
                if let fromApayExchangeHistoryId = fromApayExchangeHistoryId {
                    parameters["from_apay_exchange_history_id"] = fromApayExchangeHistoryId
                }
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            case .apayExchange(apayProductId: let apayProductId):
                return .requestParameters(parameters: ["apay_product_id": apayProductId], encoding: JSONEncoding.default)
            case .getApayExchangeHistoryDetail:
                return .requestPlain
        }
    }
    
    var sampleData: Data {
        switch self {
            case .getApayProducts:
                return dataFromResource(name: "apay_api.json")
            case .getApayProductDetail:
                return dataFromResource(name: "apay_api.json")
            case .getApayExchangeHistories:
                return dataFromResource(name: "apay_api.json")
            case .apayExchange:
                return "".utf8Encoded
            case .getApayExchangeHistoryDetail:
                return dataFromResource(name: "apay_api.json")
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

extension PointTarget: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
}
