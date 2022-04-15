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
    
    // MARK: OUTPUT
    var lectureList: PublishSubject<[Lecture]> { get }
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class HomeViewModel: HomeViewModelType {
    
    let disposeBag = DisposeBag()
    
    // MARK: INPUT
    
    let fetchList: AnyObserver<Void>
    
    // MARK: OUTPUT
    
    let lectureList = PublishSubject<[Lecture]>()
    let activated: Observable<Bool>
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        let fetching = PublishSubject<Void>()
        
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
                
        // MARK: OUTPUT
        list
            .map { $0 }
            .map { response -> [Lecture] in
                return response.lectures
            }.bind(to: lectureList)
            .disposed(by: disposeBag)
        
        errorMessage = error.map { $0 as NSError }
        
        activated = activating.distinctUntilChanged()
    }
}
