//
//  ArticleViewModel.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/9/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ArticleViewModel: class {
    var basicViewModel: BasicViewModel { get }
    var articles : BehaviorRelay<[ArticleInfo]> { get }
    func getArticlesWithLoadMore(loadMore: Bool, showIndicator: Bool)
    func deleteArticleAtIndex(index: NSInteger)
    var endLoadingAnimation: PublishSubject<Void> { get }
}
