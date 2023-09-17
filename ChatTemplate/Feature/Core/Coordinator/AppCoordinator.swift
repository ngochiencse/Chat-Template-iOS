//
//  AppCoordinator.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/9/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum AppFlow {
    case splash
    case main
}

protocol AppCoordinator: Coordinator {
    var window: UIWindow? { get }
    var root: RootViewController { get }
    var flowObservable: Observable<AppFlow?> { get }
}
