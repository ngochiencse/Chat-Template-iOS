//
//  CustomUIView.swift
//  ChatTemplate
//
//  Created by Hien Pham on 11/25/20.
//  Copyright © 2020 Hien Pham. All rights reserved.
//

import Foundation
import UIKit

class CustomUIView: UIView {
    var corners = UIRectCorner.allCorners {
        didSet {
            layoutSubviews()
        }
    }

    var colorBorder: UIColor? = nil {
        didSet {
            borderLayer?.strokeColor = colorBorder?.cgColor
        }
    }
    var widthBorder: CGFloat? = nil {
        didSet {
            borderLayer?.lineWidth = widthBorder ?? 0
        }
    }
    private var borderLayer: CAShapeLayer?
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 6
    }

    func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        layer.mask = nil
        borderLayer?.removeFromSuperlayer()
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds,
                                    topLeftRadius: topLeftRadius,
                                    topRightRadius: topRightRadius,
                                    bottomLeftRadius: bottomLeftRadius,
                                    bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape

        guard let layer = layer.mask as? CAShapeLayer,
              let path = (layer).path
        else {
            return
        }
        borderLayer = CAShapeLayer()
        borderLayer!.path = path // Reuse the Bezier path
        borderLayer!.strokeColor = colorBorder?.cgColor
        borderLayer!.fillColor = UIColor.clear.cgColor
        borderLayer!.lineWidth = widthBorder ?? 0
        borderLayer!.frame = self.bounds
        layer.addSublayer(borderLayer!)
    }
}
