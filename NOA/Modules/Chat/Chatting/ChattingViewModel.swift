//
//  ChattingViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import SocketIO

protocol ChattingViewModelType {
    associatedtype Input
    associatedtype Output
    
    // MARK: INPUT
    var fetchList$: PublishSubject<Void> { get }
    var moreFetchList$: PublishSubject<Void> { get }
    var message$: BehaviorSubject<String> { get }
    var exit$: PublishSubject<Void> { get }
    var disconnect$: PublishSubject<Void> { get }
    var sendMessage$: PublishSubject<Void> { get }
    var registerSocket$: PublishSubject<Void> { get }
    
    // MARK: OUTPUT
    var messages$: BehaviorRelay<[MessageSection]> { get }
    var scroll$: Observable<Bool> { get }
    var activated$: Observable<Bool> { get }
    var alertMessage$: Observable<String> { get }
    var errorMessage$: Observable<Error> { get }
}

class ChattingViewModel: ChattingViewModelType {
    var disposeBag = DisposeBag()
    
    struct Input {
        var fetchList: AnyObserver<Void>
        var moreFetchList: AnyObserver<Void>
        var message: AnyObserver<String>
        var exit: AnyObserver<Void>
        var disconnect: AnyObserver<Void>
        var sendMessage: AnyObserver<Void>
        var registerSocket: AnyObserver<Void>
    }
    
    struct Output {
        var messages: Driver<[MessageSection]>
        var scroll: Observable<Bool>
        var activated: Observable<Bool>
        var alertMessage: Observable<String>
        var errorMessage: Observable<NSError>
    }
        
    let input: Input
    let output: Output
    
    // MARK: INPUT
    internal let fetchList$: PublishSubject<Void>
    internal let moreFetchList$: PublishSubject<Void>
    internal let message$: BehaviorSubject<String>
    internal let exit$: PublishSubject<Void>
    internal let disconnect$: PublishSubject<Void>
    internal let sendMessage$: PublishSubject<Void>
    internal let registerSocket$: PublishSubject<Void>
    
    // MARK: OUTPUT
    internal let messages$:  BehaviorRelay<[MessageSection]>
    internal let scroll$: Observable<Bool>
    internal let activated$: Observable<Bool>
    internal let alertMessage$: Observable<String>
    internal let errorMessage$: Observable<Error>
    
    init(service: ChatService = ChatService(),
        _ selectedRoom: ChatRoom = ChatRoom.EMPTY) {
        let user = UserInfo.shared.getUser()
        
        // MARK: Input
        let fetchList$ = PublishSubject<Void>()
        let moreFetchList$ = PublishSubject<Void>()
        let message$ = BehaviorSubject<String>(value: "")
        let sendMessage$ = PublishSubject<Void>()
        let disconnect$ = PublishSubject<Void>()
        let exit$ = PublishSubject<Void>()
        let registerSocket$ = PublishSubject<Void>()
        let page$ = BehaviorRelay<Int>(value: 0)
        let state$ = BehaviorRelay<Bool>(value: false)
        
        // MARK: OUTPUT
        let messages$ = BehaviorRelay<[MessageSection]>(value: [])
        let created$ = BehaviorRelay<String>(value: "")
        let scroll$ = PublishSubject<Bool>()
        let activated$ = BehaviorSubject<Bool>(value: false)
        let alertMessage$ = BehaviorSubject<String>(value: "")
        let errorMessage$ = PublishSubject<Error>()
        
        // MARK: Input
        self.input = Input(fetchList: fetchList$.asObserver(),
                           moreFetchList: moreFetchList$.asObserver(),
                           message: message$.asObserver(),
                           exit: exit$.asObserver(),
                           disconnect: disconnect$.asObserver(),
                           sendMessage: sendMessage$.asObserver(),
                           registerSocket: registerSocket$.asObserver())
        
        self.fetchList$ = fetchList$
        self.moreFetchList$ = moreFetchList$
        self.message$ = message$
        self.exit$ = exit$
        self.disconnect$ = disconnect$
        self.sendMessage$ = sendMessage$
        self.registerSocket$ = registerSocket$
        
        fetchList$
            .flatMapLatest{service.chatList(selectedRoom.roomId, 0)}
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                var message: [MessageItem] = []
                for msg in response {
                    if msg.msg_from == user.nickname {
                        let otherMessage = OtherMessage(id: String(selectedRoom.owner.user_code),
                                                        nickname: selectedRoom.owner.nickname,
                                                        profile: selectedRoom.owner.profile,
                                                        message: msg.msg_content,
                                                        timestamp: msg.created)
                        message.insert(MessageItem.otherMessageCell(otherMessage), at: 0)
                    } else {
                        let myMessage = MyMessage(id: String(user.id),
                                                  roomId: String(selectedRoom.roomId),
                                                  to: user.nickname,
                                                  from: selectedRoom.owner.nickname,
                                                  message: msg.msg_content,
                                                  timestamp: msg.created)
                        message.insert(MessageItem.myMessageCell(myMessage), at: 0)
                    }
                    created$.accept(msg.created)
                }
                messages$.accept([MessageSection(items: message)])
                page$.accept(1)
            })
            .disposed(by: disposeBag)
                
        moreFetchList$
            .filter{!state$.value}
            .do(onNext: { _ in state$.accept(true)})
            .flatMapLatest{ service.chatList( selectedRoom.roomId, page$.value) }
            .do(onError: { err in errorMessage$.onNext(err) })
            .subscribe(onNext: { response in
                var message: [MessageItem] = []
                for msg in response {
                    if msg.msg_from == user.nickname {
                        let otherMessage = OtherMessage(id: String(selectedRoom.owner.user_code),
                                                        nickname: selectedRoom.owner.nickname,
                                                        profile: selectedRoom.owner.profile,
                                                        message: msg.msg_content,
                                                        timestamp: msg.created)
                        message.insert(MessageItem.otherMessageCell(otherMessage), at: 0)
                    } else {
                        let myMessage = MyMessage(id: String(user.id),
                                                  roomId: String(selectedRoom.roomId),
                                                  to: user.nickname,
                                                  from: selectedRoom.owner.nickname,
                                                  message: msg.msg_content,
                                                  timestamp: msg.created)
                        message.insert(MessageItem.myMessageCell(myMessage), at: 0)
                    }
                    created$.accept(msg.created)
                }
                messages$.accept([MessageSection(items: message)] + messages$.value)
                page$.accept(page$.value + 1)
                scroll$.onNext(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    state$.accept(false)
                }
            })
            .disposed(by: disposeBag)
                
        registerSocket$
            .debug()
            .subscribe(onNext: {
                SocketIOManager.shared.connect()
                SocketIOManager.shared.addListeners()
                SocketIOManager.shared.newMessage{ (message) in
                    let msg = MessageItem.otherMessageCell(OtherMessage(id: String(selectedRoom.owner.user_code),
                                                                                        nickname: selectedRoom.owner.nickname,
                                                                                        profile: selectedRoom.owner.profile,
                                                                                        message: message.message,
                                                                        timestamp: message.timestamp))
                    messages$.accept(messages$.value + [MessageSection(items: [msg])])
                }
                SocketIOManager.shared.didConnect {
                    SocketIOManager.shared.join(String(selectedRoom.roomId))
                }
                SocketIOManager.shared.chatHistory { (messages) in
                    
                }
            })
            .disposed(by: disposeBag)
        
        
        sendMessage$
            .filter{ try! message$.value() !=  "텍스트를 입력해주세요"}
                    .do(onError: { err in errorMessage$.onNext(err) })
                    .subscribe(onNext: {
                        var message: [MessageItem] = []
                        let created = Transform.shared.dateToKTime(time: Date(), format: "yyyy-MM-dd HH:mm:ss")
                        let sendMessage = MyMessage(id: String(user.id),
                                                  roomId: String(selectedRoom.roomId),
                                                  to: user.nickname,
                                                  from: selectedRoom.owner.nickname,
                                                  message: try! message$.value(),
                                                  timestamp: created)
                        SocketIOManager.shared.sendMessage(message: sendMessage)
                        message.append(MessageItem.myMessageCell(sendMessage))
                        messages$.accept(messages$.value + [MessageSection(items: message)])
                    })
                    .disposed(by: disposeBag)
                        
        disconnect$
            .subscribe(onNext: {SocketIOManager.shared.disconnect()})
            .disposed(by: disposeBag)
        
        // MARK: OUTPUT
        self.output = Output(messages: messages$.asDriver(onErrorJustReturn: []),
                             scroll: scroll$.distinctUntilChanged(),
                             activated: activated$.distinctUntilChanged(),
                             alertMessage: alertMessage$.map { $0 as String },
                             errorMessage: errorMessage$.map { $0 as NSError })
        self.messages$ = messages$
        self.scroll$ = scroll$
        self.activated$ = activated$
        self.alertMessage$ = alertMessage$
        self.errorMessage$ = errorMessage$

    }
}

