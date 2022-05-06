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
    // MARK: INPUT
    var message: BehaviorRelay<String> { get }
    var sendMessage: AnyObserver<Void> { get }
    var register: AnyObserver<Void> { get }
    
    // MARK: OUTPUT
    var messages: Observable<[MessageSection]> { get }
    var errorMessage: Observable<NSError> { get }
}

class ChattingViewModel: ChattingViewModelType {
    var disposeBag = DisposeBag()
    
    // MARK: INPUT
    let message = BehaviorRelay(value: "")
    let sendMessage: AnyObserver<Void>
    let register: AnyObserver<Void>
    
    // MARK: OUTPUT
    let messages: Observable<[MessageSection]>
    let errorMessage: Observable<NSError>
    
    init(_ selectedFeed: Lecture = Lecture.EMPTY) {
        let sendMessaging = PublishSubject<Void>()
        let registerSocket = PublishSubject<Void>()
        
        let messageList = BehaviorRelay<[MessageSection]>(value: [])
        let error = PublishSubject<Error>()
                
        // MARK: OUTPUT
        messages = messageList.asObservable()
        register = registerSocket.asObserver()
        
        registerSocket
            .subscribe(onNext: {
                SocketIOManager.shared.start()
                SocketIOManager.shared.newMessage{ (message) in
                                    let msg = MessageItem.otherMessageCell(OtherMessage(id: "",
                                                                                     nickname: "Test", profile: "",
                                                                                        message: message.message,
                                                      timestamp: "오후 12:12"))
                    messageList.accept(messageList.value + [MessageSection(items: [msg])])
                }
            })
            .disposed(by: disposeBag)
        
//        (onErrorJustReturn: [Message(id: "",
//                                                                    nickname: "",
//                                                                    profile: "",
//                                                                    message: "error",
//                                                                    timestamp: "오후 12:12")])
        
        errorMessage = error.map { $0 as NSError }
        
        // MARK: INPUT
        sendMessage = sendMessaging.asObserver()
        
        sendMessaging
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: { [weak self] _ in
//                let msg = MessageItem.otherMessageCell(OtherMessage(id: "",
//                                                                 nickname: "Test", profile: "",
//                                                                 message: (self?.message.value)!,
//                                  timestamp: "오후 12:12"))
                let myMessage = MyMessage(id: "",
                                          message: (self?.message.value)!,
           timestamp: "오후 12:12")
                SocketIOManager.shared.sendMessage(message: myMessage)
                let msg = MessageItem.myMessageCell(myMessage)
                messageList.accept(messageList.value + [MessageSection(items: [msg])])
            })
            .disposed(by: disposeBag)
    }
}

