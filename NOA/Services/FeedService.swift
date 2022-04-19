//
//  FeedService.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import RxSwift

protocol FeedFetchable {
    func list() -> Observable<LectureList>
    func next(nextPage: String) -> Observable<LectureList>
}

class FeedService: FeedFetchable {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    //포스트 리스트 조회 메소드
    func list() -> Observable<LectureList> {
        let URL = "http://apis.data.go.kr/B552881/kmooc/courseList?serviceKey=LwG%2BoHC0C5JRfLyvNtKkR94KYuT2QYNXOT5ONKk65iVxzMXLHF7SMWcuDqKMnT%2BfSMP61nqqh6Nj7cloXRQXLA%3D%3D"
        let query: [String: Any] = ["Mobile": 1]
        return apiRequestService.getable(URL: URL, query: query, interceptor: .none) ?? Observable.empty()
    }
    
    func next(nextPage: String) -> Observable<LectureList> {
        let URL = nextPage
        return apiRequestService.getable(URL: URL, query: [:], interceptor: .none) ?? Observable.empty()
    }
}
