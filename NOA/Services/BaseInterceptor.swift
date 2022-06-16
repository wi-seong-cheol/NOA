//
//  BaseInterceptor.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Alamofire
final class BaseInterceptor: RequestInterceptor {
    private let retryLimit = 1
    private var retryCount = 0
    
    let service: AuthFetchable = AuthService()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        print("BaseInterceptor  - adpat() called")
        
        var request = urlRequest
        let tk = Token()
        
        guard let accessToken = tk.load(account: "accessToken") else {
            return
        }
        
        request.headers.add(.authorization(bearerToken: accessToken))
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        guard let statusCode =
                request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }
        
        switch statusCode {
        case 401:
            if retryCount < retryLimit {
                retryCount += 1
                print("BaseInterceptor  - retry() called")
                let status = service.refresh()
                print(status)
                completion(.retryWithDelay(1))
            } else {
                completion(.doNotRetry)
            }
        default:
            completion(.doNotRetry)
        }
    }
}
