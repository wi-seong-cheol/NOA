//
//  AuthService.swift
//  NOA
//
//  Created by wi_seong on 2022/05/26.
//

import Foundation
import RxSwift
import Alamofire

protocol AuthFetchable {
    func duplicate(_ nickname: String) -> Observable<[Duplicate]>
    func refresh() -> Observable<[Duplicate]>
}

class AuthService: AuthFetchable {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    //포스트 리스트 조회 메소드
    func duplicate(_ nickname: String) -> Observable<[Duplicate]> {
        
        let URL: String = apiUrlService.serviceUrl(.duplication)
        let query: [String: Any] = ["nick_name": nickname]
        return apiRequestService.getable(URL: URL, query: query, interceptor: .none) ?? Observable.empty()
    }
    
    func refresh() -> Observable<[Duplicate]> {
        let URL: String = apiUrlService.serviceUrl(.duplication)
        let tk = Token()
        let refreshToken = tk.load(account: "refreshToken")!
        let query: [String: Any] = ["refresh_token": refreshToken]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
}


