//
//  FeedViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/06/01.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol FeedViewModelType{
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var fetchList$: PublishSubject<Void> { get }
    var moreFetchList$: PublishSubject<Void> { get }
    var like$: PublishSubject<String> { get }
    
    // MARK: OUTPUT
    var items$: BehaviorRelay<[Feed]> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class FeedViewModel: FeedViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        var fetchList: AnyObserver<Void>
        var moreFetchList: AnyObserver<Void>
        var like: AnyObserver<String>
    }
    
    struct Output {
        var items: Driver<[Feed]>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let fetchList$: PublishSubject<Void>
    internal let moreFetchList$: PublishSubject<Void>
    internal let like$: PublishSubject<String>
    
    // MARK: OUTPUT
    internal let items$: BehaviorRelay<[Feed]>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: FeedFetchable = FeedService()) {
        let fetchList$ = PublishSubject<Void>()
        let moreFetchList$ = PublishSubject<Void>()
        let like$ = PublishSubject<String>()
        
        let items$ = BehaviorRelay<[Feed]>(value: [])
        let page$ = BehaviorRelay<Int>(value: 0)
        let state$ = BehaviorRelay<Bool>(value: false)
        
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(fetchList: fetchList$.asObserver(),
                           moreFetchList: moreFetchList$.asObserver(),
                           like: like$.asObserver())
        
        self.fetchList$ = fetchList$
        self.moreFetchList$ = moreFetchList$
        self.like$ = like$
        
        fetchList$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{service.randomList(0)}
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
            .flatMapLatest{ service.randomList( page$.value) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                items$.accept(items$.value + response)
                page$.accept(page$.value + 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    state$.accept(false)
                }
            })
            .disposed(by: disposeBag)

        like$
            .do(onNext: { _ in activated$.onNext(true) })
            .map{ $0 }
//            .flatMapLatest{ service.next(nextPage: $0 ) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                print(response)
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
