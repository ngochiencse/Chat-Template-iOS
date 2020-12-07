//
//  UITableView+Utils.swift
//  ChatTemplate
//
//  Created by Hien Pham on 5/31/20.
//  Copyright © 2020 WITHOUT. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func scrollToBottom(animated: Bool) {
        let lastSection: Int = (dataSource?.numberOfSections?(in: self) ?? 1) - 1
        guard let numberOfRows: Int = dataSource?.tableView(self, numberOfRowsInSection: lastSection), numberOfRows > 0 else { return }
        let rowIndex: Int = numberOfRows - 1
        
        if rowIndex >= 0 {
            let indexPath: IndexPath = IndexPath(row: rowIndex, section: lastSection)
            scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
}
