//
//  File.swift
//  ios_template_project
//
//  Created by Hien Pham on 9/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import NSObject_Rx

class ArticleViewModelImpl: NSObject, ArticleViewModel {
    private(set) var basicViewModel: BasicViewModel
    private(set) var articles : BehaviorRelay<[ArticleInfo]> = BehaviorRelay(value: [])
    private(set) var showsInfiniteScrolling: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let endLoadingAnimation: PublishSubject<Void> = PublishSubject()
    let api: Provider<MultiTarget>
    let limit: Int = 50
    init(basicViewModel: BasicViewModel = BasicViewModelImpl(), api: Provider<MultiTarget> = ProviderAPIWithRefreshToken<MultiTarget>()) {
        self.basicViewModel = basicViewModel
        self.api = api
        super.init()
    }

    func getArticlesWithLoadMore(loadMore: Bool, showIndicator: Bool) {
        if showIndicator == true {
            basicViewModel.showIndicator.accept(true)
        }
        
        let offset = loadMore ? articles.value.count : 0
        api.request(MultiTarget(SampleTarget.articleList(limit: limit, offset: offset)))
            .map([ArticleInfo].self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
            .subscribe {[weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let value):
                    var mutableArticles = Array(self.articles.value)
                    if loadMore == false {
                        mutableArticles.removeAll()
                    }
                    mutableArticles.insert(contentsOf: value, at: mutableArticles.count)
                    self.articles.accept(mutableArticles)
                    self.showsInfiniteScrolling.accept(value.count < self.limit)
                case .error(_):
                    break
                }
                self.basicViewModel.showIndicator.accept(false)
                self.endLoadingAnimation.onNext(())
        }.disposed(by: rx.disposeBag)
    }
    
    func deleteArticleAtIndex(index: NSInteger) {
        let articleInfo = self.articles.value[index];
        if let articleId = articleInfo.id {
            basicViewModel.showProgressHUD.accept(true)
            
            api.request(MultiTarget(SampleTarget.deleteArticle(id: articleId))).subscribe({[weak self] (event) in
                guard let self = self else { return }
                var mutableArticles = Array(self.articles.value)
                mutableArticles.remove(at: index)
                self.articles.accept(mutableArticles)
                self.basicViewModel.showProgressHUD.accept(false)
            }).disposed(by: rx.disposeBag)
        }
    }
}
