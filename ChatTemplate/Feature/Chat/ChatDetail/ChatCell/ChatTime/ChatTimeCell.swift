//
//  TimeTableCell.swift
//  Tavi
//
//  Created by Hien Pham on 12/15/17.
//  Copyright © 2017 Bravesoft VN. All rights reserved.
//

import UIKit

class ChatTimeCell: ChatCell {
    @IBOutlet weak private var label : UILabel!
    
    override var viewModel: ChatItemCellViewModel? {
        didSet {
            if viewModel != nil && (viewModel is ChatItemTimeCellViewModel) == false {
                fatalError("Wrong viewModel type! Current is:\(String(describing: type(of: viewModel))). Must be: MessageTextCellViewModel")
            }
            
            let viewModel = self.viewModel as? ChatItemTimeCellViewModel
            displayWithViewModel(viewModel)
        }
    }
    
    private func displayWithViewModel(_ viewModel: ChatItemTimeCellViewModel?) {
        self.label.text = viewModel?.time?.string(format: "YYYY年MM月dd日")
    }
}
