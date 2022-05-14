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

class  SignUpViewController: UIViewController {
    
    @IBOutlet weak var start: UIBarButtonItem!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var check: UIButton!
    @IBOutlet weak var warning1: UILabel!
    @IBOutlet weak var warning2: UILabel!
    @IBOutlet weak var privacyKeyLabel: UILabel!
    @IBOutlet weak var shape1: UIView!
    @IBOutlet weak var shape2: UIView!
    @IBOutlet weak var copyKey: UIButton!
    @IBOutlet weak var createWallet: UIButton!
    @IBOutlet weak var connectWallet: UIButton!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    var _walletAddress: String {
        set{
            self.walletAddressLabel.text = newValue
        }
        get {
            return self._walletAddress
        }
    }
    
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
        nicknameLabel.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        nickname.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        check.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 12)
        shape1.layer.cornerRadius = 4
        shape1.layer.borderWidth = 1
        shape1.layer.borderColor = UIColor(red: 204, green: 204, blue: 204).cgColor
        warning1.font = UIFont.NotoSansCJKkr(type: .medium, size: 10)
        warning2.font = UIFont.NotoSansCJKkr(type: .medium, size: 10)
        privacyKeyLabel.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        walletAddressLabel.font = UIFont.NotoSansCJKkr(type: .regular, size: 14)
        shape2.layer.cornerRadius = 4
        shape2.layer.borderWidth = 1
        shape2.layer.borderColor = UIColor(red: 204, green: 204, blue: 204).cgColor
        createWallet.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        connectWallet.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        createWallet.applyBorderGradient(colors: [UIColor(red: 225, green: 229, blue: 245).cgColor,
                                          UIColor(red: 154, green: 173, blue: 224).cgColor,
                                           UIColor(red: 237, green: 106, blue: 201).cgColor])
        connectWallet.applyGradient(colors: [UIColor(red: 225, green: 229, blue: 245).cgColor,
                                          UIColor(red: 154, green: 173, blue: 224).cgColor,
                                           UIColor(red: 237, green: 106, blue: 201).cgColor])
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        createWallet.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.createMnemonics()
            })
            .disposed(by: disposeBag)

        connectWallet.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showImportALert()
            })
            .disposed(by: disposeBag)
        
        copyKey.rx.tap
            .subscribe(onNext: { [weak self] in
                UIPasteboard.general.string = self?.walletAddressLabel.text
                
            })
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

extension SignUpViewController {
    fileprivate func showImportALert(){
        let alert = UIAlertController(title: "MyWeb3Wallet", message: "", preferredStyle: .alert)
        alert.addTextField { textfied in
            textfied.placeholder = "Enter mnemonics/private Key"
        }
        let mnemonicsAction = UIAlertAction(title: "Mnemonics", style: .default) { _ in
            print("Clicked on Mnemonics Option")
            guard let mnemonics = alert.textFields?[0].text else { return }
            print(mnemonics)
        }
        let privateKeyAction = UIAlertAction(title: "Private Key", style: .default) { _ in
            print("Clicked on Private Key Wallet Option")
            guard let privateKey = alert.textFields?[0].text else { return }
            print(privateKey)
            self.importWalletWith(privateKey: privateKey)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(mnemonicsAction)
        alert.addAction(privateKeyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func importWalletWith(privateKey: String){
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            self.showAlertMessage(title: "Error", message: "Please enter a valid Private key ", actionName: "Ok")
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
                let walletAddress = manager.addresses?.first?.address
                self.walletAddressLabel.text = walletAddress ?? "0x"
                
                print(walletAddress as Any)
            } else {
                print("error")
            }
        } catch {
#if DEBUG
            print("error creating keyStrore")
            print("Private key error.")
#endif
            let alert = UIAlertController(title: "Error", message: "Please enter correct Private key", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
        
        
        
    }
    func importWalletWith(mnemonics: String) {
        let walletAddress = try? BIP32Keystore(mnemonics: mnemonics , prefixPath: "m/44'/77777'/0'/0")
        print(walletAddress?.addresses as Any)
        self.walletAddressLabel.text = "\(walletAddress?.addresses?.first?.address ?? "0x")"
        
    }
    
    
}
extension SignUpViewController {
    
    fileprivate func createMnemonics(){
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        do {
            if (web3KeystoreManager?.addresses?.count ?? 0 >= 0) {
                let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 256, language: .english)
                guard let tMnemonics = tempMnemonics else {
                    self.showAlertMessage(title: "", message: "We are unable to create wallet", actionName: "Ok")
                    return
                }
                self._mnemonics = tMnemonics
                print(_mnemonics)
                let tempWalletAddress = try? BIP32Keystore(mnemonics: self._mnemonics , prefixPath: "m/44'/77777'/0'/0")
                print(tempWalletAddress?.addresses?.first?.address as Any)
                guard let walletAddress = tempWalletAddress?.addresses?.first else {
                    self.showAlertMessage(title: "", message: "We are unable to create wallet", actionName: "Ok")
                    return
                }
                self._walletAddress = walletAddress.address
                let privateKey = try tempWalletAddress?.UNSAFE_getPrivateKeyData(password: "", account: walletAddress)
#if DEBUG
                print(privateKey as Any, "Is the private key")
#endif
                let keyData = try? JSONEncoder().encode(tempWalletAddress?.keystoreParams)
                FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keyData, attributes: nil)
            }
        } catch {
            
        }
        
    }
}
extension SignUpViewController {
    func showAlertMessage(title: String = "MyWeb3Wallet", message: String = "Message is empty", actionName: String = "OK") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: actionName, style: .destructive)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
    
}
