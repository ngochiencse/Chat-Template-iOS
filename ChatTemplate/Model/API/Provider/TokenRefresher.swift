//
//  TokenRefresher.swift
//  ios_template_project
//
//  Created by Hien Pham on 3/10/20.
//  Copyright © 2020 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift

protocol TokenRefresher: class {
    func refreshAccessToken(_ refreshToken: String) -> Single<String>
}
