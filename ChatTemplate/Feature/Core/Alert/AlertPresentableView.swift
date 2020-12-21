//
//  AlertPresentableView.swift
//  AlertSample
//
//  Created by Isa Aliev on 10.10.2018.
//  Copyright © 2018 IsaAliev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

protocol AlertPresentableView {
    var alertViewModel: AlertPresentableViewModel { get }
}

extension AlertPresentableView where Self: UIViewController {
    func bindToAlerts() {
        bindToAlertViewModel(alertViewModel)
    }

    func bindToAlertViewModel(_ alertViewModel: AlertPresentableViewModel) {
        alertViewModel.alertModel.observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (model: AlertModel?) in
                guard let model = model else {
                    return
                }

                let alert = AlertBuilder.buildAlertController(for: model)
                self?.present(alert, animated: true, completion: nil)
            }).disposed(by: rx.disposeBag)
    }
}
