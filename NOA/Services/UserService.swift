//
//  UserService.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import RxSwift

protocol UserFetchable {
    func getUserData() -> Observable<[UserResponse]>
    func getTestData()-> Observable<LectureList>
}

class UserService: UserFetchable {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    // User Data 조회 메소드
    func getUserData()-> Observable<[UserResponse]> {
        let URL = apiUrlService.serviceUrl(version: "", path: "/courseList")
        let query: [String: Any] = ["serviceKey": DBInfo.serviceKey, "Mobile": 1]
        return apiRequestService.getable(URL: URL, query: query, interceptor: .none) ?? Observable.empty()
    }
    
    // Test 메소드
    func getTestData()-> Observable<LectureList> {
        let URL = "http://apis.data.go.kr/B552881/kmooc/courseList?serviceKey=LwG%2BoHC0C5JRfLyvNtKkR94KYuT2QYNXOT5ONKk65iVxzMXLHF7SMWcuDqKMnT%2BfSMP61nqqh6Nj7cloXRQXLA%3D%3D"
//        let URL = apiUrlService.serviceUrl(version: "", path: "/courseList")
        let query: [String: Any] = ["Mobile": 1]
//        let query: [String: Any] = ["serviceKey": DBInfo.serviceKey, "Mobile": 1]
        return apiRequestService.getable(URL: URL, query: query, interceptor: .none) ?? Observable.empty()
    }
}
