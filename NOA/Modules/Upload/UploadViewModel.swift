//
//  UploadViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import RealmSwift
import web3swift
import SwiftyJSON
import UIKit
import Alamofire

protocol UploadViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
//    var upload: AnyObserver<Void> { get }
    var upload$: PublishSubject<Void> { get }
    var uploadNFT$: PublishSubject<Void> { get }
    var subject$: BehaviorSubject<String> { get }
    var desc$: BehaviorSubject<String> { get }
    var image$: BehaviorSubject<Data> { get }
    
    // MARK: OUTPUT
    var move$: BehaviorSubject<Bool> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class UploadViewModel: UploadViewModelType {
    
    let disposeBag = DisposeBag()
    let realm = try! Realm()
    
    struct Input {
        var upload: AnyObserver<Void>
        var uploadNFT: AnyObserver<Void>
        var subject: AnyObserver<String>
        var desc: AnyObserver<String>
        var image: AnyObserver<Data>
    }
    
    struct Output {
        var move: Observable<Bool>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
    
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let upload$: PublishSubject<Void>
    internal let uploadNFT$: PublishSubject<Void>
    internal let subject$: BehaviorSubject<String>
    internal let desc$: BehaviorSubject<String>
    internal let image$: BehaviorSubject<Data>
    
    // MARK: OUTPUT
    internal let move$: BehaviorSubject<Bool>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: UploadFetchable = UploadService()) {
        // MARK: Input
        let upload$ = PublishSubject<Void>()
        let uploadNFT$ = PublishSubject<Void>()
        let subject$ = BehaviorSubject<String>(value: "")
        let desc$ = BehaviorSubject<String>(value: "")
        let image$ = BehaviorSubject<Data>(value: Data())
        
        // MARK: Output
        let postId$ = BehaviorRelay<Int>(value: -1)
        let move$ = BehaviorSubject<Bool>(value: false)
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        
        // MARK: Input
        self.input = Input(upload: upload$.asObserver(),
                           uploadNFT: uploadNFT$.asObserver(),
                           subject: subject$.asObserver(),
                           desc: desc$.asObserver(),
                           image: image$.asObserver())
        
        self.upload$ = upload$
        self.uploadNFT$ = uploadNFT$
        self.subject$ = subject$
        self.desc$ = desc$
        self.image$ = image$
        
        upload$
            .filter{
                if isEmpty(try! subject$.value(), try! desc$.value()) {
                    return true
                } else {
                    alertMessage$.onNext("빈 칸을 채워주세요.")
                    return false
                }
            }
            .do(onNext: { _ in activated$.onNext(true)})
            .flatMapLatest{
                service.upload(data: try! image$.value(),
                               post_nft: 0,
                               post_title: try! subject$.value(),
                               post_text: try! desc$.value(),
                               post_tag: "TEST")
            }
            .do(onNext: { _ in activated$.onNext(false)})
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                if response.status_code == 200 {
                    print(response.message ?? "")
                    move$.onNext(true)
                } else {
                    alertMessage$.onNext("업로드에 실패하였습니다.")
                }
            })
            .disposed(by: disposeBag)
                
        uploadNFT$
            .filter{
                if isEmpty(try! subject$.value(), try! desc$.value()) {
                    return true
                } else {
                    alertMessage$.onNext("빈 칸을 채워주세요.")
                    return false
                }
            }
            .do(onNext: { _ in activated$.onNext(true)})
            .flatMapLatest{
                service.upload(data: try! image$.value(),
                               post_nft: 1,
                               post_title: try! subject$.value(),
                               post_text: try! desc$.value(),
                               post_tag: "TEST")
            }
            .filter{ response in validation(response.message ?? "") }
            .map{ $0.message! }
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest{ service.createNFT(url: $0, title: try! subject$.value(), desc: try! desc$.value()) }
            .do(onNext: { _ in activated$.onNext(false)})
            .do(onError: { err in errorMessage$.onNext(err) })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { response in
                alertMessage$.onNext(response)
                move$.onNext(true)
            })
            .disposed(by: disposeBag)
                
        // MARK: OUTPUT
        self.output = Output(move: move$.asObservable(),
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
                
        self.move$ = move$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$
    }
}

private func validation(_ url: String) -> Bool {
    let pattern = "(?i)(http|https)(:\\/\\/)([^ .]+)(\\.)([^ \n]+)"
    let address = NSPredicate(format: "SELF MATCHES %@", pattern)
    let isValid = address.evaluate(with: url)
    
    return isValid
}

private func isEmpty(_ title: String, _ desc: String) -> Bool {
    if title == "작품 제목을 입력해주세요." || desc == "작품 설명을 입력해주세요." {
        return false
    } else {
        return true
    }
}
