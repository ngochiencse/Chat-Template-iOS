//
//  MessageBackgroundView.swift
//  ChatTemplate
//
//  Created by Hien Pham on 8/31/20.
//  Copyright © 2020 Hien Pham. All rights reserved.
//

import Foundation
import UIKit

class MessageBackgroundView: UIView {
    var corners = UIRectCorner.allCorners {
        didSet {
            layoutSubviews()
        }
    }
    var roundedCornerRadius: CGFloat = 16
    var unroundedCornerRadius: CGFloat = 6

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = unroundedCornerRadius
        roundCorners(corners: corners, radius: roundedCornerRadius)
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        layer.mask = nil
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
