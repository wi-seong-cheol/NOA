//
//  ChatService.swift
//  NOA
//
//  Created by wi_seong on 2022/05/30.
//

import Foundation
import RxSwift
import Alamofire
import RxRelay

protocol ChatFetchable {
    func roomlist() -> Observable<[ChatRoom]>
    func like(_ postId: String) -> Observable<CommonResponse>
    func makeRoom(_ otherId: String) -> Observable<CommonResponse>
}

class ChatService: ChatFetchable {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    func makeRoom(_ otherId: String) -> Observable<CommonResponse> {
        
        let URL = apiUrlService.serviceUrl(.makeRoom)
        let user = UserInfo.shared.getUser()
        let body: [String: Any] = ["user_code": user.id,
                                    "partner_code": otherId]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.postable(URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
    
    //포스트 리스트 조회 메소드
    func roomlist() -> Observable<[ChatRoom]> {
        let URL: String = apiUrlService.serviceUrl(.chatList)
        let user = UserInfo.shared.getUser()
        let query: [String: Any] = ["user_code": user.id]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    func like(_ postId: String) -> Observable<CommonResponse> {
        let URL = apiUrlService.serviceUrl(.likePosting)
        let body: [String: Any] = ["post_id": postId]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.postable(URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
    
    func chatList(_ room_id: Int, _ page: Int) -> Observable<[Message]> {
        let URL: String = apiUrlService.serviceUrl(.messages)
        let query: [String: Any] = ["room_id": room_id,
                                    "page": page]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])

        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
}


