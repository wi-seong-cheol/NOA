//
//  SearchService.swift
//  NOA
//
//  Created by wi_seong on 2022/05/02.
//

import Foundation
import RxSwift
import Alamofire

protocol SearchFetchable {
    func search(_ keyword: String) -> Observable<[Search]>
}

class SearchService: SearchFetchable {
    var cache = [String: [Search]]()
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    //포스트 리스트 조회 메소드
    func search(_ keyword: String) -> Observable<[Search]> {
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        guard !keyword.isEmpty else {
            return Observable.just([])
        }
        let URL: String = apiUrlService.serviceUrl(.searchTitleContent)
        if keyword != "", let cachedData = self.cache[keyword] {
            return Observable.just(cachedData)
        } else {
            let query: [String: Any] = ["word": keyword]
            return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor)!
                .do(onNext: { data in
                    if keyword != "" {
                        self.cache[keyword] = data
                    }
                })
                .catch{ error in
                    if keyword != "", let cachedData = self.cache[keyword] {
                        return Observable.just(cachedData)
                    } else {
                        return Observable.just([])
                    }
                    
                }
        }
    }
}

