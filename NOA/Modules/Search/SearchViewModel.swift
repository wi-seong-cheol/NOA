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
    // MARK: INPUT
//    var searchText: AnyObserver<Void> { get }
    var searchText: BehaviorRelay<String> { get }
    
    // MARK: OUTPUT
    var items: Driver<[Search]> { get }
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class SearchViewModel: SearchViewModelType {
    let disposeBag = DisposeBag()
    
    // MARK: INPUT
    let searchText = BehaviorRelay(value: "")
    
    // MARK: OUTPUT
    let items: Driver<[Search]>
    let activated: Observable<Bool>
    let errorMessage: Observable<NSError>
    
    init(service: SearchFetchable = SearchService()) {
        let searching = PublishSubject<Void>()
        
        let itemsList = BehaviorRelay<[Search]>(value: [])
        
        let activating = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        
        // MARK: OUTPUT
        
        items = itemsList.asDriver(onErrorJustReturn: [])
        
        errorMessage = error.map { $0 as NSError }
        
        activated = activating.distinctUntilChanged()
        
        // MARK: INPUT
                
        searchText
            .skip(1)
            .debug()
            .flatMapLatest{ [weak self] _ in service.search((self?.searchText.value)!) }
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: { response in
                itemsList.accept(response)
            })
            .disposed(by: disposeBag)
    }
}

