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
    
    var _walletAddress: String = ""
    
    var _privateKey: String {
        set{
            DispatchQueue.main.async {
                self.privateKeyLabel.text = newValue
            }
        }
        get {
            return self._privateKey
        }
    }
    
    var _mnemonics: String = ""
    var password: String = ""
    
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
        //     Page Move
        // ------------------------------

        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
        
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
    fileprivate func showImportAlert(){
        let alert = UIAlertController(title: "MyWeb3Wallet", message: "", preferredStyle: .alert)
        alert.addTextField { textfied in
            textfied.placeholder = "Enter mnemonics/private Key"
        }
        let mnemonicsAction = UIAlertAction(title: "Mnemonics", style: .default) { _ in
            print("Clicked on Mnemonics Option")
            guard let mnemonics = alert.textFields?[0].text else { return }
            print(mnemonics)
            
            self.indicator.startAnimating()
            self.importWalletWith(mnemonics: mnemonics) { [weak self] message in
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    self?.OKDialog(message)
                }
            }
        }
        let privateKeyAction = UIAlertAction(title: "Private Key", style: .default) { _ in
            print("Clicked on Private Key Wallet Option")
            guard let privateKey = alert.textFields?[0].text else { return }
            print(privateKey)
            self.indicator.startAnimating()
            self.importWalletWith(privateKey: privateKey) { [weak self] message in
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    self?.OKDialog(message)
                }
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(mnemonicsAction)
        alert.addAction(privateKeyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func importWalletWith(privateKey: String, _ completion: @escaping (String) -> Void){
        DispatchQueue.global(qos: .background).async { [weak self] in
            let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let dataKey = Data.fromHex(formattedKey) else {
                completion("Please enter a valid Private key")
                return
            }
            do {
                let keystore =  try EthereumKeystoreV3(privateKey: dataKey)
                if let myWeb3KeyStore = keystore {
                    let manager = KeystoreManager([myWeb3KeyStore])
                    let address = keystore?.addresses?.first
#if DEBUG
                    print("Address :::>>>>> ", address as Any)
                    print("Address :::>>>>> ", manager.addresses as Any)
#endif
                    self?._privateKey = privateKey
                    self?.viewModel.input.walletAddress.onNext(address!.address)
                    
                    completion("지갑이 생성되었습니다. 개인키를 복사하여 저장해주세요.")
                } else {
                    completion("Keystore를 가져오지 못했습니다.")
                }
            } catch {
#if DEBUG
                print("error creating keyStrore")
                print("Private key error.")
#endif
                completion("Please enter correct Private key")
            }
        }
    }
    
    func importWalletWith(mnemonics: String, _ completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let walletAddress = try? BIP32Keystore(mnemonics: mnemonics , prefixPath: "m/44'/77777'/0'/0")
            print(walletAddress?.addresses as Any)
            self?._walletAddress = "\(walletAddress?.addresses?.first?.address ?? "0x")"
            do {
                let password = "web3swift"
                let mnemonics = "fine have legal roof fury bread egg knee wrong idea must edit" // Some mnemonic phrase
                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                
                let address = keystore.addresses!.first!.address
                let keystoreManager: KeystoreManager
                keystoreManager = KeystoreManager([keystore])
                
                let ethereumAddress = EthereumAddress(address)!
                let pkData = try keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
                self?._privateKey = pkData
                self?.viewModel.input.walletAddress.onNext(address)
                completion("지갑이 생성되었습니다. 개인키를 복사하여 저장해주세요.")
            } catch {
                completion("privateKey를 가져오지 못헀습니다.")
            }
        }
    }
}
extension SignUpViewController {
    func isValidPass(_ pass: String) -> Bool{
        let passRegEx = "^[a-zA-Z0-9#?!@$%^&*-]{8,15}$"
        let passTest = NSPredicate(format: "SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: pass)
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
        let createWallet = UIAlertAction(title: "지갑 생성하기", style: .default) { _ in
            print("Clicked on Create Wallet")
            
            guard let pw = alert.textFields?[0].text,
                  let repeatPW = alert.textFields?[1].text else {
                return
            }
            if pw != repeatPW {
                self.OKDialog("비밀번호가 일치하지 않습니다.")
                return
            }
            
            if !self.isValidPass(pw) {
                self.OKDialog("8~15자리 비밀번호를 입력해주세요.")
                return
            }
            self.password = pw
            
            self.indicator.startAnimating()
            self.createMnemonics() { [weak self] message in
                print(message)
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    self?.OKDialog(message)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(createWallet)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func createMnemonics(completion: @escaping (String) -> Void) {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        DispatchQueue.global(qos: .background).async { [weak self] in
            do {
                if (web3KeystoreManager?.addresses?.count ?? 0 >= 0) {
                    let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 256)
                    guard let tMnemonics = tempMnemonics else {
                        completion("We are unable to create wallet")
                        return
                    }
                    self?._mnemonics = tMnemonics
                    print(self?._mnemonics as Any)
                    let keystore = try! BIP32Keystore(
                        mnemonics: tMnemonics,
                        password: self?.password ?? "",
                        mnemonicsPassword: "",
                        language: .english,
                        prefixPath: "m/44'/77777'/0'/0")!
                    print("--> \(keystore.addresses?.first?.address as Any)")
                    guard let walletAddress = keystore.addresses?.first else {
                        completion("We are unable to create wallet")
                        return
                    }
                    
                    self?._walletAddress = walletAddress.address
                    let privateKey = try keystore.UNSAFE_getPrivateKeyData(password: self?.password ?? "", account: walletAddress).toHexString()
                    self?._privateKey = privateKey
                    
    #if DEBUG
                    print(privateKey as Any, "Is the private key")
    #endif
                    let keyData = try? JSONEncoder().encode(keystore.keystoreParams)
                    self?.viewModel.input.walletAddress.onNext(walletAddress.address)
                    FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keyData, attributes: nil)
                    completion("지갑이 생성되었습니다. 개인키를 복사하여 저장해주세요.")
                }
            } catch {
                completion("privateKey를 가져오지 못헀습니다.")
            }
        }
    }
}
// omit midnight dream tragic under pyramid slogan science execute shrug coach repeat shiver celery age window elite brand staff estate old powder six awful
