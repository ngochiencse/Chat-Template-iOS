//
//  MainCoordinator.swift
//  ios_template_project
//
//  Created by Hien Pham on 10/25/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import UIKit

class MainCoordinator: NSObject, Coordinator {
    let root: RootViewController
    let navigationController: BaseNavigationController = BaseNavigationController()
    init(root: RootViewController) {
        self.root = root
        super.init()
    }
    
    func start() {
        let vc: ChatListViewController = ChatListViewController()
        navigationController.pushViewController(vc, animated: false)
        root.showViewController(navigationController, animated: true)
    }
}
