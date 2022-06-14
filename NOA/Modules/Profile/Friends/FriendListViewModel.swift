//
//  FriendListViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/05/10.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol FriendListViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var fetchList$: PublishSubject<Void> { get }
    var moreFetchList$: PublishSubject<Void> { get }
    var report$: BehaviorSubject<String> { get }
    
    // MARK: OUTPUT
    var items$: BehaviorRelay<[UserResponse]> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class FriendListViewModel: FriendListViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        var fetchList: AnyObserver<Void>
        var moreFetchList: AnyObserver<Void>
        var report: AnyObserver<String>
    }
    
    struct Output {
        var items: Driver<[UserResponse]>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let fetchList$: PublishSubject<Void>
    internal let moreFetchList$: PublishSubject<Void>
    internal let report$: BehaviorSubject<String>
    
    // MARK: OUTPUT
    internal let items$: BehaviorRelay<[UserResponse]>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: UserFetchable = UserService()) {
        let fetchList$ = PublishSubject<Void>()
        let moreFetchList$ = PublishSubject<Void>()
        let report$ = BehaviorSubject<String>(value: "")
        
        let items$ = BehaviorRelay<[UserResponse]>(value: [])
        let page$ = BehaviorRelay<Int>(value: 0)
        let state$ = BehaviorRelay<Bool>(value: false)
        
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(fetchList: fetchList$.asObserver(),
                           moreFetchList: moreFetchList$.asObserver(),
                           report: report$.asObserver())
        
        self.fetchList$ = fetchList$
        self.moreFetchList$ = moreFetchList$
        self.report$ = report$
        
        fetchList$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{ service.friendList(0) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                items$.accept(response)
                page$.accept(1)
            })
            .disposed(by: disposeBag)
                
        moreFetchList$
            .filter{!state$.value}
            .do(onNext: { _ in state$.accept(true)})
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{ service.friendList(page$.value) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onNext: { _ in state$.accept(false)})
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                items$.accept(items$.value + response)
                page$.accept(page$.value + 1)
            })
            .disposed(by: disposeBag)

        report$
                .debug()
            .skip(1)
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{ service.report($0) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                if response.status_code == 200 {
                    alertMessage$.onNext(response.message!)
                } else {
                    alertMessage$.onNext("잠시 후 다시 시도해주세요.")
                }
            })
        .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        self.output = Output(items: items$.asDriver(onErrorJustReturn: []),
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
                
        self.items$ = items$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
    }
}
