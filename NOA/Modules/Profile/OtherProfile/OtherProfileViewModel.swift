//
//  OtherProfileViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/28.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import RealmSwift

protocol OtherProfileViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var load$: PublishSubject<Void> { get }
    var imageLoad$: PublishSubject<String> { get }
    var follow$: PublishSubject<Void> { get }
    var message$: PublishSubject<Void> { get }
    
    // MARK: OUTPUT
    var roomId: BehaviorRelay<Int> { get }
    var move$: BehaviorSubject<Bool> { get }
    var followLabel$: BehaviorRelay<String> { get }
    var artist$: BehaviorRelay<Artist> { get }
    var id$: BehaviorRelay<Int> { get }
    var profile$: BehaviorRelay<UIImage> { get }
    var nickname$: BehaviorRelay<String> { get }
    var status$: BehaviorRelay<String> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class OtherProfileViewModel: OtherProfileViewModelType {
    
    let disposeBag = DisposeBag()
    let realm = try! Realm()
    
    struct Input {
        var load: AnyObserver<Void>
        var imageLoad: AnyObserver<String>
        var follow: AnyObserver<Void>
        var message: AnyObserver<Void>
    }
    
    struct Output {
        var move: Observable<Bool>
        var followLabel: Driver<String>
        var artist: Driver<Artist>
        var id: Driver<Int>
        var profile: Driver<UIImage>
        var nickname: Driver<String>
        var status: Driver<String>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }

    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let load$: PublishSubject<Void>
    internal let imageLoad$: PublishSubject<String>
    internal let follow$: PublishSubject<Void>
    internal let message$: PublishSubject<Void>
    
    // MARK: OUTPUT
    internal let roomId: BehaviorRelay<Int>
    internal let move$: BehaviorSubject<Bool>
    internal let followLabel$: BehaviorRelay<String>
    internal let artist$: BehaviorRelay<Artist>
    internal let id$: BehaviorRelay<Int>
    internal let profile$: BehaviorRelay<UIImage>
    internal let nickname$: BehaviorRelay<String>
    internal let status$: BehaviorRelay<String>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(userService: UserFetchable = UserService(),
         chatService: ChatFetchable = ChatService(),
         _ artist: Artist = Artist.EMPTY) {
        // MARK: INPUT
        let load$ = PublishSubject<Void>()
        let imageLoad$ = PublishSubject<String>()
        let follow$ = PublishSubject<Void>()
        let message$ = PublishSubject<Void>()
        
        // MARK: OUTPUT
        let roomId = BehaviorRelay<Int>(value: 0)
        let move$ = BehaviorSubject<Bool>(value: false)
        let followLabel$ = BehaviorRelay<String>(value: "친구 추가")
        let artist$ = BehaviorRelay(value: artist)
        let id$ = BehaviorRelay(value: artist.user_code)
        let profile$ = BehaviorRelay<UIImage>(value: UIImage())
        let nickname$ = BehaviorRelay<String>(value: artist.nickname)
        let status$ = BehaviorRelay<String>(value: "")
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(load: load$.asObserver(),
                           imageLoad: imageLoad$.asObserver(),
                           follow: follow$.asObserver(),
                           message: message$.asObserver())
        self.roomId = roomId
        self.move$ = move$
        self.message$ = message$
        self.load$ = load$
        self.imageLoad$ = imageLoad$
        self.follow$ = follow$
        
        load$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMap{ userService.getUser(String(id$.value)) }
            .do(onError: { err in
                activated$.onNext(false)
                errorMessage$.onNext(err)
            })
            .subscribe(onNext: { response in
                response.isFriend == 1 ? followLabel$.accept("친구") : followLabel$.accept("친구 추가")
                status$.accept(response.user_desc ?? "")
            })
            .disposed(by: disposeBag)
                
        artist$
            .map{ $0.profile }
            .filter{ $0 != "" }
            .flatMap{ ImageLoader.loadImage(from: $0)}
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in
                activated$.onNext(false)
                errorMessage$.onNext(err)
            })
            .subscribe(onNext: {(image) in
                profile$.accept(image ?? UIImage())
            })
            .disposed(by: disposeBag)
                
        follow$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMap{ userService.follow(String(id$.value))}
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                if response.message == "친구삭제 완료" {
                    followLabel$.accept("친구 추가")
                } else {
                    followLabel$.accept("친구")
                }
            })
            .disposed(by: disposeBag)
        
        message$
            .do(onNext: { _ in activated$.onNext(true) })
            .flatMap{ chatService.makeRoom(String(id$.value))}
            .do(onNext: { _ in activated$.onNext(false) })
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                if response.status_code == 200 {
                    followLabel$.accept("친구 추가")
                    roomId.accept(Int(response.message!)!)
                    move$.onNext(true)
                } else {
                    alertMessage$.onNext("잠시 후 다시 시도해주세요.")
                }
            })
            .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        self.output = Output(move: move$.asObservable(),
                             followLabel: followLabel$.asDriver(onErrorJustReturn: ""),
                                     artist: artist$.asDriver(onErrorJustReturn: Artist.EMPTY),
                             id: id$.asDriver(onErrorJustReturn: 0),
                             profile: profile$.asDriver(onErrorJustReturn: UIImage()),
                             nickname: nickname$.asDriver(onErrorJustReturn: ""),
                             status: status$.asDriver(onErrorJustReturn: ""),
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
        self.followLabel$ = followLabel$
        self.artist$ = artist$
        self.id$ = id$
        self.profile$ = profile$
        self.nickname$ = nickname$
        self.status$ = status$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
        
    }
}
