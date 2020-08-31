//
//  SplashScreenViewModel.swift
//  ios_template_project
//
//  Created by Hien Pham on 11/9/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//

import Foundation

enum SplashScreenNextAction: Int {
    case tutorialScreen = 0
    case loginScreen
    case homeScreen
}

protocol SplashScreenViewModelDelegate: class {
    func splashScreen(splashScreen : SplashScreenViewModel, didFinishWithNextAction nextAction: SplashScreenNextAction)
}

protocol SplashScreenViewModel: class {
    var delegate: SplashScreenViewModelDelegate? { get set }
    func checkLocalData()
}

