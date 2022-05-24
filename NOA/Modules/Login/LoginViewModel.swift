//
//  LoginViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/05/11.
//

import Foundation
import RxSwift
import RxRelay
import web3swift

protocol LoginViewModelType {
    // MARK: INPUT
    var login: AnyObserver<Void> { get }
    var password: BehaviorRelay<String> { get }
    var nickname: BehaviorRelay<String> { get }
    var privateKey: BehaviorRelay<String> { get }
    
    // MARK: OUTPUT
    var start: Observable<Bool> { get }
    var activated: Observable<Bool> { get }
    var alertMessage: Observable<String> { get }
    var errorMessage: Observable<NSError> { get }
    func importWalletWith(privateKey: String, _ completion: @escaping (String) -> Void)
}

class LoginViewModel: LoginViewModelType {
    
    let disposeBag = DisposeBag()
    
    // MARK: INPUT
    let login: AnyObserver<Void>
    let password = BehaviorRelay<String>(value: "")
    let nickname = BehaviorRelay<String>(value: "")
    let privateKey = BehaviorRelay<String>(value: "")
    
    // MARK: OUTPUT
    let start: Observable<Bool>
    let activated: Observable<Bool>
    let alertMessage: Observable<String>
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        let loggingIn = PublishSubject<Void>()
        
        let activating = BehaviorSubject<Bool>(value: false)
        let startService = BehaviorSubject<Bool>(value: false)
        let alert = BehaviorSubject<String>(value: "")
        let error = PublishSubject<Error>()
                        
        
        // MARK: OUTPUT
        
        start = startService.map { $0 as Bool }
        
        alertMessage = alert.map { $0 as String }
        
        errorMessage = error.map { $0 as NSError }
        
        activated = activating.distinctUntilChanged()
        
        
        // MARK: INPUT
        login = loggingIn.asObserver()
        
        loggingIn
            .subscribe(onNext: { [weak self] in
                if self?.nickname.value == "" || self?.privateKey.value == ""{
                    alert.onNext("빈칸을 채워주세요")
                } else {
                    self?.importWalletWith(privateKey: (self?.privateKey.value)!) { message in
                        if message != "Success" {
                            alert.onNext(message)
                        } else {
                            startService.onNext(true)
                            // alert.onNext("success")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func importWalletWith(privateKey: String, _ completion: @escaping (String) -> Void)  {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            completion("Please enter a valid Private key")
            return
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            do {
                let name = "New Wallet"
                guard let keystore = try EthereumKeystoreV3(privateKey: dataKey, password: (self?.password.value)!) else {
                    completion("Keystore get fail")
                    return
                }
                let keyData = try JSONEncoder().encode(keystore.keystoreParams)
                let address = keystore.addresses!.first!.address
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
                UserInfo.shared.saveWallet(wallet)
                UserInfo.shared.saveIsLogin(true)
                completion("Success")
            } catch {
    #if DEBUG
                print("error creating keyStrore")
                print("Private key error.")
    #endif
                completion("Please enter correct Private key")
            }
        }
    }
    
}
// 0x6FCA51AD4461eE27Ae92f3e11596b23EC107b4a7
// d16b6f87af2c110e957a3564d461f168174e0bbf1c38b4338ca2652227c8eabe
// noa12345
