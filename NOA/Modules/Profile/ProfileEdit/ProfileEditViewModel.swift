//
//  ProfileEditViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/06/03.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol ProfileEditViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var edit$: PublishSubject<Void> { get }
    var profileInput$: BehaviorSubject<UIImage> { get }
    var nicknameInput$: BehaviorSubject<String> { get }
    var statusMessageInput$: BehaviorSubject<String> { get }
    
    // MARK: OUTPUT
    var nickname$: BehaviorRelay<String> { get }
    var statusMessage$: BehaviorRelay<String> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class ProfileEditViewModel: ProfileEditViewModelType {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        var edit: AnyObserver<Void>
        var profileInput: AnyObserver<UIImage>
        var nicknameInput: AnyObserver<String>
        var statusMessageInput: AnyObserver<String>
    }
    
    struct Output {
        var nickname: Driver<String>
        var statusMessage: Driver<String>
        var profile: Driver<UIImage>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let edit$: PublishSubject<Void>
    internal let profileInput$: BehaviorSubject<UIImage>
    internal let nicknameInput$: BehaviorSubject<String>
    internal let statusMessageInput$: BehaviorSubject<String>
    
    // MARK: OUTPUT
    internal var nickname$: BehaviorRelay<String>
    internal var statusMessage$: BehaviorRelay<String>
    internal let profile$: BehaviorRelay<UIImage>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: UserFetchable = UserService()) {
        
        var user = UserInfo.shared.getUser()
        
        // MARK: INPUT
        let edit$ = PublishSubject<Void>()
        let profileChange$ = PublishSubject<UIImage>()
        let statusMessageChange$ = PublishSubject<String>()
        let nicknameChange$ = PublishSubject<String>()
        let profileInput$ = BehaviorSubject<UIImage>(value: UIImage())
        let nicknameInput$ = BehaviorSubject<String>(value: "")
        let statusMessageInput$ = BehaviorSubject<String>(value: "")
        
        // MARK: OUTPUT
        let nickname$ = BehaviorRelay<String>(value: user.nickname)
        let statusMessage$ = BehaviorRelay<String>(value: user.status_message)
        let profile$ = BehaviorRelay<UIImage>(value: UIImage())
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: INPUT
        self.input = Input(edit: edit$.asObserver(),
                           profileInput: profileInput$.asObserver(),
                           nicknameInput: nicknameInput$.asObserver(),
                           statusMessageInput: statusMessageInput$.asObserver())
        
        self.edit$ = edit$
        self.profileInput$ = profileInput$
        self.nicknameInput$ = nicknameInput$
        self.statusMessageInput$ = statusMessageInput$
        
        edit$
            .do(onNext: { _ in activated$.onNext(true)})
            .flatMapLatest{ _ in service.nicknameEdit(nickname$.value)}
            .filter{ response in
                if response.status_code == 200 {
                    user.nickname = nickname$.value
                    return true
                } else {
                    alertMessage$.onNext("잠시 후 다시 시도해주세요.")
                    return false
                }
            }
            .flatMapLatest{ _ in service.statusMessageEdit(statusMessage$.value)}
            .filter{ response in
                if response.status_code == 200 {
                    user.status_message = statusMessage$.value
                    return true
                } else {
                    alertMessage$.onNext("잠시 후 다시 시도해주세요.")
                    return false
                }
            }
            .flatMapLatest{ _ in service.profileEdit(profile$.value.jpegData(compressionQuality: 0.1)!)}
            .do(onNext: { _ in activated$.onNext(false)})
            .do(onError: { err in
                activated$.onNext(false)
                errorMessage$.onNext(err)
            })
            .subscribe(onNext: { response in
                if response.status_code == 200 {
//                    user.profile =
                    alertMessage$.onNext("프로필이 수정되었습니다.")
                } else {
                    alertMessage$.onNext("잠시 후 다시 시도해주세요.")
                }
            })
            .disposed(by: disposeBag)
            
        profileInput$
            .bind(to: profile$)
            .disposed(by: disposeBag)
        
        ImageLoader.loadImage(from: user.profile)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (image) in
                profile$.accept(image ?? UIImage())
            })
            .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        self.output = Output(nickname: nickname$.asDriver(onErrorJustReturn: user.nickname),
                             statusMessage: statusMessage$.asDriver(onErrorJustReturn: user.status_message),
                             profile: profile$.asDriver(onErrorJustReturn: UIImage()),
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
        self.nickname$ = nickname$
        self.statusMessage$ = statusMessage$
        self.profile$ = profile$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
                
        
    }
}

