//
//  UINavigationControllerUtils.swift
//  ios_template_project
//
//  Created by Hien Pham on 8/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    static func topMostNavigationController() -> UINavigationController? {
        var topNavigationController: UINavigationController? = nil
        var topMostViewController = UIViewController.topMostController()
        while topMostViewController != nil && topMostViewController!.isKind(of: UINavigationController.self) == false {
            topMostViewController = topMostViewController?.presentingViewController
        }
        topNavigationController = topMostViewController as? UINavigationController
        return topNavigationController
    }
    
    func popToClass<T>(_ class_p : T.Type, animated: Bool)  {
        for controller in self.viewControllers {
            if controller is T {
                self.popToViewController(controller, animated: animated)
                break
            }
        }
    }
}
