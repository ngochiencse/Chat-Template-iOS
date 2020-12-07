//
//  MessageTextCellViewModel.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

protocol MessageTextCellViewModel: MessageCellViewModel {
    var attributedText: NSAttributedString? { get }
}
