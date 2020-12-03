//
//  AvatarImageViewModel.swift
//  Koibana
//
//  Created by Hien Pham on 10/9/20.
//  Copyright © 2020 Koibana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AvatarImageViewModel: class {
    var avatarUrlStr: BehaviorRelay<String?> { get }
    var defaultImage: BehaviorRelay<UIImage?> { get }
    var onTapImageView: PublishSubject<Void> { get }
    func didTapOnImageView()
}
