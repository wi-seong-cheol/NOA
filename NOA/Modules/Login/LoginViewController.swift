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
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var privateKey: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var shape: [UIView]!
    
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
    
    let viewModel: LoginViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: LoginViewModelType = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = LoginViewModel()
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
        for s in shape {
            s.layer.cornerRadius = 4
            s.layer.borderWidth = 1
            s.layer.borderColor = UIColor(red: 204, green: 204, blue: 204).cgColor
        }
        nickname.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        privateKey.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        password.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        login.applyBorderGradient(colors: [UIColor(red: 225, green: 229, blue: 245).cgColor,
                                      UIColor(red: 154, green: 173, blue: 224).cgColor,
                                       UIColor(red: 237, green: 106, blue: 201).cgColor])
        signUp.applyGradient(colors: [UIColor(red: 225, green: 229, blue: 245).cgColor,
                                      UIColor(red: 154, green: 173, blue: 224).cgColor,
                                       UIColor(red: 237, green: 106, blue: 201).cgColor])
        login.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        signUp.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        nickname.rx.text
            .orEmpty
            .map{ $0 as String }
            .bind(to: viewModel.nickname)
            .disposed(by: disposeBag)
        
        privateKey.rx.text
            .orEmpty
            .map{ $0 as String }
            .bind(to: viewModel.privateKey)
            .disposed(by: disposeBag)
        
        password.rx.text
            .orEmpty
            .map{ $0 as String }
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        login.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.login)
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
        viewModel.start
            .filter{ $0 }
            .bind { [weak self] _ in
                let keyWindow = UIApplication.shared.connectedScenes
                        .filter({$0.activationState == .foregroundActive})
                        .map({$0 as? UIWindowScene})
                        .compactMap({$0})
                        .first?.windows
                        .filter({$0.isKeyWindow}).first
                let storyboard = UIStoryboard(name:"Main", bundle: nil)
                if let viewController = storyboard.instantiateViewController(identifier: "SplashViewController") as? SplashViewController {
                    keyWindow?.replaceRootViewController(viewController, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------

        // Alert
        viewModel.alertMessage
            .skip(1)
            .map{ $0 as String }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog(message)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
}
