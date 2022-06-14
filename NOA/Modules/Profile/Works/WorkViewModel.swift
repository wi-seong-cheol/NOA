//
//  WorkViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol WorkViewModelType{
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var fetchAllList$: PublishSubject<Void> { get }
    var moreFetchAllList$: PublishSubject<Void> { get }
    var fetchNFTList$: PublishSubject<Void> { get }
    var moreFetchNFTList$: PublishSubject<Void> { get }
    var like$: PublishSubject<String> { get }
    
    // MARK: OUTPUT
    var artist$: BehaviorRelay<Artist> { get }
    var id$: BehaviorRelay<Int> { get }
    var items$: BehaviorRelay<[Feed]> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class WorkViewModel: WorkViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        var fetchAllList: AnyObserver<Void>
        var moreFetchAllList: AnyObserver<Void>
        var fetchNFTList: AnyObserver<Void>
        var moreFetchNFTList: AnyObserver<Void>
        var like: AnyObserver<String>
    }
    
    struct Output {
        var artist: Driver<Artist>
        var id: Driver<Int>
        var items: Driver<[Feed]>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let artist$: BehaviorRelay<Artist>
    internal let id$: BehaviorRelay<Int>
    internal let fetchAllList$: PublishSubject<Void>
    internal let moreFetchAllList$: PublishSubject<Void>
    internal let fetchNFTList$: PublishSubject<Void>
    internal let moreFetchNFTList$: PublishSubject<Void>
    internal let like$: PublishSubject<String>
    
    // MARK: OUTPUT
    internal let items$: BehaviorRelay<[Feed]>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: FeedFetchable = FeedService(),
         _ artist: Artist = Artist.EMPTY) {
        // MARK: INPUT
        let fetchAllList$ = PublishSubject<Void>()
        let moreFetchAllList$ = PublishSubject<Void>()
        let fetchNFTList$ = PublishSubject<Void>()
        let moreFetchNFTList$ = PublishSubject<Void>()
        let like$ = PublishSubject<String>()
        
        // MARK: OUTPUT
        let artist$ = BehaviorRelay(value: artist)
        let id$ = BehaviorRelay(value: artist.user_code)
        let items$ = BehaviorRelay<[Feed]>(value: [])
        let page$ = BehaviorRelay<Int>(value: 0)
        let state$ = BehaviorRelay<Bool>(value: false)
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(fetchAllList: fetchAllList$.asObserver(),
                           moreFetchAllList: moreFetchAllList$.asObserver(),
                           fetchNFTList: fetchNFTList$.asObserver(),
                           moreFetchNFTList: moreFetchNFTList$.asObserver(),
                           like: like$.asObserver())
        
        self.fetchAllList$ = fetchAllList$
        self.moreFetchAllList$ = moreFetchAllList$
        self.fetchNFTList$ = fetchNFTList$
        self.moreFetchNFTList$ = moreFetchNFTList$
        self.like$ = like$
        
        fetchAllList$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{service.allWorkList(String(id$.value), 0)}
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                items$.accept(response)
                page$.accept(1)
            })
            .disposed(by: disposeBag)
                
        moreFetchAllList$
            .filter{!state$.value}
            .do(onNext: { _ in state$.accept(true)})
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{ service.allWorkList(String(id$.value),  page$.value) }
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                print("---> \(response)")
                items$.accept(items$.value + response)
                page$.accept(page$.value + 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    state$.accept(false)
                }
            })
            .disposed(by: disposeBag)
                
        fetchNFTList$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{service.nftList(String(id$.value), 0)}
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                items$.accept(response)
                page$.accept(1)
            })
            .disposed(by: disposeBag)
                    
        moreFetchNFTList$
            .filter{!state$.value}
            .do(onNext: { _ in state$.accept(true)})
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest{ service.nftList(String(id$.value), page$.value) }
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
        self.output = Output(artist: artist$.asDriver(onErrorJustReturn: artist),
                             id: id$.asDriver(onErrorJustReturn: 0),
                             items: items$.asDriver(onErrorJustReturn: []),
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
        
        self.artist$ = artist$
        self.id$ = id$
        self.items$ = items$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
    }
}
