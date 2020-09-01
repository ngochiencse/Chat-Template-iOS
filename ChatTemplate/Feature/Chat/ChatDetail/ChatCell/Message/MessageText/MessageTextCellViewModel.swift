//
//  MessageTextCellViewModel.swift
//  WITHOUT_IOS
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

protocol MessageTextCellViewModel: MessageCellViewModel {
    var text: String? { get }
}
