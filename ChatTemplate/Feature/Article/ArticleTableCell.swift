//
//  ArticleTableCell.swift
//  ios_template_project
//
//  Created by Hien Pham on 8/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import UIKit
import SDWebImage

class ArticleTableCell: UITableViewCell {
    @IBOutlet private weak var test: UILabel!
    @IBOutlet private weak var lbCategoryName: UILabel!
    @IBOutlet private weak var iconPen: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var thumbnail: UIImageView!
    @IBOutlet private weak var imageRecommendIcon: UIImageView!
    @IBOutlet private weak var imageNewIcon: UIImageView!
    @IBOutlet private weak var horizantalCategoryConstraint: NSLayoutConstraint!
    
    public func displayWithArticle(articleInfo: ArticleInfo) {
        if (articleInfo.imagePath != nil && articleInfo.imagePath!.count > 0) {
            self.thumbnail.sd_setImage(with: URL(string: articleInfo.imagePath!), placeholderImage: nil, options: SDWebImageOptions.retryFailed)
        } else {
            self.thumbnail.image = UIImage(named: "no_image")
        }
        
        self.lbCategoryName.text = articleInfo.category
        
        self.titleLabel.text = articleInfo.title
        self.titleLabel.sizeToFit()
        self.bodyLabel.text = articleInfo.body
        self.bodyLabel.sizeToFit()
        
        self.imageNewIcon.isHidden = false;
        self.horizantalCategoryConstraint.constant = 55.0;
    }
}
