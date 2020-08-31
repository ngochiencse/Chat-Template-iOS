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
        let vc: MainTabbarContainerController = MainTabbarContainerController()
        if let articleViewController: ArticleViewController = vc.content.viewControllers.first(where: { (ele: UIViewController) -> Bool in
            return ele is ArticleViewController
        }) as? ArticleViewController {
            articleViewController.delegate = self
        }
        navigationController.pushViewController(vc, animated: false)
        root.showViewController(navigationController, animated: true)
    }
}

extension MainCoordinator: ArticleViewControllerDelegate {
    func articleViewController(_ articleViewController: ArticleViewController, didSelect article: ArticleInfo) {
        if let urlString: String = article.url, let vc : WebViewController = WebViewController(urlString: urlString) {
            vc.title = "Web View"
            vc.bottomToolBarHidden = true
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}
