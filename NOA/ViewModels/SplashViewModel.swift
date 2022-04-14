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
    var errorMessage: Observable<NSError> { get }
}

class SplashViewModel: SplashViewModelType {
    
    let disposeBag = DisposeBag()
    
    // MARK: OUTPUT
//    let user: Observable<[UserResponse]>
//
//    init(service: UserFetchable = UserService()) {
//
//            }, onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//        let loadingStarted = Observable<Void>.empty()
//        let loadingEnded = Observable<Void>.empty()
//
//        loadingStarted
//            .do(onNext: <#T##((()) throws -> Void)?##((()) throws -> Void)?##(()) throws -> Void#>, afterNext: <#T##((()) throws -> Void)?##((()) throws -> Void)?##(()) throws -> Void#>, onError: <#T##((Error) throws -> Void)?##((Error) throws -> Void)?##(Error) throws -> Void#>, afterError: <#T##((Error) throws -> Void)?##((Error) throws -> Void)?##(Error) throws -> Void#>, onCompleted: <#T##(() throws -> Void)?##(() throws -> Void)?##() throws -> Void#>, afterCompleted: <#T##(() throws -> Void)?##(() throws -> Void)?##() throws -> Void#>, onSubscribe: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onSubscribed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDispose: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//
//                loadingEnded.do(onNext: <#T##((()) throws -> Void)?##((()) throws -> Void)?##(()) throws -> Void#>, afterNext: <#T##((()) throws -> Void)?##((()) throws -> Void)?##(()) throws -> Void#>, onError: <#T##((Error) throws -> Void)?##((Error) throws -> Void)?##(Error) throws -> Void#>, afterError: <#T##((Error) throws -> Void)?##((Error) throws -> Void)?##(Error) throws -> Void#>, onCompleted: <#T##(() throws -> Void)?##(() throws -> Void)?##() throws -> Void#>, afterCompleted: <#T##(() throws -> Void)?##(() throws -> Void)?##() throws -> Void#>, onSubscribe: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onSubscribed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDispose: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//    }
    // MARK: INPUT
    
    let fetchList: AnyObserver<Void>
    
    // MARK: OUTPUT
    
    let lectureList: Observable<LectureList>
    let errorMessage: Observable<NSError>
    
    init(service: UserFetchable = UserService()) {
        let fetching = PublishSubject<Void>()
        
        let list = BehaviorSubject<LectureList>(value: LectureList.EMPTY)
        let activating = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        // MARK: INPUT
        fetchList = fetching.asObserver()
        
        fetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap(service.getTestData)
            .do(onNext: { _ in activating.onNext(false) })
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: list.onNext)
            .disposed(by: disposeBag)
//            .do(onNext: { _ in activating.onNext(true) })
//                .flatMap(service.getTestData)
//                .map { $0.map { LectureList(from: $0) } }
//                .do(onNext: { _ in activating.onNext(false) })
//                .do(onError: { err in error.onNext(err) })
//                .subscribe(onNext: lectureList.onNext)
//                .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        lectureList = list

        errorMessage = error.map { $0 as NSError }
    }
//
//    var loadingStarted: () -> Void = { }
//    var loadingEnded: () -> Void = { }
//
//    func initialization() {
//        loadingStarted()
//        // API Call
//        loadingEnded()
//    }
//
//    func versionCheck() {
//
//    }
//
//    func concurrentWorkItems() {
//
//    }
//
//    func comparePushToken() {
//
//    }
}
