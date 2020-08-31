//
//  TutorialViewModel.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/9/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation
import UIKit

protocol TutorialViewModel: class {
    var delegate: TutorialViewModelDelegate? { get set }
    var imageArray : Array<UIImage> { get }
}

protocol TutorialViewModelDelegate: class {
    func tutorialGoNext(tutorial : TutorialViewModel)
}
