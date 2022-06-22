//
//  ChatViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/23.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol ChatViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var fetchList$: PublishSubject<Void> { get }
    
    // MARK: OUTPUT
    var items$: BehaviorRelay<[ChatRoom]> { get }
    var activated$: Observable<Bool> { get }
    var errorMessage$: Observable<Error> { get }
}

class ChatViewModel: ChatViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let fetchList: AnyObserver<Void>
    }
    
    struct Output {
        let items: Driver<[ChatRoom]>
        let activated: Observable<Bool>
        let errorMessage: Observable<NSError>
    }
        
    let input: Input
    let output: Output
        
    // MARK: INPUT
    internal let fetchList$: PublishSubject<Void>
    
    // MARK: OUTPUT
    internal let items$: BehaviorRelay<[ChatRoom]>
    internal let activated$: Observable<Bool>
    internal let errorMessage$: Observable<Error>
    
    init(service: ChatFetchable = ChatService()) {
        // MARK: Input
        let fetchList$ = PublishSubject<Void>()
        
        // MARK: Output
        let items$ = BehaviorRelay<[ChatRoom]>(value: [])
        let activated$ = BehaviorSubject<Bool>(value: false)
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(fetchList: fetchList$.asObserver())
        
        self.fetchList$ = fetchList$
        
        fetchList$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMapLatest(service.roomlist)
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                items$.accept(response)
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
