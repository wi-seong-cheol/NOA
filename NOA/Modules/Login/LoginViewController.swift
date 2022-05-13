//
//  LoginViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/05/11.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit

class  LoginViewController: UIViewController {
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var privacyKeyLabel: UILabel!
    @IBOutlet weak var privacyKey: UITextField!
    @IBOutlet weak var shape: UIView!
    
    var _mnemonics: String = ""
    
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
    
    let viewModel: HomeViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: HomeViewModelType = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = HomeViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupBindings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let identifier = segue.identifier ?? ""
//
//        if identifier == "HomeDetailSegue",
//           let selectedFeed = sender as? Lecture,
//           let feedVC = segue.destination as? HomeDetailViewController {
//            let feedViewModel = HomeDetailViewModel(selectedFeed)
//            feedVC.viewModel = feedViewModel
//        }
    }
}

extension LoginViewController {
    // MARK: - UI Setting
    func configure() {
        privacyKeyLabel.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        privacyKey.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        shape.layer.cornerRadius = 4
        shape.layer.borderWidth = 1
        shape.layer.borderColor = UIColor(red: 204, green: 204, blue: 204).cgColor
        login.applyBorderGradient(colors: [UIColor(red: 225, green: 229, blue: 245).cgColor,
                                      UIColor(red: 154, green: 173, blue: 224).cgColor,
                                       UIColor(red: 237, green: 106, blue: 201).cgColor])
        signUp.applyGradient(colors: [UIColor(red: 225, green: 229, blue: 245).cgColor,
                                      UIColor(red: 154, green: 173, blue: 224).cgColor,
                                       UIColor(red: 237, green: 106, blue: 201).cgColor])
        login.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        signUp.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
//        createWallet.rx.tap
//            .throttle(500, scheduler: MainScheduler)
//

        login.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                
            })
            .disposed(by: disposeBag)
        
        signUp.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { [weak self] in
                self?.performSegue(withIdentifier: "signUpSegue", sender: nil)
            }
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     Page Move
        // ------------------------------

        // ------------------------------
        //     OUTPUT
        // ------------------------------

        // 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
}
