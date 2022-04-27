//
//  WorkViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import RxSwift
import RxRelay

protocol AllWorkViewModelType {
    // MARK: INPUT
    var fetchList: AnyObserver<Void> { get }
    var moreFetchList: AnyObserver<Void> { get }
    
    // MARK: OUTPUT
    var items: Observable<[Lecture]> { get }
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class AllWorkViewModel: AllWorkViewModelType {
    
    let disposeBag = DisposeBag()
    
    // MARK: INPUT
    let fetchList: AnyObserver<Void>
    let moreFetchList: AnyObserver<Void>
    
    // MARK: OUTPUT
    let items: Observable<[Lecture]>
    let activated: Observable<Bool>
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        let fetching = PublishSubject<Void>()
        let moreFetching = PublishSubject<Void>()
        
        let itemsList = BehaviorRelay<[Lecture]>(value: [])
        let nextPage = BehaviorRelay<String>(value: "")
        let state = BehaviorRelay<Bool>(value: false)
        
        let activating = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        // MARK: INPUT
        fetchList = fetching.asObserver()
        moreFetchList = moreFetching.asObserver()
        
        fetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap(service.list)
            .do(onNext: { _ in activating.onNext(false) })
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: { response in
                itemsList.accept(response.lectures)
                nextPage.accept(response.next)
            })
            .disposed(by: disposeBag)
                
        moreFetching
            .filter{!state.value}
            .do(onNext: { _ in state.accept(true)})
            .do(onNext: { _ in activating.onNext(true) })
            .flatMapLatest{ service.next(nextPage: nextPage.value) }
            .do(onNext: { _ in activating.onNext(false) })
            .do(onNext: { _ in state.accept(false)})
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: { response in
                itemsList.accept(itemsList.value + response.lectures)
                nextPage.accept(response.next)
            })
            .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        items = itemsList.asObservable()
        
        errorMessage = error.map { $0 as NSError }
        
        activated = activating.distinctUntilChanged()
    }
}

