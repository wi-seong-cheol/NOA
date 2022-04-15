//
//  HomeViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/09.
//

import Foundation
import RxSwift
import RxRelay

protocol HomeViewModelType {
    // MARK: INPUT
    var fetchList: AnyObserver<Void> { get }
    var likeTap: AnyObserver<Void> { get }
    
    // MARK: OUTPUT
    var lectureList: Observable<LectureList> { get }
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class HomeViewModel: HomeViewModelType {
    
    let disposeBag = DisposeBag()
    
    // MARK: INPUT
    
    let fetchList: AnyObserver<Void>
    let likeTap: AnyObserver<Void>
    
    // MARK: OUTPUT
    
    let lectureList: Observable<LectureList>
    let activated: Observable<Bool>
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        let fetching = PublishSubject<Void>()
        let liking = PublishSubject<Void>()
        
        let list = BehaviorSubject<LectureList>(value: LectureList.EMPTY)
        let activating = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        // MARK: INPUT
        fetchList = fetching.asObserver()
        
        fetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap(service.getFeedList)
            .do(onNext: { _ in activating.onNext(false) })
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: list.onNext)
            .disposed(by: disposeBag)
                
        likeTap = liking.asObserver()
                
//        liking.withLatestFrom(list)
//                .map{ $0.lectures.map { $0.teachers("123") } }
//            .subscribe(onNext: list.onNext)
//                .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        lectureList = list
        
        errorMessage = error.map { $0 as NSError }
        
        activated = activating.distinctUntilChanged()
    }
}
