//
//  SplashViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import RxSwift

protocol SplashViewModelType {
    // MARK: INPUT
    
    var fetchList: AnyObserver<Void> { get }
    
    // MARK: OUTPUT
    
    var lectureList: Observable<LectureList> { get }
    var isLogin: Observable<Bool> { get }
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class SplashViewModel: SplashViewModelType {
    
    let disposeBag = DisposeBag()
    
    // MARK: INPUT
    
    let fetchList: AnyObserver<Void>
    
    // MARK: OUTPUT
    
    let lectureList: Observable<LectureList>
    let isLogin: Observable<Bool>
    let activated: Observable<Bool>
    let errorMessage: Observable<NSError>
    
    init(service: UserFetchable = UserService()) {
        let fetching = PublishSubject<Void>()
        let move = PublishSubject<Void>()
        
        let list = BehaviorSubject<LectureList>(value: LectureList.EMPTY)
        let activating = BehaviorSubject<Bool>(value: false)
        let loginCheck = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        // MARK: INPUT
        fetchList = move.asObserver()
        
        move
            .subscribe(onNext: { _ in
                if UserInfo.shared.getIsLogin() {
                    loginCheck.onNext(true)
                    print("true")
                } else {
                    loginCheck.onNext(false)
                    print("false")
                }
            })
            .disposed(by: disposeBag)
//            
//        fetching
//            .do(onNext: { _ in activating.onNext(true) })
//            .flatMap(service.getTestData)
//            .do(onNext: { _ in activating.onNext(false) })
//            .do(onError: { err in error.onNext(err) })
//            .subscribe(onNext: list.onNext)
//            .disposed(by: disposeBag)
                
        
        // MARK: OUTPUT
        lectureList = list

        errorMessage = error.map { $0 as NSError }
        
        isLogin = loginCheck.map { $0 as Bool}
        
        activated = activating.distinctUntilChanged()
    }
}
