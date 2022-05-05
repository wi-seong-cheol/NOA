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
import SocketIO
import RxKeyboard

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
        sendButton.rx.tap
            .bind { [weak self] in
                print("click")
            }
            .disposed(by: disposeBag)
    }
    
    @objc func hideKeyboard() {
        messageTextView.resignFirstResponder()
    }
}
