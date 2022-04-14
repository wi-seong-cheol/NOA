//
//  APIService.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import SystemConfiguration

class APIRequestService {
    
    @Inject var header: HeaderCommon
    @Inject var globalAlert: GlobalAlert
    
    func getable<T:Codable>(URL: String, query:[String:Any]?, interceptor: Interceptor?)-> Observable<T>? {
        if let vc = UIApplication.topViewController() {
            print("2134")
            globalAlert.commonAlert(title: "네트워크 연결 확인\n", content: "네트워크 연결이 되어있지 않습니다.\n연결상태를 확인해주세요.", vc: vc)
        } else {
            print("wertyui")
        }
        if isInternetAvailable() {
            print("123")
            print(query)
            if RxAlamofire.requestData(.get, URL,
                                       parameters: query,
                                       encoding: URLEncoding.default,
                                       headers: header.headerSetting(),
                                       interceptor: interceptor)
                .mapObject(type: T.self) == nil {
                print("2131")
            } else {
                print("12415135")
            }
            return RxAlamofire.requestData(.get, URL,
                                           parameters: query,
                                           encoding: URLEncoding.default,
                                           headers: header.headerSetting(),
                                           interceptor: interceptor)
                .mapObject(type: T.self)
        } else {
            let window = UIApplication.shared.windows.first {$0.isKeyWindow} //최상단 뷰 select
            if let vc = UIApplication.topViewController() {
                globalAlert.commonAlert(title: "네트워크 연결 확인\n", content: "네트워크 연결이 되어있지 않습니다.\n연결상태를 확인해주세요.", vc: vc)
            }
            return nil
        }
        
    }
    
    func postable<T:Codable>(URL: String, body:[String:Any]?, interceptor: Interceptor?)-> Observable<T>? {
        if isInternetAvailable() {
            return RxAlamofire.requestData(.post, URL,
                                           parameters: body,
                                           encoding: JSONEncoding.default,
                                           headers: header.headerSetting(),
                                           interceptor: interceptor)
                .mapObject(type: T.self)
        }else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow } //최상단 뷰 select
            if let vc = window?.rootViewController {
                globalAlert.commonAlert(title: "네트워크 연결 확인\n", content: "네트워크 연결이 되어있지 않습니다.\n연결상태를 확인해주세요.", vc: vc)
            }
            return nil
        }
        
    }
    
    func deletaable<T:Codable>(URL:String, body:[String:Any]?, interceptor: Interceptor?)-> Observable<T>? {
        if isInternetAvailable() {
            return RxAlamofire.requestData(.delete, URL,
                                           parameters: body,
                                           encoding: JSONEncoding.default,
                                           headers: header.headerSetting(),
                                           interceptor: interceptor)
                .mapObject(type: T.self)
        }else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow } //최상단 뷰 select
            if let vc = window?.rootViewController {
                globalAlert.commonAlert(title: "네트워크 연결 확인\n", content: "네트워크 연결이 되어있지 않습니다.\n연결상태를 확인해주세요.", vc: vc)
            }
            return nil
        }
        
    }
    
    func putable<T:Codable>(URL:String, body:[String:Any]?, interceptor: Interceptor?)-> Observable<T>? {
        if isInternetAvailable() {
            return RxAlamofire.requestData(.put, URL,
                                           parameters: body,
                                           encoding: JSONEncoding.default,
                                           headers: header.headerSetting(),
                                           interceptor: interceptor)
                .mapObject(type: T.self)
        }else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow } //최상단 뷰 select
            if let vc = window?.rootViewController {
                globalAlert.commonAlert(title: "네트워크 연결 확인\n", content: "네트워크 연결이 되어있지 않습니다.\n연결상태를 확인해주세요.", vc: vc)
            }
            return nil
        }
        
    }
    
    func patchable<T:Codable>(URL:String, body:[String:Any]?, interceptor: Interceptor?)-> Observable<T>? {
        if isInternetAvailable() {
            return RxAlamofire.requestData(.patch, URL,
                                           parameters: body,
                                           encoding: JSONEncoding.default,
                                           headers: header.headerSetting(),
                                           interceptor: interceptor)
                .mapObject(type: T.self)
        }else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow } //최상단 뷰 select
            if let vc = window?.rootViewController {
                globalAlert.commonAlert(title: "네트워크 연결 확인\n", content: "네트워크 연결이 되어있지 않습니다.\n연결상태를 확인해주세요.", vc: vc)
            }
            return nil
        }
        
    }
    
    
    //네트워크 연결상태 확인
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            
            return false
            
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}

