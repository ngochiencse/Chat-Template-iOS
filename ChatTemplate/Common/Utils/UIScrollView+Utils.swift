//
//  UIScrollView+Utils.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    var isScrollPositionAtBottom: Bool {
        return contentOffset.y >= (contentSize.height - bounds.size.height)
    }

    func scrollToBottomByContentOffset(animated: Bool) {
        let newY = max(contentSize.height - bounds.height, 0)
        setContentOffset(CGPoint(x: 0, y: newY), animated: animated)
    }
}
