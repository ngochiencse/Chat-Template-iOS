//
//  InputLayoutViewController.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 6/26/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit
import RSKGrowingTextView

protocol InputLayoutViewController {
    func setUp(container: UIView?, textView: RSKGrowingTextView?, scrollView: UIScrollView?,
               textViewContainerBottomSpaceConstraint: NSLayoutConstraint?, minTextViewHeight: CGFloat)
}
