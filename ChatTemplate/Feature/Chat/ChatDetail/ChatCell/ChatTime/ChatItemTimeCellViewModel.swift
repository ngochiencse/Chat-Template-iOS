//
//  ChatItemTimeCellViewModel.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation

protocol ChatItemTimeCellViewModel: ChatItemCellViewModel, ChatItemAdvancedViewModel {
    var time: Date? { get }
}
