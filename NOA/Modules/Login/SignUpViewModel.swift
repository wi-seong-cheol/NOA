////
////  SignUpViewModel.swift
////  NOA
////
////  Created by wi_seong on 2022/05/24.
////

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa
import web3swift

protocol SignUpViewModelType {
    // MARK: Warpper Class로 정의해야 함
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var nickname$: BehaviorSubject<String> { get }
    var walletAddress$: BehaviorSubject<String> { get }
    var check$: PublishSubject<Void> { get }
    var key$: BehaviorSubject<String> { get }
    var password$: BehaviorSubject<String> { get }
    var createWallet$: PublishSubject<Void> { get }
    var importWalletPrivateKey$: PublishSubject<Void> { get }
    var importWalletMnemonics$: PublishSubject<Void> { get }
    var register$: PublishSubject<Void> { get }

    // MARK: OUTPUT
    var privateKey$: BehaviorRelay<String> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class SignUpViewModel: SignUpViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        var nickname: AnyObserver<String>
        var walletAddress: AnyObserver<String>
        var check: AnyObserver<Void>
        var key: AnyObserver<String>
        var password: AnyObserver<String>
        var createWallet: AnyObserver<Void>
        var importWalletPrivateKey: AnyObserver<Void>
        var importWalletMnemonics: AnyObserver<Void>
        var register: AnyObserver<Void>
    }
    
    struct Output {
        var privateKey: Driver<String>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let nickname$: BehaviorSubject<String>
    internal let walletAddress$: BehaviorSubject<String>
    internal let check$: PublishSubject<Void>
    internal let key$: BehaviorSubject<String>
    internal let password$: BehaviorSubject<String>
    internal let createWallet$: PublishSubject<Void>
    internal let importWalletPrivateKey$: PublishSubject<Void>
    internal let importWalletMnemonics$: PublishSubject<Void>
    internal let register$: PublishSubject<Void>
    
    // MARK: OUTPUT
    internal let privateKey$: BehaviorRelay<String>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: AuthFetchable = AuthService()) {
        
        // MARK: Input
        let duplicate = BehaviorSubject<Bool>(value: true)
        let check$ = PublishSubject<Void>()
        let key$ = BehaviorSubject<String>(value: "")
        let password$ = BehaviorSubject<String>(value: "")
        let createWallet$ = PublishSubject<Void>()
        let importWalletPrivateKey$ = PublishSubject<Void>()
        let importWalletMnemonics$ = PublishSubject<Void>()
        let register$ = PublishSubject<Void>()
        let nickname$ = BehaviorSubject<String>(value: "")
        let walletAddress$ = BehaviorSubject<String>(value: "")
        
        // MARK: Output
        let privateKey$ = BehaviorRelay<String>(value: "")
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: Input
        self.input = Input(nickname: nickname$.asObserver(),
                           walletAddress: walletAddress$.asObserver(),
                           check: check$.asObserver(),
                           key: key$.asObserver(),
                           password: password$.asObserver(),
                           createWallet: createWallet$.asObserver(),
                           importWalletPrivateKey: importWalletPrivateKey$.asObserver(),
                           importWalletMnemonics: importWalletMnemonics$.asObserver(),
                           register: register$.asObserver())
        
        self.check$ = check$
        self.key$ = key$
        self.password$ = password$
        self.createWallet$ = createWallet$
        self.importWalletPrivateKey$ = importWalletPrivateKey$
        self.importWalletMnemonics$ = importWalletMnemonics$
        self.register$ = register$
        self.nickname$ = nickname$
        self.walletAddress$ = walletAddress$
        
        
        // Nickname 중복 확인
        check$
            .filter{
                if try! nickname$.value() != "" {
                    return true
                } else {
                    alertMessage$.onNext("닉네임을 입력해주세요.")
                    return false
                }
            }
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMap{ service.duplicate(try! nickname$.value())}
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                if response.status_code == 200 {
                    print(response)
                    alertMessage$.onNext("사용 가능한 닉네임 입니다.")
                    duplicate.onNext(false)
                } else {
                    print("-> \(response)")
                    alertMessage$.onNext("이미 사용중인 닉네임 입니다.")
                    duplicate.onNext(true)
                }
            })
            .disposed(by: disposeBag)
        
        // 지갑 생성
        createWallet$
                .do(onNext: { _ in activated$.onNext(true) })
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .flatMap{ service.createWallet(password: try! password$.value()) }
                .do(onNext: { _ in activated$.onNext(false) })
                .do(onError: { err in
                    activated$.onNext(false)
                    errorMessage$.onNext(err)
                })
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { result in
                    walletAddress$.onNext(result.walletAddress)
                    privateKey$.accept(result.privateKey)
                    alertMessage$.onNext("지갑이 생성되었습니다. 개인키를 복사하여 저장해주세요.")
                })
                .disposed(by: disposeBag)
                    
        // 지갑 import by PrivateKey
        importWalletPrivateKey$
            .do(onNext: { _ in activated$.onNext(true) })
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap{ service.importWalletWith(privateKey: try! key$.value()) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in
                activated$.onNext(false)
                errorMessage$.onNext(err)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
                print(result.walletAddress)
                walletAddress$.onNext(result.walletAddress)
                privateKey$.accept(result.privateKey)
                alertMessage$.onNext("지갑이 연결되었습니다. 개인키를 복사하여 저장해주세요.")
            })
            .disposed(by: disposeBag)
                
        // 지갑 import by Mnemonics
        importWalletMnemonics$
            .do(onNext: { _ in activated$.onNext(true) })
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap{ service.importWalletWith(mnemonics: try! key$.value()) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in
                activated$.onNext(false)
                errorMessage$.onNext(err)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
                walletAddress$.onNext(result.walletAddress)
                privateKey$.accept(result.privateKey)
                alertMessage$.onNext("지갑이 연결되었습니다. 개인키를 복사하여 저장해주세요.")
            })
            .disposed(by: disposeBag)
                
        // 회원가입
        register$
            .filter{
                if try! duplicate.value() {
                    alertMessage$.onNext("닉네임 중복확인을 해주세요.")
                    return false
                } else if try! walletAddress$.value() == ""{
                    alertMessage$.onNext("privateKey를 입력해주세요")
                    return false
                } else {
                    print("clcickccldscsc")
                    return true
                }
            }
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMap{
                service.register(nickname: try! nickname$.value(), address: try! walletAddress$.value()) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                if response.status_code == 200 {
                    alertMessage$.onNext("회원가입에 성공하였습니다. PrivateKey를 복사하여 로그인해주세요.")
                } else {
                    alertMessage$.onNext("회원가입에 실패하였습니다.")
                }
            })
            .disposed(by: disposeBag)
                
                
        // MARK: OUTPUT
        
        self.output = Output(privateKey: privateKey$.asDriver(onErrorJustReturn: ""),
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
        self.privateKey$ = privateKey$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
        
    }
}
