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
    let service: AppCoordinatorService
    
    init(window: UIWindow?, service: AppCoordinatorService = AppCoordinatorServiceImpl()) {
        self.window = window
        self.service = service
        root = RootViewController()
        super.init()
        root.delegate = self
        bindToEvents()
    }
    
    func bindToEvents() {
        Observable
            .combineLatest(
                service.pushNotification.asObservable(), currentFlow.asObservable())
            .observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (values) in
                let (pushNotificationWrapped, currentFlow) = values
                guard let self = self, currentFlow == .main else { return }
                
                if let pushNotification = pushNotificationWrapped {
                    self.handlePushNotification(pushNotification.content)
                    self.service.didHandlePushNotification()
                    return
                }
            }).disposed(by: rx.disposeBag)
    }

    func switchFlow(to appFlow: AppFlow, animated: Bool) {
        switch appFlow {
        case .splash:
            let splash: SplashScreenViewModel = SplashScreenViewModelImpl()
            splash.delegate = self
            let vc: SplashScreenViewController = SplashScreenViewController(viewModel: splash)
            root.showViewController(vc, animated: animated)
            currentItem = vc
            break
        case .tutorial:
            let tutorial: TutorialViewModel = TutorialViewModelImpl()
            tutorial.delegate = self
            let vc: TutorialViewController = TutorialViewController(viewModel: tutorial)
            root.showViewController(vc, animated: animated)
            currentItem = vc
            break
        case .auth:
            let auth = AuthCoordinator(root: root)
            auth.delegate = self
            auth.start()
            currentItem = auth
            break
        case .main:
            let main = MainCoordinator(root: root)
            main.start()
            currentItem = main
            break
        }
        
        currentFlow.accept(appFlow)
    }

    func start() {
        switchFlow(to: .splash, animated: true)
        
        window?.rootViewController = root
        window?.makeKeyAndVisible()
    }
    
    func logOut() {
        root.dismiss(animated: true, completion: nil)
        switchFlow(to: .auth, animated: true)
    }
    
    func didStartAppWithPushContent(_ pushContent: [AnyHashable : Any]) {
        service.didStartAppWithPushContent(pushContent)
    }

    func didReceivePushContent(_ pushContent: [AnyHashable : Any], isAppActive: Bool) {
        service.didReceivePushContent(pushContent, isAppActive: isAppActive)
    }
}

extension AppCoordinatorImpl: SplashScreenViewModelDelegate {
    func splashScreen(splashScreen : SplashScreenViewModel, didFinishWithNextAction nextAction: SplashScreenNextAction) {
        switch nextAction {
        case .tutorialScreen:
            switchFlow(to: .tutorial, animated: true)
            break
        case .loginScreen:
            switchFlow(to: .auth, animated: true)
            break
        case .homeScreen:
            switchFlow(to: .main, animated: true)
            break
        }
    }
}
extension AppCoordinatorImpl: TutorialViewModelDelegate {
    func tutorialGoNext(tutorial: TutorialViewModel) {
        switchFlow(to: .auth, animated: true)
    }
}

extension AppCoordinatorImpl: AuthCoordinatorDelegate {
    func authCoordinatorDidFinish(_ authCoordinator: AuthCoordinator) {
        switchFlow(to: .main, animated: true)
    }
}

extension AppCoordinatorImpl: RootViewControllerDelegate {
    func rootViewControllerOnLogoutEvent(_ rootViewController: RootViewController?) {
        root.dismiss(animated: false, completion: nil)
        switchFlow(to: .auth, animated: true)
    }
}

extension AppCoordinatorImpl {
    func handlePushNotification(_ pushNotification: [AnyHashable : Any]) {
        print("handlePushNotification: \(pushNotification)")
        guard let aps = pushNotification["aps"] as? [AnyHashable : Any],
            let alert = aps["alert"] as? [AnyHashable : Any] else { return }
        let title = alert["title"] as? String
        let body = "Tap push notification with message: \(String(describing: alert["body"] as? String))"
        root.alertViewModel.alertModel.accept(AlertModel(actionModels: [AlertModel.ActionModel(title: "OK", style: .default, handler: nil)],
                                                         title: title, message: body, prefferedStyle: .alert))
    }
}
