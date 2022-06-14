//
//  SearchWorkViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/05/03.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol SearchWorkViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var fetchList$: PublishSubject<Void> { get }
    var moreFetchList$: PublishSubject<Void> { get }
    
    // MARK: OUTPUT
    var items$: BehaviorRelay<[Feed]> { get }
    var keyword$: BehaviorRelay<String> { get }
    var activated$: Observable<Bool> { get }
    var errorMessage$: Observable<Error> { get }
}

class SearchWorkViewModel: SearchWorkViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        // MARK: INPUT
        var fetchList: AnyObserver<Void>
        var moreFetchList: AnyObserver<Void>
    }
    
    struct Output {
        var items: Driver<[Feed]>
        var keyword: Driver<String>
        var activated: Observable<Bool>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    let fetchList$: PublishSubject<Void>
    let moreFetchList$: PublishSubject<Void>
    
    // MARK: OUTPUT
    let items$: BehaviorRelay<[Feed]>
    let keyword$: BehaviorRelay<String>
    let activated$: Observable<Bool>
    let errorMessage$: Observable<Error>
    
    init(service: FeedFetchable = FeedService(),
         _ keyword: String = "") {
        // MARK: INPUT
        let fetchList$ = PublishSubject<Void>()
        let moreFetchList$ = PublishSubject<Void>()
        
        // MARK: OUTPUT
        let items$ = BehaviorRelay<[Feed]>(value: [])
        let keyword$ = BehaviorRelay(value: keyword)
        let page$ = BehaviorRelay<Int>(value: 0)
        let state$ = BehaviorRelay<Bool>(value: false)
        let activated$ = BehaviorSubject<Bool>(value: false)
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(fetchList: fetchList$.asObserver(),
                           moreFetchList: moreFetchList$.asObserver())
        self.fetchList$ = fetchList$
        self.moreFetchList$ = moreFetchList$
        
        fetchList$
            .filter{ keyword != "" }
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{service.searchList(keyword, 0)}
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
            .flatMapLatest{ service.searchList(keyword, page$.value) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onNext: { _ in state$.accept(false)})
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                items$.accept(items$.value + response)
                page$.accept(page$.value + 1)
            })
            .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        self.output = Output(items: items$.asDriver(onErrorJustReturn: []),
                             keyword: keyword$.asDriver(onErrorJustReturn: ""),
                                     activated: activated$.distinctUntilChanged(),
                                     errorMessage: errorMessage$.map { $0 as NSError })
        self.items$ = items$
        self.keyword$ = keyword$
        self.activated$ = activated$
        self.errorMessage$ = errorMessage$
    }
}

