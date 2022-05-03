//
//  SearchService.swift
//  NOA
//
//  Created by wi_seong on 2022/05/02.
//

import Foundation
import RxSwift

protocol SearchFetchable {
    func search(_ keyword: String) -> Observable<[Search]>
}

class SearchService: SearchFetchable {
    var cache = [String: [Search]]()
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    //포스트 리스트 조회 메소드
    func search(_ keyword: String) -> Observable<[Search]> {
        guard !keyword.isEmpty else {
            return Observable.just([])
        }
        let URL = "https://api.github.com/users/\(keyword)/repos"
        if keyword != "", let cachedData = self.cache[keyword] {
            return Observable.just(cachedData)
        } else {
            return apiRequestService.getable(URL: URL, query: [:], interceptor: .none)!
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

