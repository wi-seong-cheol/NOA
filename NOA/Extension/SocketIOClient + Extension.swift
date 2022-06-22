//
//  SocketIOClient + Extension.swift
//  NOA
//
//  Created by wi_seong on 2022/05/06.
//

import RxSwift
import RxCocoa
import SocketIO

extension SocketIOClient {
    func listen(event: String, relay: PublishRelay<[Any]>) {
        on(event) { items, _ in
           relay.accept(items)
        }
    }
    
    func listen<ResultType>(event: String, result: ResultType, relay: PublishRelay<ResultType>) {
        on(event) { _, _ in
           relay.accept(result)
        }
    }
}
