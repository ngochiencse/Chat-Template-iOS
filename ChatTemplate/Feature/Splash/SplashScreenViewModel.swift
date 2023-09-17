//
//  SplashScreenViewModel.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/9/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift

protocol SplashScreenViewModel: class {
    var onFinish: PublishSubject<Void> { get }
    func checkLocalData()
}
