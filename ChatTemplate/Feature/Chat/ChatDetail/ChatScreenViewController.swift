//
//  MycleChatScreenViewController.swift
//  Tavi
//
//  Created by Hien Pham on 12/8/17.
//  Copyright © 2017 Bravesoft VN. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import RxSwift
import RxCocoa
import Tatsi
import SDWebImage
import RSKGrowingTextView

private let LOADMORECELLHEIGHT: CGFloat = 40
private let CHATTIMECELLHEIGHT: CGFloat = 40

private let messageTextReuseId: String = String(describing: MessageTextCell.self)
private let messageImageReuseId: String = String(describing: MessageImageCell.self)
private let chatTimeReuseId: String = String(describing: ChatTimeCell.self)

class ChatScreenViewController: BaseViewController {
    let viewModel: ChatScreenViewModel

    // Send message implementation
    @IBOutlet weak private var textView: UITextView!
    @IBOutlet weak private var sendMessageButton: UIButton!

    // Display list message implementation
    @IBOutlet weak private var tableView: UITableView!

    // Loading view
    @IBOutlet weak private var viewToShowProgressHUD: UIView!

    // Keyboard Implementation
    @IBOutlet private var accessoryInput: UIView!
    let inputLayout: InputLayoutViewController
    @IBOutlet weak var textViewContainerBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak private var accessoryInputContainer: UIView!

    @IBOutlet weak var friendlyNameLabel: UILabel!
    @IBOutlet weak var otherAvatarImageView: UIImageView!
    @IBOutlet weak var iconOnline: UIImageView!

    private let tmpTextCell: MessageTextCell = Bundle.main.loadNibNamed(messageTextReuseId,
                                                                        owner: nil,
                                                                        options: nil)?.first as? MessageTextCell
        ?? MessageTextCell()
    private let tmpImageCell: MessageImageCell = Bundle.main.loadNibNamed(messageImageReuseId,
                                                                          owner: nil,
                                                                          options: nil)?.first as? MessageImageCell
        ?? MessageImageCell()

    init(viewModel: ChatScreenViewModel, inputLayout: InputLayoutViewController = InputLayoutViewControllerImpl()) {
        self.viewModel = viewModel
        self.inputLayout = inputLayout
        super.init(basicViewModel: viewModel.basicViewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBarHidden = true
        setUpChatScreen()
        bindToViewModel()
        bindingMessage()
        viewModel.getMessages(loadMore: false)
    }

    // MARK: - Set up

    private func setUpChatScreen() {
        title = "サーフィンに乗れるようになろう。"
        setUpInputView()
        setupTableView()
    }

    private func setUpInputView() {
        accessoryInputContainer.addSubview(accessoryInput)
        accessoryInput.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 6)
        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.minimumLineHeight = 18
        style.maximumLineHeight = 18
        textView.typingAttributes = [
            NSAttributedString.Key.font: self.textView?.font ?? UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.paragraphStyle: style
        ]

        if let textView = textView as? RSKGrowingTextView {
            textView.maximumNumberOfLines = 5
            textView.heightChangeAnimationDuration = 0.15
            textView.attributedPlaceholder = NSAttributedString(string: "メッセージ入力", attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor(white: 0.67, alpha: 1.0)
            ])
        }

        guard let growingTextView: RSKGrowingTextView = textView as? RSKGrowingTextView else {
            return
        }
        inputLayout.setUp(container: view, textView: growingTextView, scrollView: tableView,
                          textViewContainerBottomSpaceConstraint: textViewContainerBottomSpaceConstraint,
                          minTextViewHeight: 40)
    }

    private func setupTableView() {
        let cellReuseIds: [String] = [
            messageTextReuseId,
            messageImageReuseId,
            chatTimeReuseId
        ]
        for cellReuseId: String in cellReuseIds {
            tableView.register(UINib(nibName: cellReuseId, bundle: nil), forCellReuseIdentifier: cellReuseId)
        }

        let footer: UIView = UIView()
        footer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2)
        tableView.tableFooterView = footer

        tableView.separatorStyle = .none

        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = 44

        tableView.allowsSelection = false

        tableView.isHidden = true
    }

    func bindToViewModel() {
        viewModel.showsInfiniteScrolling.observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (showsInfiniteScrolling) in
                guard let self = self else { return }
                if showsInfiniteScrolling == true {
                    guard let header: LoadMoreHeaderFooterView =
                            Bundle.main.loadNibNamed(String(describing: LoadMoreHeaderFooterView.self),
                                                     owner: nil,
                                                     options: nil)?.first as? LoadMoreHeaderFooterView
                    else {
                        return
                    }
                    header.loadingIcon?.startAnimating()
                    header.loadingIcon?.style = .gray
                    header.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: LOADMORECELLHEIGHT)
                    self.tableView.tableHeaderView = header
                } else {
                    let header: UIView = UIView()
                    header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2)
                    self.tableView.tableHeaderView = header
                }
            }).disposed(by: rx.disposeBag)

        viewModel.didFinishLoadFirstTime.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            UIView.setAnimationsEnabled(false)
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            DispatchQueue.main.async(execute: {
                self.tableView.scrollToBottomByContentOffset(animated: false)
                self.tableView.isHidden = false
            })
        }).disposed(by: rx.disposeBag)

        viewModel.didFinishLoadMore.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            var contentOffset: CGPoint = self.tableView.contentOffset
            let bottomSpace: CGFloat = self.tableView.contentSize.height - contentOffset.y
            UIView.setAnimationsEnabled(false)
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            contentOffset.y = max(self.tableView.contentSize.height - bottomSpace, 0)
            self.tableView.setContentOffset(contentOffset, animated: false)
        }).disposed(by: rx.disposeBag)
    }

    func bindingMessage() {
        viewModel.onSendMessagesStart.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            UIView.setAnimationsEnabled(false)
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            DispatchQueue.main.async(execute: {
                self.tableView.scrollToBottomByContentOffset(animated: true)
                self.tableView.isHidden = false
            })
        }).disposed(by: rx.disposeBag)
        viewModel.onSendMessagesFinish.observeOn(MainScheduler.instance).subscribe(onError: {[weak self] (_) in
            self?.tableView.reloadData()
        }).disposed(by: rx.disposeBag)

        viewModel.onReceiveMessages.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            guard let self = self else { return }
            let isScrollAtBottom: Bool = self.tableView.isScrollPositionAtBottom
            UIView.setAnimationsEnabled(false)
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            DispatchQueue.main.async(execute: {
                if isScrollAtBottom {
                    self.tableView.scrollToBottomByContentOffset(animated: true)
                }
            })
        }).disposed(by: rx.disposeBag)

        textView.rx.text.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (text) in
            guard let self = self else { return }
            let cleanedText: String? = text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.sendMessageButton.isEnabled = !(cleanedText?.isEmpty ?? true)
        }).disposed(by: rx.disposeBag)
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func sendButtonClicked(_ sender: Any) {
        viewModel.sendText(textView.text)
        textView.text = nil
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: textView)
    }

    @IBAction func actionCamera(_ sender: Any) {
        getImage(fromSourceType: .camera)
    }

    @IBAction func actionPhoto(_ sender: Any) {
        var config = TatsiConfig.default
        config.singleViewMode = true
        config.showCameraOption = true
        config.supportedMediaTypes = [.image]
        config.firstView = .userLibrary
        config.maxNumberOfSelections = 5
        let pickerViewController = TatsiPickerViewController(config: config)
        pickerViewController.pickerDelegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }

    @IBAction func actionPreviewUsserInfo(_ sender: Any) {
        //        let viewModel: ProfileDetailFormViewModel =
        //            ProfileDetailFormViewModelImpl(user: self.viewModel.otherUser.value)
        //        let vc: ProfileDetailViewController = ProfileDetailViewController(viewModel: viewModel)
        //        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatScreenViewController: TatsiPickerViewControllerDelegate {
    func pickerViewController(_ pickerViewController: TatsiPickerViewController, didPickAssets assets: [PHAsset]) {
        pickerViewController.dismiss(animated: true, completion: nil)
        viewModel.sendImages(assets)
    }
}

extension ChatScreenViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    // MARK: - UIImagePickerViewDelegate.
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.viewModel.sendImage(image)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

extension ChatScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemViewModel: ChatItemCellViewModel = viewModel.chatItems[indexPath.row]
        let cell: ChatCell
        switch itemViewModel.itemType {
        case .message:
            let messageViewModel: MessageCellViewModel! = itemViewModel as? MessageCellViewModel
            switch messageViewModel.messageType {
            case .text:
                let cellText: MessageTextCell! = tableView.dequeueReusableCell(withIdentifier: messageTextReuseId,
                                                                               for: indexPath) as? MessageTextCell
                cellText.delegate = self
                cell = cellText
            case .image:
                let imageCell: MessageImageCell! = tableView.dequeueReusableCell(withIdentifier: messageImageReuseId,
                                                                                 for: indexPath) as? MessageImageCell
                imageCell.delegate = self
                cell = imageCell
            }
        case .time:
            let timeCell: ChatCell! = tableView.dequeueReusableCell(withIdentifier: chatTimeReuseId,
                                                                    for: indexPath) as? ChatCell
            cell = timeCell
        }
        cell.viewModel = itemViewModel
        return cell
    }
}

extension ChatScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let itemViewModel: ChatItemCellViewModel = viewModel.chatItems[indexPath.row]
        switch itemViewModel.itemType {
        case .message:
            let cell: ChatCell
            guard let messageViewModel: MessageCellViewModel = itemViewModel as? MessageCellViewModel else {
                return 0
            }
            switch messageViewModel.messageType {
            case .text:
                cell = tmpTextCell
            case .image:
                cell = tmpImageCell
            }
            cell.viewModel = itemViewModel
            let height: CGFloat = cell.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width,
                                                                      height: UIView.layoutFittingExpandedSize.height),
                                                               withHorizontalFittingPriority: .required,
                                                               verticalFittingPriority: .fittingSizeLevel).height
            return height
        case .time:
            return CHATTIMECELLHEIGHT
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= scrollView.contentInset.top - scrollView.contentInset.bottom {
            viewModel.getMessages(loadMore: true)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}

extension ChatScreenViewController: MessageCellDelegate {
    func messageCellDidClicked(_ messageCell: MessageCell) {
        guard
            let cellViewModel: MessageImageCellViewModel = messageCell.viewModel as? MessageImageCellViewModel,
            let urlString = cellViewModel.imageUrl.value else { return }
        let viewController = ChatDetailViewPhotoViewController(viewModel:
                                                                ChatDetailViewPhotoViewModelImpl(urlString: urlString))
        self.present(viewController, animated: true, completion: nil)
    }
}
