//
//  ChatListViewController.swift
//  ChatTemplate
//
//  Created by Hien Pham on 8/31/20.
//  Copyright © 2020 Hien Pham. All rights reserved.
//

import UIKit

class ChatListViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func goToChatScreen(_ sender: Any) {
        let viewModel: ChatScreenViewModel = ChatScreenViewModelMock()
        let vc: ChatScreenViewController = ChatScreenViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
