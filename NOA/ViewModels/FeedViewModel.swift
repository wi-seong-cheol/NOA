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

protocol FeedViewModelType {
    var work: Observable<UIImage> { get }
    //    var orderedList: Observable<String> { get }
    //    var itemsPriceText: Observable<String> { get }
    //    var itemsVatText: Observable<String> { get }
    //    var totalPriceText: Observable<String> { get }
}

class FeedViewModel: FeedViewModelType {
    var disposeBag = DisposeBag()
    let work: Observable<UIImage>
    //    let itemsPriceText: Observable<String>
    //    let itemsVatText: Observable<String>
    //    let totalPriceText: Observable<String>
    let errorMessage: Observable<NSError>
    
    init(_ selectedFeed: Lecture = Lecture.EMPTY) {
        let feed = Observable.just(selectedFeed)
        let workImage = BehaviorRelay<UIImage>(value: UIImage())
        let error = PublishSubject<Error>()
        
        errorMessage = error.map { $0 as NSError }
        work = workImage.asObservable()
        
        feed
            .map{ $0.courseImage }
            .filter{ $0 != "" }
            .flatMap{ ImageLoader.loadImage(from: $0)}
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: {(image) in
                workImage.accept(image ?? UIImage())})
            .disposed(by: disposeBag)
    }
}
