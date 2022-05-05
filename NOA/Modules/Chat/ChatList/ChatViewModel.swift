//
//  ChatViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/23.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift

protocol ChatViewModelType {
    // MARK: INPUT
    var fetchList: AnyObserver<Void> { get }
    
    // MARK: OUTPUT
    var items: Observable<[Lecture]> { get }
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
}

class ChatViewModel: ChatViewModelType {
    
    let disposeBag = DisposeBag()
    
    let realm = try! Realm()
    // MARK: INPUT
    let fetchList: AnyObserver<Void>
    
    // MARK: OUTPUT
    let items: Observable<[Lecture]>
    let activated: Observable<Bool>
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        let fetching = PublishSubject<Void>()
        
        let itemList = BehaviorRelay<[Lecture]>(value: [])
        
        let activating = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        // MARK: INPUT
        fetchList = fetching.asObserver()
        
        fetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap(service.list)
            .do(onNext: { _ in activating.onNext(false) })
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: { response in
                itemList.accept(response.lectures)
            })
            .disposed(by: disposeBag)
        
        // MARK: OUTPUT
        items = itemList.asObservable()
                    
        errorMessage = error.map { $0 as NSError }
        
        activated = activating.distinctUntilChanged()
    }
    
    func sendMessage() {
        let content = ChatLocalDB(value: ["id": "", "name": "", "contents": "", "profile": "", "date": "", "count": 1])
        if realm.objects(ChatListLocalDB.self).isEmpty == true {
            let chatModel = ChatListLocalDB()
            chatModel.chat.append(content)
            
            try! realm.write {
                realm.add(chatModel)
            }
        } else {
            try! realm.write {
                let chatModel = realm.objects(ChatListLocalDB.self)
                chatModel.first?.chat.append(content)
            }
        }
    }
    
    func receiveMessage(sender: String, text: String) {
        
        let content = ChatLocalDB(value: ["id": "", "name": "", "contents": "", "profile": "", "date": "", "count": 1])
            
            if realm.objects(ChatListLocalDB.self).isEmpty == true {
                let chatModel = ChatListLocalDB()
                chatModel.chat.append(content)
            } else {
                try! realm.write {
                    let chatModel = realm.objects(ChatListLocalDB.self)
                    chatModel.first?.chat.append(content)
                }
            }
    }
}
