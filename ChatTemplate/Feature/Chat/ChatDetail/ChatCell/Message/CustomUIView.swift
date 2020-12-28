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

    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0

    private var borderLayer: CAShapeLayer?
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshDisplayRoundCorners()
    }

    func refreshDisplayRoundCorners() {
        roundCorners(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    }

    private func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0,
                              bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
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

        let borderLayer = CAShapeLayer()
        borderLayer.path = (layer.mask as? CAShapeLayer)?.path // Reuse the Bezier path
        borderLayer.strokeColor = colorBorder?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = widthBorder ?? 0
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
        self.borderLayer = borderLayer
    }
}
