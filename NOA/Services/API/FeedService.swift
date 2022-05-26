//
//  FeedService.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import RxSwift
import Alamofire

protocol FeedFetchable {
    func homeList(_ page: Int) -> Observable<[Feed]>
    func randomList(_ page: Int) -> Observable<[Feed]>
    func searchList(_ keyword: String, _ page: Int) -> Observable<[Feed]>
    func nftList(_ userId: String, _ page: Int) -> Observable<[Feed]>
    func allWorkList(_ userId: String, _ page: Int) -> Observable<[Feed]>
    func like(_ postId: String) -> Observable<CommonResponse>
    func report(_ postId: String) -> Observable<CommonResponse>
}

class FeedService: FeedFetchable {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    // 홈 피드 조회 메소드
    func homeList(_ page: Int) -> Observable<[Feed]> {
        let URL: String = apiUrlService.serviceUrl(.homeFeed)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let query: [String: Any] = ["user_code": userCode,
                                    "page": page]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    // 랜덤 피드 조회 메소드
    func randomList(_ page: Int) -> Observable<[Feed]> {
        let URL: String = apiUrlService.serviceUrl(.randomFeed)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let query: [String: Any] = ["user_code": userCode,
                                    "page": page]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    // 검색 피드 조회 메소드
    func searchList(_ keyword: String, _ page: Int) -> Observable<[Feed]> {
        let URL: String = apiUrlService.serviceUrl(.searchResult)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let query: [String: Any] = ["word": keyword,
                                    "user_code": userCode,
                                    "page": page]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    // NFT 작품 피드 조회 메소드
    func nftList(_ userId: String, _ page: Int) -> Observable<[Feed]> {
        let URL: String = apiUrlService.serviceUrl(.userNFTPost)
        let query: [String: Any] = ["user_code": userId,
                                    "page": page]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    // 모든 작품 피드 조회 메소드
    func allWorkList(_ userId: String, _ page: Int) -> Observable<[Feed]> {
        let URL: String = apiUrlService.serviceUrl(.userAllPost)
        let query: [String: Any] = ["user_code": userId,
                                    "page": page]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    // 피드 좋아요
    func like(_ postId: String) -> Observable<CommonResponse> {
        let URL = apiUrlService.serviceUrl(.likePosting)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let body: [String: Any] = ["user_code": userCode,
                                   "post_id": postId]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.putable(URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
    
    // 피드 신고
    func report(_ postId: String) -> Observable<CommonResponse> {
        let URL = apiUrlService.serviceUrl(.reportFeed)
        let user = UserInfo.shared.getUser()
        let userCode = user.id
        let body: [String: Any] = ["user_code": userCode,
                                   "reported_post": postId]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.putable(URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
}

