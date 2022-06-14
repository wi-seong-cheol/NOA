//
//  FeedDetailViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/20.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import UIKit

protocol FeedDetailViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var likeClick$: PublishSubject<Void> { get }
    var report$: PublishSubject<Void> { get }
    
    // MARK: OUTPUT
    var artist$: BehaviorRelay<Artist> { get }
    var profile$: BehaviorRelay<UIImage> { get }
    var nickname$: BehaviorRelay<String> { get }
    var work$: BehaviorRelay<UIImage> { get }
    var like$: BehaviorRelay<UIImage> { get }
    var likeCount$: BehaviorRelay<String> { get }
    var nft$: BehaviorRelay<UIImage> { get }
    var titleLabel$: BehaviorRelay<String> { get }
    var desc$: BehaviorRelay<String> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class FeedDetailViewModel: FeedDetailViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        var likeClick: AnyObserver<Void>
        var report: AnyObserver<Void>
    }
    
    struct Output {
        var artist: Driver<Artist>
        var profile: Driver<UIImage>
        var nickname: Driver<String>
        var work: Driver<UIImage>
        var like: Driver<UIImage>
        var likeCount: Driver<String>
        var nft: Driver<UIImage>
        var titleLabel: Driver<String>
        var desc: Driver<String>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: OUTPUT
    
    internal let likeClick$: PublishSubject<Void>
    internal let report$: PublishSubject<Void>
    
    // MARK: OUTPUT
    
    internal let artist$: BehaviorRelay<Artist>
    internal let profile$: BehaviorRelay<UIImage>
    internal let nickname$: BehaviorRelay<String>
    internal let work$: BehaviorRelay<UIImage>
    internal let like$: BehaviorRelay<UIImage>
    internal let likeCount$: BehaviorRelay<String>
    internal let nft$: BehaviorRelay<UIImage>
    internal let titleLabel$: BehaviorRelay<String>
    internal let desc$: BehaviorRelay<String>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: FeedFetchable = FeedService(),
         _ selectedFeed: Feed = Feed.EMPTY) {
        // MARK: INPUT
        let likeClick$ = PublishSubject<Void>()
        let report$ = PublishSubject<Void>()
        
        // MARK: OUTPUT
        print(selectedFeed)
        let artist$ = BehaviorRelay<Artist>(value: selectedFeed.user!)
        let feed$ = BehaviorRelay(value: selectedFeed)
        let workId$ = BehaviorRelay<String>(value: "")
        let profile$ = BehaviorRelay<UIImage>(value: UIImage())
        let nickname$ = BehaviorRelay<String>(value: "")
        let work$ = BehaviorRelay<UIImage>(value: UIImage())
        let like$ = BehaviorRelay<UIImage>(value: UIImage())
        let likeCount$ = BehaviorRelay<String>(value: "0")
        let nft$ = BehaviorRelay<UIImage>(value: UIImage())
        let titleLabel$ = BehaviorRelay<String>(value: "")
        let desc$ = BehaviorRelay<String>(value: "")
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        
        self.input = Input(likeClick: likeClick$.asObserver(),
                           report: report$.asObserver())
        self.likeClick$ = likeClick$
        self.report$ = report$
        
        likeClick$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{ _ in service.like(workId$.value) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                print(response)
                if response.message == "좋아요+1" {
                    let value = String(Int(likeCount$.value)! + 1)
                    likeCount$.accept(value)
                    like$.accept(UIImage(named: "heart_fill_asset")!)
                } else if response.message == "좋아요 취소" {
                    let value = String(Int(likeCount$.value)! - 1)
                    likeCount$.accept(value)
                    like$.accept(UIImage(named: "heart_blank_asset")!)
                }
            })
            .disposed(by: disposeBag)
        
        report$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{ _ in service.report(workId$.value) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                alertMessage$.onNext(response.message!)
            })
            .disposed(by: disposeBag)
        
        feed$
            .map{ $0.post.img }
            .filter{ $0 != "" }
            .flatMap{ ImageLoader.loadImage(from: $0)}
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: {(image) in
                work$.accept(image ?? UIImage())
            })
            .disposed(by: disposeBag)
                
        feed$
            .map{ $0.user!.profile }
            .filter{ $0 != "" }
            .debug()
            .flatMap{ ImageLoader.loadImage(from: $0)}
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: {(image) in
                profile$.accept(image ?? UIImage())
            })
            .disposed(by: disposeBag)
        
                
        // MARK: OUTPUT
        self.output = Output(artist: artist$.asDriver(),
                                     profile: profile$.asDriver(),
                             nickname: nickname$.asDriver(),
                             work: work$.asDriver(),
                             like: like$.asDriver(),
                             likeCount: likeCount$.asDriver(),
                             nft: nft$.asDriver(),
                             titleLabel: titleLabel$.asDriver(),
                             desc: desc$.asDriver(),
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError})
        
        self.artist$ = artist$
        self.profile$ = profile$
        self.nickname$ = nickname$
        self.work$ = work$
        self.like$ = like$
        self.likeCount$ = likeCount$
        self.nft$ = nft$
        self.titleLabel$ = titleLabel$
        self.desc$ = desc$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
    
        artist$.accept(feed$.value.user!)
        workId$.accept(String(feed$.value.post.id))
        nickname$.accept(feed$.value.user!.nickname)
        like$.accept((feed$.value.post.isLike == 0 ?
                      UIImage(named: "heart_blank_asset"):
                        UIImage(named: "heart_fill_asset"))!)
        likeCount$.accept(String(feed$.value.post.like_count))
        nft$.accept((feed$.value.post.nft == 0 ?
                     UIImage():
                        UIImage(named: "nft_asset"))!)
        titleLabel$.accept(feed$.value.post.title)
        desc$.accept(feed$.value.post.text)
    }
}
