//
//  MainTabbarController.swift
//  ios_template_project
//
//  Created by Hien Pham on 8/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import UIKit
import BSTabbarController
import SnapKit
import Moya

class MainTabbarContainerController: BaseViewController {
    let content: MainTabbarController = MainTabbarController(nibName: String(describing: MainTabbarController.self), bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        content.delegate = self
        view.addSubview(content.view)
        content.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        content.willMove(toParent: self)
        addChild(content)
        content.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshDisplayMainTabbarController()
    }
    
    fileprivate func refreshDisplayMainTabbarController() {
        let selectedViewController : UIViewController = self.content.selectedViewController
        self.title = selectedViewController.title
        self.navigationItem.titleView = selectedViewController.navigationItem.titleView
        self.navigationItem.leftBarButtonItems = selectedViewController.navigationItem.leftBarButtonItems
        self.navigationItem.rightBarButtonItems = selectedViewController.navigationItem.rightBarButtonItems
    }
}

extension MainTabbarContainerController: BSTabbarControllerDelegate {
    func tabBarController(_ tabBarController: BSTabbarController, didSelectAtIndex selectedIndex: Int) {
        self.refreshDisplayMainTabbarController()
    }
}

class MainTabbarController: BSTabbarController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {        
        var viewControllers : Array<UIViewController> = Array();
        for i in 0..<5 {
            var vc : BaseViewController
            switch (i) {
            case 0:
                vc = ArticleViewController()
                vc.title = "API Sample"
                break
            case 1:
                vc = RoundedUISampleViewController()
                vc.title = "RoundedUI Sample"
                break
            case 2:
                vc = PostArticleViewController()
                vc.title = "Post Sample"
                break;
            case 3:
                vc = APIMultipleViewController()
                vc.title = "API Multiple Demo"
                break;
            case 4:
                vc = ChatListViewController()
                vc.title = "Chat"
            default:
                vc = BaseViewController();
                vc.view.backgroundColor = UIColor(red: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), green: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), blue: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), alpha: 1);
                vc.title = String(format: "Tab %d",  i + 1)
                break;
            }
            viewControllers.append(vc)
        }
        self.viewControllers = viewControllers;
        self.title = "カレンダー";
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
