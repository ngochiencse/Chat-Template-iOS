//
//  AppCoordinator.swift
//  ios_template_project
//
//  Created by Hien Pham on 10/25/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AppCoordinatorImpl: NSObject, AppCoordinator {
    var window: UIWindow?
    let root: RootViewController
    var flowObservable: Observable<AppFlow?> {
        return currentFlow.asObservable()
    }
    private(set) var currentFlow: BehaviorRelay<AppFlow?> = BehaviorRelay(value: nil)
    private(set) var currentItem: Any?
    private(set) var binding: Disposable?
    
    init(window: UIWindow?) {
        self.window = window
        root = RootViewController()
        super.init()
    }
    
    func switchFlow(to appFlow: AppFlow, animated: Bool) {
        switch appFlow {
        case .splash:
            let vc: SplashScreenViewController = SplashScreenViewController()
            vc.delegate = self
            root.showViewController(vc, animated: animated)
            currentItem = vc
        case .main:
            let main = MainCoordinator(root: root)
            main.start()
            currentItem = main
        }
        
        currentFlow.accept(appFlow)
    }

    func start() {
        switchFlow(to: .splash, animated: true)
        
        window?.rootViewController = root
        window?.makeKeyAndVisible()
    }
}

extension AppCoordinatorImpl: SplashScreenViewControllerDelegate {
    func splashScreenDidFinish(splashScreen: SplashScreenViewController) {
        switchFlow(to: .main, animated: true)
    }
}
