//
//  LoginViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/05/11.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import web3swift

protocol LoginViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var login$: PublishSubject<Void> { get }
    var nickname$: BehaviorSubject<String> { get }
    var privateKey$: BehaviorSubject<String> { get }
    
    // MARK: OUTPUT
    var start$: Observable<Bool> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class LoginViewModel: LoginViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        var login: AnyObserver<Void>
        var walletAddress: AnyObserver<String>
        var nickname: AnyObserver<String>
        var privateKey: AnyObserver<String>
    }
    
    struct Output {
        var start: Observable<Bool>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let login$: PublishSubject<Void>
    internal let nickname$: BehaviorSubject<String>
    internal let privateKey$: BehaviorSubject<String>
    internal let walletAddress$: BehaviorSubject<String>
    
    // MARK: OUTPUT
    internal let start$: Observable<Bool>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: AuthFetchable = AuthService()) {
        // MARK: Input
        let login$ = PublishSubject<Void>()
        let nickname$ = BehaviorSubject<String>(value: "")
        let privateKey$ = BehaviorSubject<String>(value: "")
        let walletAddress$ = BehaviorSubject<String>(value: "")
        
        // MARK: Output
        let start$ = BehaviorSubject<Bool>(value: false)
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        

        // MARK: INPUT
        self.input = Input(login: login$.asObserver(),
                           walletAddress: walletAddress$.asObserver(),
                           nickname: nickname$.asObserver(),
                           privateKey: privateKey$.asObserver())
        
        self.login$ = login$
        self.nickname$ = nickname$
        self.privateKey$ = privateKey$
        self.walletAddress$ = walletAddress$
        
        login$
            .filter{
                if (try! nickname$.value() == "") || (try! privateKey$.value() == "" ){
                    alertMessage$.onNext("빈칸을 채워주세요")
                    activated$.onNext(false)
                    return false
                } else { return true }
            }
            .do(onNext: { _ in activated$.onNext(true) })
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest{ service.importWalletWith(privateKey: try! privateKey$.value())}
            .filter{ result in
                if !validation(result.walletAddress) {
                    return false
                } else {
                    walletAddress$.onNext(result.walletAddress)
                    return true
                }
            }
            .flatMapLatest{_ in service.login(nickname: try! nickname$.value(), address: try! walletAddress$.value())}
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in
                activated$.onNext(false)
                errorMessage$.onNext(err)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
//                print(result.datax)
                if result.status_code == 200 {
                    guard let data = result.data else {
                        return
                    }
                    Token.shared.save(account: "accessToken", value: data.accessToken)
                    Token.shared.save(account: "refreshToken", value: data.accessToken)
                    var user = UserInfo.shared.getUser()
                    user.id = data.user_code
                    UserInfo.shared.saveUser(user)
                    UserInfo.shared.saveIsLogin(true)
                    start$.onNext(true)
                } else {
                    alertMessage$.onNext("닉네임과 PrivateKey를 확인해주세요.")
                }
            })
            .disposed(by: disposeBag)
                
        
        // MARK: OUTPUT
        
        self.output = Output(start: start$.map { $0 as Bool },
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
                
        self.start$ = start$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
    }
}

private func validation(_ walletAddress: String) -> Bool {
    let pattern = "^0x[a-fA-F0-9]{40}$"
    let address = NSPredicate(format: "SELF MATCHES %@", pattern)
    let isValid = address.evaluate(with: walletAddress)
    
    return isValid
}
// 0x6FCA51AD4461eE27Ae92f3e11596b23EC107b4a7
// d16b6f87af2c110e957a3564d461f168174e0bbf1c38b4338ca2652227c8eabed16b6f87af2c110e957a3564d461f168174e0bbf1c38b4338ca2652227c8eabed16b6f87af2c110e957a3564d461f168174e0bbf1c38b4338ca2652227c8eabed16b6f87af2c110e957a3564d461f168174e0bbf1c38b4338ca2652227c8eabe
// noa12345
//62826d11709638661f985034350ef489716500870a30cad82efd605999cf9603
