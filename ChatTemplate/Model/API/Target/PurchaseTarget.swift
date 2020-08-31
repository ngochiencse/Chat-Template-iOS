//
//  PurchaseTarget.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/14/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Moya

enum OSType: Int {
    case ios = 0
    case android
}

// Correspond to Auth Section in api doc
enum PurchaseTarget {
    // 購入商品の取得
    case getPurchasedProducts(osType: OSType?)
    // 購入履歴の取得
    case getPurchaseHistories(limit: Int?, fromPurchaseHistoryId: Int?)
    // 購入
    case purchase(receipt: String, price: String)
}

// MARK: - TargetType Protocol Implementation
extension PurchaseTarget: TargetType {
    var baseURL: URL {
        let host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        let baseURL: URL = URL(string: host + path)!
        return baseURL
    }
    
    var path: String {
        switch self {
        case .getPurchasedProducts:
            return "purchase-products"
        case .getPurchaseHistories, .purchase:
            return "users/me/purchase-histories"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPurchasedProducts:
            return .get
        case .getPurchaseHistories:
            return .get
        case .purchase:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getPurchasedProducts(osType: let osType):
            var parameters: [String: Any] = [:]
            if let osType = osType {
                parameters["os_type"] = osType.rawValue
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getPurchaseHistories(limit: let limit, fromPurchaseHistoryId: let fromPurchaseHistoryId):
            var parameters: [String: Any] = [:]
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let fromPurchaseHistoryId = fromPurchaseHistoryId {
                parameters["from_purchase_history_id"] = fromPurchaseHistoryId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .purchase(receipt: let receipt, price: let price):
            return .requestParameters(parameters: ["receipt": receipt, "price": price], encoding: JSONEncoding.default)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getPurchasedProducts:
            return
                """
                    {
                      "purchase_products": [
                        {
                          "id": 1,
                          "count": 10,
                          "extra": 1,
                          "product_id": "vn.mj.test.price99"
                        },
                        {
                          "id": 2,
                          "count": 20,
                          "extra": 1,
                          "product_id": "vn.mj.test.price199"
                        },
                        {
                          "id": 3,
                          "count": 300000000000,
                          "extra": 300000000000,
                          "product_id": "vn.mj.test.price299"
                        },
                        {
                          "id": 4,
                          "count": 40,
                          "extra": 10,
                          "product_id": "vn.mj.test.price399"
                        },
                        {
                          "id": 5,
                          "count": 50,
                          "extra": 22,
                          "product_id": "vn.mj.test.price499"
                        }
                      ]
                    }
                """.utf8Encoded
        case .getPurchaseHistories:
            return
                """
                    {
                      "purchase_histories": [
                        {
                          "id": 1,
                          "created_at": "2019-12-07T10:00:02+09:00",
                          "price": "240円",
                          "purchase_product": {
                            "id": 1,
                            "count": 10,
                            "extra": 1,
                            "product_id": "abcdefg12345"
                          }
                        }
                      ]
                    }
                """.utf8Encoded
        case .purchase:
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

extension PurchaseTarget: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
}
