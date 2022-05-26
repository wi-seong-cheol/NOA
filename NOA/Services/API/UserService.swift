//
//  UserService.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import RxSwift
import Alamofire

protocol UserFetchable {
//    func getSelfUser() -> Observable<UserResponse>
    func getUser(_ otherId: String) -> Observable<UserResponse>
    func follow(_ otherId: String) -> Observable<CommonResponse>
    func isFriend(_ otherId: String) -> Observable<CommonResponse>
    func friendList(_ page: Int) -> Observable<[UserResponse]>
    func report(_ otherId: String) -> Observable<CommonResponse>
    func profileEdit(_ data: Data) -> Observable<CommonResponse>
    func nicknameEdit(_ nickname: String) -> Observable<CommonResponse>
    func statusMessageEdit(_ message: String) -> Observable<CommonResponse>
}

class UserService: UserFetchable {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
//
//    func getSelfUser() -> Observable<UserResponse> {
//        let URL: String = apiUrlService.serviceUrl(.selfUser)
//        let userId = UserInfo.shared.getUser().id
//        let query: [String: Any] = ["user_code": userId]
//
//        return apiRequestService.getable(URL: URL, query: query, interceptor: .none) ?? Observable.empty()
//    }
    
    func getUser(_ otherId: String) -> Observable<UserResponse> {
        let URL: String = apiUrlService.serviceUrl(.userInfo)
        let userId = UserInfo.shared.getUser().id
        let query: [String: Any] = ["user_code": userId,
                                    "other": otherId]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    func follow(_ otherId: String) -> Observable<CommonResponse> {
        let URL: String = apiUrlService.serviceUrl(.friend)
        let userId = UserInfo.shared.getUser().id
        let body: [String: Any] = ["user_code": userId,
                                    "friend_code": otherId]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.postable(URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
    
    func isFriend(_ otherId: String) -> Observable<CommonResponse> {
        let URL: String = apiUrlService.serviceUrl(.isFriend)
        let userId = UserInfo.shared.getUser().id
        let query: [String: Any] = ["user_code": userId,
                                    "friend_code": otherId]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    func friendList(_ page: Int) -> Observable<[UserResponse]> {
        let URL: String = apiUrlService.serviceUrl(.friendList)
        let userId = UserInfo.shared.getUser().id
        let query: [String: Any] = ["user_code": userId,
                                    "page": page]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    // 유저 신고
    func report(_ otherId: String) -> Observable<CommonResponse> {
        let URL = apiUrlService.serviceUrl(.reportUser)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let body: [String: Any] = ["user_code": userCode,
                                   "reported_user": otherId]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.putable(URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
    
    func profileEdit(_ data: Data) -> Observable<CommonResponse> {
        let URL = apiUrlService.serviceUrl(.changeProfile)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let body: [String: Any] = ["user_code": userCode]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.putUploadable(data: data, URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
    
    func nicknameEdit(_ nickname: String) -> Observable<CommonResponse> {
        let URL = apiUrlService.serviceUrl(.changeNickname)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let body: [String: Any] = ["user_code": userCode,
                                   "user_nickname": nickname]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.putable(URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
    
    func statusMessageEdit(_ message: String) -> Observable<CommonResponse> {
        let URL = apiUrlService.serviceUrl(.changeDesc)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let body: [String: Any] = ["user_code": userCode,
                                   "desc": message]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.putable(URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
}
