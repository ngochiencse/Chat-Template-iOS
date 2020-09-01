//
//  UIView+Utils.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/25/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
