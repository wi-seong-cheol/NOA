//
//  SocketIOManager.swift
//  NOA
//
//  Created by wi_seong on 2022/05/06.
//

import Foundation
import RxCocoa
import RxSwift
import SocketIO
import RealmSwift

final class SocketIOManager {

    static let shared = SocketIOManager()

    private var socketManager = SocketManager(
        socketURL: URL(string: DBInfo.chatting_url)!,
        config: [.log(true), .compress]
    )
    private let disposeBag = DisposeBag()
    private var socket: SocketIOClient {
        return socketManager.defaultSocket //.socket(forNamespace: "/my-namespace")
    }
    
    // socket connection state
    func addListeners() {
        // socket emit
        
        // socket listenermes
    }
    func join(_ roomId: String) {
        let msg: [String: Any] = [
            "room_id": roomId
        ]
        socket.emit("join", with: [msg], completion: nil)
    }
    // socket emit
    func sendMessage(message: MyMessage) {
        let msg: [String: Any] = [
            "room_id": message.roomId,
            "msg_to": message.to,
            "msg_from": message.from,
            "msg_content": message.message,
            "msg_time": message.timestamp
        ]
        socket.emit("chatting", with: [msg], completion: nil)
    }
    
    // socket listener
    func newMessage(handler: @escaping (_ message: OtherMessage) -> Void) {
        socket.on("chatting") { (data, ack) in
            let msg = data[0] as! [String: Any]
            let message = OtherMessage(id: "",
                                       nickname:  msg["msg_from"]  as! String,
                                       profile: "",
                                       message: msg["msg_content"]  as! String,
                                       timestamp: msg["msg_time"] as! String)
            handler(message)
        }
    }
    
    func chatHistory(handler: @escaping ( _: Any) -> Void){
        socket.on("msg") { (data, ack) in
            handler(data[0])
        }
    }
    
    // socket connection state
    func connect() {
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
