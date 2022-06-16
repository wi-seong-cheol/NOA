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
            cell.onData.onNext(cellModel)
            return cell
        case let .otherMessageCell(cellModel):
            let cell = tableview.dequeueReusableCell(withIdentifier: OtherMessageCell.identifier, for: indexPath) as! OtherMessageCell
            cell.onData.onNext(cellModel)
            cell.delegate = self
            return cell
        case let .myMessageCell(cellModel):
            let cell = tableview.dequeueReusableCell(withIdentifier: MyMessageCell.identifier, for: indexPath) as! MyMessageCell
            cell.onData.onNext(cellModel)
            return cell
        }
    }
    
    var oldContentSizeHeight: CGFloat = 0.0
    var nowContentSizeHeight: CGFloat = 0.0
    var more: Bool = false
    var viewModel: ChattingViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: ChattingViewModel = ChattingViewModel()) {
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
        print("-----------> \(self.tableView.contentSize.height)")

        configure()
        setupBindings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
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
        
        tableView.delegate = self
        messageTextView.delegate = self
        textViewSetupView(messageTextView)
        messageTextView.layer.cornerRadius = 4
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = UIColor(red: 112, green: 112, blue: 112).cgColor
        messageTextView.font = UIFont.NotoSansCJKkr(type: .regular, size: 12)
        self.hideKeyboard()
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        tableView.rx_reachedTop
            .skip(2)
            .map { _ in () }
            .subscribe(onNext: { _ in
                self.more = true
                self.viewModel.input.moreFetchList.onNext(())
            })
            .disposed(by: disposeBag)
        
        let didDisappear = rx.viewDidDisappear
            .map { _ in () }
        
        firstLoad
            .bind(to: self.viewModel.input.registerSocket,
                  self.viewModel.input.fetchList)
            .disposed(by: disposeBag)
        
        didDisappear
            .bind(to: self.viewModel.input.disconnect)
            .disposed(by: disposeBag)
        
        // MARK: - TextView Bind
        messageTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.message)
            .disposed(by: disposeBag)
        
        // MARK: - Message Send
        sendButton.rx.tap
            .bind(to: viewModel.input.sendMessage)
            .disposed(by: disposeBag)
        
        // MARK: - Socket IO
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------
//            .subscribe(onNext: { currentSize in
//                print("currentSize --> \(currentSize)")
//            })
//            .disposed(by: disposeBag)
        
        // MARK: - Message Bind
        viewModel.output.messages
            .do(onNext: { _ in
                if self.more {
                    print("-----------> 1")
                } else {
                    print("-----------> 2")
                    self.tableView.setContentOffset(CGPoint(x: 0, y : CGFloat.greatestFiniteMagnitude), animated: true)
                }

            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
                
        // MARK: - 에러 처리
        viewModel.output.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
}

extension ChattingViewController: OtherMessageDelegate {
    func didSelectedProfile(_ otherMessageCell: OtherMessageCell, detailButtonTappedFor userId: String) {
//        let storyboard = UIStoryboard(name:"Profile", bundle: nil)
//        let pushVC = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController")
//        self.navigationController?.pushViewController(pushVC, animated: true)
    }
}

//MARK: - textView 관련 메서드
extension ChattingViewController {
    func textViewSetupView(_ textView: UITextView) {
        textCheck(textView, "텍스트를 입력해주세요")
    }
    
    func textCheck(_ textView: UITextView, _ text: String) {
        if textView.text == text {
            textView.text = ""
            textView.textColor = UIColor.black
        } else if textView.text == "" {
            textView.text = text
            textView.textColor = UIColor.lightGray
        }
    }
}

//MARK: - UITextViewDelegate 관련 메서드
extension ChattingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetupView(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textViewSetupView(textView)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

//MARK: - UITableViewDelegate 관련 메서드
extension ChattingViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.more {
            self.more = false
            self.oldContentSizeHeight = self.tableView.contentSize.height
            viewModel.output.scroll
                .filter{ $0 }
                .subscribe(onNext: { _ in
    //                if self.more {
    //
                        let newContentSizeHeight = self.tableView.contentSize.height
                        print("-----------> \(self.oldContentSizeHeight)")
                        print("-----------> \(newContentSizeHeight)")
                        print("-----------> \(newContentSizeHeight - self.oldContentSizeHeight)")
                        self.more = false
                        self.tableView.setContentOffset(CGPoint(x: 0, y : newContentSizeHeight - self.oldContentSizeHeight), animated: false)
    //                }
                })
                .disposed(by: disposeBag)
        }
    }
}
