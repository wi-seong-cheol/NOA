//
//  LoginViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/05/11.
//

import Foundation
import RxSwift
import RxRelay

protocol LoginViewModelType {
    // MARK: INPUT
    
    // MARK: OUTPUT
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class LoginViewModel: LoginViewModelType {
    
    let disposeBag = DisposeBag()
    
    // MARK: INPUT
    
    // MARK: OUTPUT
    let activated: Observable<Bool>
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        
        let activating = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        // MARK: INPUT
                
        // MARK: OUTPUT
        
        errorMessage = error.map { $0 as NSError }
        
        activated = activating.distinctUntilChanged()
    }
}
