//
//  ProfileViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import UIKit

protocol ProfileViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var load$: PublishSubject<Void> { get }
    
    // MARK: OUTPUT
    var profile$: BehaviorRelay<UIImage> { get }
    var nickname$: BehaviorRelay<String> { get }
    var status$: BehaviorRelay<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class ProfileViewModel: ProfileViewModelType {
    
    
    let disposeBag = DisposeBag()
    
    struct Input {
        var load: AnyObserver<Void>
    }
    
    struct Output {
        var profile: Driver<UIImage>
        var nickname: Driver<String>
        var status: Driver<String>
        var errorMessage: Observable<NSError>
    }
        
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let load$: PublishSubject<Void>
    
    // MARK: OUTPUT
    internal let profile$: BehaviorRelay<UIImage>
    internal let nickname$: BehaviorRelay<String>
    internal let status$: BehaviorRelay<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: UserFetchable = UserService()) {
        // MARK: INPUT
        let load$ = PublishSubject<Void>()
        
        // MARK: OUTPUT
        let profile$ = BehaviorRelay<UIImage>(value: UIImage())
        let nickname$ = BehaviorRelay<String>(value: "")
        let status$ = BehaviorRelay<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(load: load$.asObserver())
        self.load$ = load$
        let user = UserInfo.shared.getUser()
        
        load$
            .flatMap{ ImageLoader.loadImage(from: user.profile)}
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { image in
                profile$.accept(image ?? UIImage(named: "profile_asset")!)
            })
            .disposed(by: disposeBag)
                
        nickname$.accept(user.nickname)
        status$.accept(user.status_message)
                
        // MARK: OUTPUT
        self.output = Output(profile: profile$.asDriver(onErrorJustReturn: UIImage()),
                             nickname: nickname$.asDriver(onErrorJustReturn: ""),
                             status: status$.asDriver(onErrorJustReturn: ""),
            errorMessage: errorMessage$.map { $0 as NSError })
        self.profile$ = profile$
        self.nickname$ = nickname$
        self.status$ = status$
        self.errorMessage$ = errorMessage$
    }
}
