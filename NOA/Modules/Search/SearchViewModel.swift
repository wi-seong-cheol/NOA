//
//  SearchViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/29.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol SearchViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var searchText$: BehaviorSubject<String> { get }
    
    // MARK: OUTPUT
    var items$: BehaviorRelay<[Search]> { get }
    var activated$: Observable<Bool> { get }
    var errorMessage$: Observable<Error> { get }
}

class SearchViewModel: SearchViewModelType {
    let disposeBag = DisposeBag()
    
    struct Input {
        var searchText: AnyObserver<String>
    }
    
    struct Output {
        var items: Driver<[Search]>
        var activated: Observable<Bool>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    let searchText$: BehaviorSubject<String>
    
    // MARK: OUTPUT
    let items$: BehaviorRelay<[Search]>
    let activated$: Observable<Bool>
    let errorMessage$: Observable<Error>
    
    init(service: SearchFetchable = SearchService()) {
        // MARK: INPUT
        let searchText$ = BehaviorSubject<String>(value: "")
        
        // MARK: OUTPUT
        let items$ = BehaviorRelay<[Search]>(value: [])
        let activated$ = BehaviorSubject<Bool>(value: false)
        let errorMessage$ = PublishSubject<Error>()
        
        
        // MARK: INPUT
        self.input = Input(searchText: searchText$.asObserver())
        self.searchText$ = searchText$
        
        searchText$
            .skip(1)
            .debug()
            .flatMapLatest{ _ in service.search(try! searchText$.value())}
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { result in
                items$.accept(result)
            })
            .disposed(by: disposeBag)
                
        // MARK: OUTPUT
                
        self.output = Output(items: items$.asDriver(onErrorJustReturn: []),
                             activated: activated$.distinctUntilChanged(),
                             errorMessage: errorMessage$.map { $0 as NSError })
                
        self.items$ = items$
        self.activated$ = activated$
        self.errorMessage$ = errorMessage$
    }
}
