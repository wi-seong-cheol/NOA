//
//  SignUpViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/05/16.
//

import UIKit

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit
import web3swift

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var start: UIBarButtonItem!
    @IBOutlet var titleLabel: [UILabel]!
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var check: UIButton!
    @IBOutlet var warning: [UILabel]!
    @IBOutlet var shape: [UIView]!
    @IBOutlet weak var copyKey: UIButton!
    @IBOutlet weak var createWallet: UIButton!
    @IBOutlet weak var connectWallet: UIButton!
    @IBOutlet weak var privateKeyLabel: UILabel!
    
    lazy var indicator: NVActivityIndicatorView = {
        let indicator = NVActivityIndicatorView(
            frame: CGRect(
                x: self.view.frame.width/2 - 25,
                y: self.view.frame.height/2 - 25,
                width: 50,
                height: 50),
            type: .circleStrokeSpin,
            color: .black,
            padding: 0)
        
        indicator.center = self.view.center
                
        // 기타 옵션
        indicator.color = UIColor(red: 237, green: 106, blue: 201)
        
        return indicator
    }()
    
    let viewModel: SignUpViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: SignUpViewModel = SignUpViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = SignUpViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupBindings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SignUpViewController {
    // MARK: - UI Setting
    func configure() {
        view.addSubview(indicator)
        for t in titleLabel {
            t.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        }
        nickname.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        check.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 12)
        for s in shape {
            s.layer.cornerRadius = 4
            s.layer.borderWidth = 1
            s.layer.borderColor = UIColor(red: 204, green: 204, blue: 204).cgColor
        }
        for w in warning {
            w.font = UIFont.NotoSansCJKkr(type: .medium, size: 10)
        }
    
        createWallet.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        connectWallet.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        createWallet.applyBorderGradient(colors: [UIColor(red: 225, green: 229, blue: 245).cgColor,
                                          UIColor(red: 154, green: 173, blue: 224).cgColor,
                                           UIColor(red: 237, green: 106, blue: 201).cgColor])
        connectWallet.applyGradient(colors: [UIColor(red: 225, green: 229, blue: 245).cgColor,
                                          UIColor(red: 154, green: 173, blue: 224).cgColor,
                                           UIColor(red: 237, green: 106, blue: 201).cgColor])
        self.hideKeyboard()
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        check.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
//            .do(onNext: { [weak self] in
//                self?.viewModel.nickname.accept((self?.nickname.text)!)
//            })
            .bind(to: viewModel.input.check)
            .disposed(by: disposeBag)
        
        createWallet.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showPasswordAlert()
            })
            .disposed(by: disposeBag)

        connectWallet.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showImportAlert()
            })
            .disposed(by: disposeBag)
        
        copyKey.rx.tap
            .subscribe(onNext: { [weak self] in
                UIPasteboard.general.string = self?.privateKeyLabel.text
                self?.OKDialog("개인키가 복사되었습니다.")
            })
            .disposed(by: disposeBag)
        
        start.rx.tap
            .bind(to: viewModel.input.register)
            .disposed(by: disposeBag)
        
        nickname.rx.text
            .orEmpty
            .bind(to: viewModel.input.nickname)
            .disposed(by: disposeBag)
        

        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
        // PrivateKey
        viewModel.output.privateKey
            .map{ $0 as String}
            .drive(privateKeyLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Activated
        viewModel.output.activated
                .skip(1)
                .map { $0 }
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {[weak self] finished in
                    print("-> \(finished)")
                    if finished {
                        self?.indicator.startAnimating()
                    } else {
                        self?.indicator.stopAnimating()
                    }
                })
                .disposed(by: disposeBag)
        
        // Alert
        viewModel.output.alertMessage
            .skip(1)
            .map{ $0 as String }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog(message)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        viewModel.output.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
}

extension SignUpViewController {
    fileprivate func showImportAlert() {
        let alert = UIAlertController(title: "MyWeb3Wallet", message: "", preferredStyle: .alert)
        alert.addTextField { textfied in
            textfied.placeholder = "Enter mnemonics/private Key"
        }
        let mnemonicsAction = UIAlertAction(title: "Mnemonics", style: .default) { [weak self] _ in
            print("Clicked on Mnemonics Option")
            guard let mnemonics = alert.textFields?[0].text else { return }
            print(mnemonics)
            
            Observable.just(mnemonics)
                .subscribe(onNext: { key in
                    self?.viewModel.input.key.onNext(key)
                })
                .disposed(by: (self?.disposeBag)!)
            
            Observable<Void>.just(Void())
                .subscribe(onNext: { _ in
                    self?.viewModel.input.importWalletMnemonics.onNext(Void())
                })
                .disposed(by: (self?.disposeBag)!)
        }
        let privateKeyAction = UIAlertAction(title: "Private Key", style: .default) { [weak self] _ in
            print("Clicked on Private Key Wallet Option")
            guard let privateKey = alert.textFields?[0].text else { return }
            print(privateKey)
            Observable.just(privateKey)
                .subscribe(onNext: { key in
                    self?.viewModel.input.key.onNext(key)
                })
                .disposed(by: (self?.disposeBag)!)
            
            Observable<Void>.just(Void())
                .subscribe(onNext: { _ in
                    self?.viewModel.input.importWalletPrivateKey.onNext(Void())
                })
                .disposed(by: (self?.disposeBag)!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(mnemonicsAction)
        alert.addAction(privateKeyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPasswordAlert() {
        let alert = UIAlertController(title: "Password", message: "", preferredStyle: .alert)
        alert.addTextField { textfied in
            textfied.isSecureTextEntry = true
            textfied.placeholder = "Password"
        }
        alert.addTextField { textfied in
            textfied.isSecureTextEntry = true
            textfied.placeholder = "Repeat Password"
        }
        let createWallet = UIAlertAction(title: "지갑 생성하기", style: .default) { [weak self] _ in
            print("Clicked on Create Wallet")
            
            guard let pw = alert.textFields?[0].text,
                  let repeatPW = alert.textFields?[1].text else {
                return
            }
            if pw != repeatPW {
                self?.OKDialog("비밀번호가 일치하지 않습니다.")
                return
            }
            
            if !((self?.isValidPass(pw))!) {
                self?.OKDialog("8~15자리 비밀번호를 입력해주세요.")
                return
            }
            alert.textFields?[0].rx.text
                .orEmpty
                .bind(to: (self?.viewModel.input.password)!)
                .disposed(by: (self?.disposeBag)!)
            
            Observable<Void>.just(Void())
                .subscribe(onNext: {
                    self?.viewModel.input.createWallet.onNext(Void())
                })
                .disposed(by: (self?.disposeBag)!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(createWallet)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidPass(_ pass: String) -> Bool{
        let passRegEx = "^[a-zA-Z0-9#?!@$%^&*-]{8,15}$"
        let passTest = NSPredicate(format: "SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: pass)
    }
}
