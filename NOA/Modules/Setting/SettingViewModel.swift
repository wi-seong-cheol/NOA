//
//  SettingViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/05/01.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift

protocol SettingViewModelType {
    // MARK: INPUT
    var logout: AnyObserver<Void> { get }
    
    // MARK: OUTPUT
    var present: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class SettingViewModel: SettingViewModelType {
    
    let disposeBag = DisposeBag()
    
    let realm = try! Realm()
    // MARK: INPUT
    let logout: AnyObserver<Void>
    
    // MARK: OUTPUT
    let present: Observable<Bool>
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        let loggingOut = PublishSubject<Void>()
        
        let error = PublishSubject<Error>()
        let show = BehaviorSubject<Bool>(value: false)
        
        // MARK: INPUT
        logout = loggingOut.asObserver()
        
        loggingOut
            .subscribe(onNext: { _ in
                
                show.onNext(true)
            })
            .disposed(by: disposeBag)
        
        // MARK: OUTPUT
        present = show.map { $0 as Bool }
        
        errorMessage = error.map { $0 as NSError }
    }
}

