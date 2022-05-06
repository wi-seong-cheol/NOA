//
//  ChattingViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit
import RxKeyboard
import RxDataSources

class ChattingViewController: UIViewController {
    
    static let identifier = "ChattingViewController"
    @IBOutlet weak var inputContainerBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var indicator: NVActivityIndicatorView = {
        let indicator = NVActivityIndicatorView(
            frame: CGRect(
                x: self.view.frame.width/2 - 25,
                y: self.view.frame.height/2 - 25,
                width: 50,
                height: 50),
            type: .ballScaleMultiple,
            color: .black,
            padding: 0)
        
        indicator.center = self.view.center
                
        // 기타 옵션
        indicator.color = .purple
        
        indicator.stopAnimating()
        return indicator
    }()
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<MessageSection> {
        [weak self] dataSource, tableview, indexPath, item in
        switch item {
        case let .noticeCell(cellModel):
            let cell = tableview.dequeueReusableCell(withIdentifier: NoticeCell.identifier, for: indexPath) as! NoticeCell
            return cell
        case let .dateCell(cellModel):
            let cell = tableview.dequeueReusableCell(withIdentifier: DateCell.identifier, for: indexPath) as! DateCell
            return cell
        case let .otherMessageCell(cellModel):
            let cell = tableview.dequeueReusableCell(withIdentifier: OtherMessageCell.identifier, for: indexPath) as! OtherMessageCell
            cell.onData.onNext(cellModel)
            return cell
        case let .myMessageCell(cellModel):
            let cell = tableview.dequeueReusableCell(withIdentifier: MyMessageCell.identifier, for: indexPath) as! MyMessageCell
            cell.onData.onNext(cellModel)
            return cell
        }
    }
    
    var viewModel: ChattingViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: ChattingViewModelType = ChattingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = ChattingViewModel()
        super.init(coder: aDecoder)
    }
    
    // MARK: life cylce
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
//        self.tabBarController?.selectedIndex = 1
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChattingViewController {
    // MARK: - UI Setting
    func configure() {
        let window = UIApplication.shared.windows.first
        let extra = window!.safeAreaInsets.bottom
        
        // MARK: - Setting Keyboard
        RxKeyboard.instance.visibleHeight
            .skip(1)    // 초기 값 버리기
            .distinctUntilChanged()
            .do(onNext: { _ in
                self.tableView.setContentOffset(CGPoint(x: 0, y : CGFloat.greatestFiniteMagnitude), animated: true)
            })
            .drive(onNext: { keyboardVisibleHeight in
                UIView.animate(withDuration: 0) {
                    if keyboardVisibleHeight == 0 {
                        self.inputContainerBottomContraint.constant = 0
                    } else {
                        self.inputContainerBottomContraint.constant = keyboardVisibleHeight - extra
                    }
                }
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        
        let tapGuesterHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tableView.addGestureRecognizer(tapGuesterHideKeyboard)
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        let disappear = rx.viewDidDisappear
            .take(1)
            .map { _ in () }
        
        firstLoad
            .debug()
            .bind(to: self.viewModel.register)
            .disposed(by: disposeBag)
        
        disappear
            .bind(to: self.viewModel.disconnect)
            .disposed(by: disposeBag)
        
        // MARK: - Message Bind
        viewModel.messages
            .do(onNext: { _ in
                self.tableView.setContentOffset(CGPoint(x: 0, y : CGFloat.greatestFiniteMagnitude), animated: true)
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // MARK: - TextView Bind
        messageTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.message)
            .disposed(by: disposeBag)
        
        // MARK: - Message Send
        sendButton.rx.tap
            .bind(to: viewModel.sendMessage)
            .disposed(by: disposeBag)
        
        // MARK: - Socket IO
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------

        // MARK: - 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
    
    @objc func hideKeyboard() {
        messageTextView.resignFirstResponder()
    }
}
