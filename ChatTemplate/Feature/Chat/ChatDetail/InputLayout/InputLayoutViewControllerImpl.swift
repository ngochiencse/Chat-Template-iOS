//
//  InputLayoutViewController.swift
//  ChatTemplate
//
//  Created by Hien Pham on 6/26/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import UIKit
import RSKGrowingTextView

class InputLayoutViewControllerImpl: NSObject, InputLayoutViewController {
    @IBOutlet var container: UIView?
    @IBOutlet var textView: RSKGrowingTextView? {
        didSet {
            textView?.heightChangeAnimationDuration = 0.15
            textView?.heightChangeUserActionsBlock = {[weak self] (_ oldHeight: CGFloat, _ newHeight: CGFloat) in
                guard let self = self, let tableView = self.scrollView else { return }
                var contentOffset = tableView.contentOffset
                let oldHeightClamp = max(oldHeight, self.minTextViewHeight)
                let newHeightClamp = max(newHeight, self.minTextViewHeight)
                contentOffset.y += (newHeightClamp - oldHeightClamp)
                tableView.contentOffset = contentOffset
                self.container?.layoutIfNeeded()
            }
        }
    }
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet var textViewContainerBottomSpaceConstraint: NSLayoutConstraint?
    var minTextViewHeight: CGFloat = 0

    func setUp(container: UIView?, textView: RSKGrowingTextView?, scrollView: UIScrollView?,
               textViewContainerBottomSpaceConstraint: NSLayoutConstraint?, minTextViewHeight: CGFloat) {
        self.container = container
        self.textView = textView
        self.scrollView = scrollView
        self.textViewContainerBottomSpaceConstraint = textViewContainerBottomSpaceConstraint
        self.minTextViewHeight = minTextViewHeight
    }

    private var bottomSafeArea: CGFloat {
        let bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            bottomSafeArea = container?.safeAreaInsets.bottom ?? 0
        } else {
            bottomSafeArea = container?.parentViewController?.bottomLayoutGuide.length ?? 0
        }
        return bottomSafeArea
    }

    override init() {
        super.init()
        setupNotification()
    }

    func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    //    func removeNotification() {
    //    }

    @objc private func keyboardWillShow(notification: Notification) {
        showToolBarWithKeyboardSetting(keyboardSetting: notification.userInfo!)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        hideToolBarWithKeyboardSetting(keyboardSetting: notification.userInfo!)
    }

    private func showToolBarWithKeyboardSetting(keyboardSetting: [AnyHashable: Any]) {
        guard (textViewContainerBottomSpaceConstraint?.constant ?? 0) == 0 else { return }

        guard let kbFrame: CGRect = keyboardSetting[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        var contentOffSet: CGPoint = scrollView?.contentOffset ?? .zero
        contentOffSet.y += kbFrame.size.height - bottomSafeArea

        textViewContainerBottomSpaceConstraint?.constant = kbFrame.size.height

        guard let duration = keyboardSetting[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let keyboardSetting = keyboardSetting[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions.init(rawValue: keyboardSetting),
                       animations: {
                        self.scrollView?.contentOffset = contentOffSet
                        self.container?.layoutIfNeeded()
                       },
                       completion: nil)
    }

    private func hideToolBarWithKeyboardSetting(keyboardSetting: [AnyHashable: Any]) {
        guard (textViewContainerBottomSpaceConstraint?.constant ?? 0) != 0 else { return }

        textViewContainerBottomSpaceConstraint?.constant = 0

        guard let kbFrame: CGRect = keyboardSetting[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        var contentOffSet: CGPoint = scrollView?.contentOffset ?? .zero
        contentOffSet.y -= kbFrame.size.height - bottomSafeArea

        guard let duration = keyboardSetting[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let keyboardSetting = keyboardSetting[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions.init(rawValue: keyboardSetting),
                       animations: {
                        self.scrollView?.contentOffset = contentOffSet
                        self.container?.layoutIfNeeded()
                       },
                       completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
