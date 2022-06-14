//
//  SplashViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import RxSwift
import RxCocoa

protocol SplashViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: OUTPUT
    var getUser$: PublishSubject<Void> { get }
    
    // MARK: OUTPUT
    var move$: BehaviorSubject<Bool> { get }
    var isLogin$: BehaviorSubject<Bool> { get }
    var errorMessage$: Observable<Error> { get }
}

class SplashViewModel: SplashViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        var getUser: AnyObserver<Void>
    }
    
    struct Output {
        var move: Observable<Bool>
        var isLogin: Observable<Bool>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let getUser$: PublishSubject<Void>
    
    // MARK: OUTPUT
    internal let move$: BehaviorSubject<Bool>
    internal let isLogin$: BehaviorSubject<Bool>
    internal let errorMessage$: Observable<Error>
    
    init(service: UserFetchable = UserService()) {
        // MARK: INPUT
        let getUser$ = PublishSubject<Void>()
        let user$ = BehaviorRelay<User>(value: UserInfo.shared.getUser())
        
        // MARK: OUTPUT
        let move$ = BehaviorSubject<Bool>(value: false)
        let isLogin$ = BehaviorSubject<Bool>(value:  UserInfo.shared.getIsLogin())
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(getUser: getUser$.asObserver())
        self.getUser$ = getUser$
        
        getUser$
            .flatMap{ service.getUser(String(user$.value.id)) }
            .do(onError: { err in errorMessage$.onNext(err)})
            .subscribe(onNext: { response in
                var user = user$.value
                user.profile = response.user_profile
                user.nickname = response.user_nickname
                user.status_message = response.user_desc ?? ""
                print(user)
                UserInfo.shared.saveUser(user)
                move$.onNext(true)
            })
            .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        self.output = Output(move: move$.asObservable(),
                             isLogin: isLogin$.asObservable(),
                             errorMessage: errorMessage$.map { $0 as NSError })
        self.move$ = move$
        self.isLogin$ = isLogin$
        self.errorMessage$ = errorMessage$
    }
}
