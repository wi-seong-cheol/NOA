//
//  FeedService.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import RxSwift

class PostService {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    //포스트 리스트 조회 메소드
    func getPostList()-> Observable<[FeedResponse]>? {
        let URL = apiUrlService.serviceUrl(version: "", path: "/posts")
        
        return apiRequestService.getable(URL: URL, query: nil, interceptor: .none)
    }
}
