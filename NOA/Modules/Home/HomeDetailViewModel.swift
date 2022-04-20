//
//  FeedViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/19.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

protocol HomeDetailViewModelType {
    // MARK: OUTPUT
    var work: Observable<UIImage> { get }
}

class HomeDetailViewModel: HomeDetailViewModelType {
    var disposeBag = DisposeBag()
    
    // MARK: OUTPUT
    let work: Observable<UIImage>
    let errorMessage: Observable<NSError>
    
    init(_ selectedFeed: Lecture = Lecture.EMPTY) {
        let feed = Observable.just(selectedFeed)
        let workImage = BehaviorRelay<UIImage>(value: UIImage())
        let error = PublishSubject<Error>()
        
        // MARK: INPUT
        feed
            .map{ $0.courseImage }
            .filter{ $0 != "" }
            .flatMap{ ImageLoader.loadImage(from: $0)}
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: {(image) in
                workImage.accept(image ?? UIImage())})
            .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        work = workImage.asObservable()
                
        errorMessage = error.map { $0 as NSError }
    }
}
