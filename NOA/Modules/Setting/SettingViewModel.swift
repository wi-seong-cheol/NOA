//
//  SettingViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/05/01.
//

import Foundation
import RxSwift
import RxRelay

protocol SettingViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var logout$: PublishSubject<Void> { get }
    
    // MARK: OUTPUT
    var present$: Observable<Bool> { get }
    var errorMessage$: Observable<Error> { get }
}

class SettingViewModel: SettingViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let logout: AnyObserver<Void>
    }
    
    struct Output {
        let present: Observable<Bool>
        let errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    let logout$: PublishSubject<Void>
    
    // MARK: OUTPUT
    let present$: Observable<Bool>
    let errorMessage$: Observable<Error>
    
    init() {
        // MARK: INPUT
        let logout$ = PublishSubject<Void>()
        
        // MARK: OUTPUT
        let present$ = BehaviorSubject<Bool>(value: false)
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(logout: logout$.asObserver())
        
        self.logout$ = logout$
        
        logout$
            .subscribe(onNext: { _ in
                present$.onNext(true)
            })
            .disposed(by: disposeBag)
        
        // MARK: OUTPUT
        self.output = Output(present: present$.map { $0 as Bool },
                             errorMessage: errorMessage$.map { $0 as NSError })
        self.present$ = present$
        self.errorMessage$ = errorMessage$
    }
}

