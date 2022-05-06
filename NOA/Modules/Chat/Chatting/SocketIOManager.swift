//
//  SocketIOManager.swift
//  NOA
//
//  Created by wi_seong on 2022/05/06.
//

import RxCocoa
import RxSwift
import SocketIO

final class SocketIOManager {

    static let shared = SocketIOManager()

    private var socketManager: SocketManager!
    private let disposeBag = DisposeBag()
    private var socket: SocketIOClient {
        return socketManager.defaultSocket //.socket(forNamespace: "/my-namespace")
    }

    // Call start from the singleton
    func start() {
        guard socketManager == nil else {
            return
        }

        // Initialize socket manager
        socketManager = SocketManager(
            socketURL: URL(string: "ws://localhost:3000")!,
            config: [.log(true), .compress]
        )
    }
    
    // socket connection state
    func addListeners() {
        // socket emit
        
        // socket listenermes
    }
    
    // socket common function
//    func emitMessage(events: String, message: [String: Any]) {
//        socket.emit(events, with: [message], completion: nil)
//    }
//
//    func listenMessage(events: String, message: [String: Any],
//                       handler: @escaping (_ message: Message) -> Void){
//        socket.on(events){ (data, ack) in
//            handler(message)
//        }
//    }
    
    // socket emit
    func sendMessage(message: MyMessage) {
//        let msg: [String: Any] = [
//            "NodeJS Server Port": "Hello"
//        ]
        //("sendMessage", with: [msg], completion: nil)
        socket.emit("NodeJS Server Port", message.message)
    }
    
    // socket listener
    func newMessage(handler: @escaping (_ message: OtherMessage) -> Void) {
        socket.on("iOS Client Port") { (data, ack) in
            let msg = data[0] as! [String: Any]
            let message = OtherMessage(id: "",
                                       nickname: "Test",
                                       profile: "",
                                       message: msg["msg"]  as! String,
                                       timestamp: "1231")
            handler(message)
        }
    }
    
    // socket connection state
    func connect() {
        print("dsf")
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
        socket.emit("SIGINT", completion: nil)
        print("Socket Session all disconnected")
    }
    
    func didConnect(handler: @escaping () -> Void){
        socket.on(clientEvent: .connect) { (data, ack) in
            print("App Chat: socket connected")
            handler()
        }
    }
    
    func didDisConnect(handler: @escaping () -> Void){
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("App Chat: Disconnect")
            handler()
        }
    }
    
    func didReConnect(handler: @escaping () -> Void){
        socket.on(clientEvent: .reconnect) { (data, ack) in
            print("App Chat: reconnect")
            handler()
        }
    }
    
    func didReconnectAttemp(handler: @escaping () -> Void){
        socket.on(clientEvent: .reconnectAttempt) { (data, ack) in
            print("App Chat: reconnectAttempt")
            handler()
        }
    }
}
