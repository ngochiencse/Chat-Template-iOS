//
//  ChatTextCell.swift
//  Tavi
//
//  Created by Hien Pham on 12/15/17.
//  Copyright © 2017 Bravesoft VN. All rights reserved.
//

import UIKit

class MessageTextCell: MessageCell {
    @IBOutlet weak private var contentLabel : UILabel!
    override var viewModel: ChatItemCellViewModel? {
        didSet {
            if viewModel != nil && (viewModel is MessageTextCellViewModel) == false {
                fatalError("Wrong viewModel type! Current is:\(String(describing: type(of: viewModel))). Must be: MessageTextCellViewModel")
            }
            
            let viewModel = self.viewModel as? MessageTextCellViewModel
            displayWithViewModel(viewModel)
        }
    }
        
    private func displayWithViewModel(_ viewModel: MessageTextCellViewModel?) {
        var trimmedString : String
        if let unwrapped = viewModel?.text {
            if (unwrapped.count > Constant.MAX_LENGTH_CHAT_MESSAGE) {
                let start = unwrapped.startIndex
                let end = unwrapped.index(start, offsetBy: Constant.MAX_LENGTH_CHAT_MESSAGE)
                trimmedString = String(unwrapped[start..<end])
            } else {
                trimmedString = unwrapped
            }
        } else {
            trimmedString = ""
        }
        self.contentLabel.attributedText = self.refreshString(string: trimmedString, lineSpacing: 6)
        
        // Set line spacing to 0 if content label display only 1 line
        do {
            var frame : CGRect = self.frame
            frame.size.width = UIScreen.main.bounds.size.width
            self.frame = frame
            self.layoutIfNeeded()
        }
        
//        if self.contentLabel.lineCount() <= 1 {
//            self.contentLabel.attributedText = self.refreshString(string: trimmedString, lineSpacing: 0)
//        }
        
        if viewModel?.isMyMessage == true {
            contentLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
            contentLabel.textColor = UIColor.white
        } else {
            contentLabel.transform = CGAffineTransform.identity
            contentLabel.textColor = UIColor.black
        }
    }
    
    private func refreshString(string: String, lineSpacing: CGFloat) -> NSAttributedString {
        let paragraphStyle : NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineSpacing = lineSpacing
        let attrsDictionary : [NSAttributedString.Key: Any] = [.font : self.contentLabel.font ?? UIFont.systemFont(ofSize: 14),
                                                                        .paragraphStyle : paragraphStyle,
                                                                        .foregroundColor : self.contentLabel.textColor ?? UIColor.darkGray]
        let myString : NSAttributedString = NSAttributedString(string: string, attributes: attrsDictionary)
        return myString;
    }
}
