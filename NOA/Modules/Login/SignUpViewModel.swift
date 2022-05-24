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
import web3swift

protocol SignUpViewModelType {
    // MARK: Warpper Class로 정의해야 함
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var nickname$: BehaviorSubject<String> { get }
    var walletAddress$: BehaviorSubject<String> { get }
    var check$: PublishSubject<Void> { get }
    var register$: PublishSubject<Void> { get }

    // MARK: OUTPUT
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class SignUpViewModel: SignUpViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let nickname: AnyObserver<String>
        let walletAddress: AnyObserver<String>
        let check: AnyObserver<Void>
        let register: AnyObserver<Void>
    }
    
    struct Output {
        let activated: Observable<Bool>
        let alertMessage: Observable<String>
        let errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let nickname$: BehaviorSubject<String>
    internal let walletAddress$: BehaviorSubject<String>
    internal let check$: PublishSubject<Void>
    internal let register$: PublishSubject<Void>
    
    // MARK: OUTPUT
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: AuthFetchable = AuthService()) {
        
        let duplicate = BehaviorSubject<Bool>(value: true)
//        let activating = BehaviorSubject<Bool>(value: false)
//        let alert = BehaviorSubject<String>(value: "")
//        let error = PublishSubject<NSError>()
        
        // MARK: Input
        let check$ = PublishSubject<Void>()
        let register$ = PublishSubject<Void>()
        let nickname$ = BehaviorSubject<String>(value: "")
        let walletAddress$ = BehaviorSubject<String>(value: "")
        
        // MARK: Output
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: Input & Output
        self.input = Input(nickname: nickname$.asObserver(),
                           walletAddress: walletAddress$.asObserver(),
                           check: check$.asObserver(),
                           register: register$.asObserver())
        // MARK: INPUT
        self.check$ = check$
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
                if response.isEmpty {
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
                print(response.message)
                if response.message == "회원가입 완료" {
                    alertMessage$.onNext("회원가입에 성공하였습니다. PrivateKey를 복사하여 로그인해주세요.")
                } else {
                    alertMessage$.onNext("회원가입에 실패하였습니다.")
                }
            })
            .disposed(by: disposeBag)
                
                
        // MARK: OUTPUT
        
        self.output = Output(activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
        
    }
}
