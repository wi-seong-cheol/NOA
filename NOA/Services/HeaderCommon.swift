//
//  HeaderCommon.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import Alamofire

//공통 헤더
class HeaderCommon {

    func headerSetting()-> HTTPHeaders{
        let requestUUID: String = UUID().uuidString.lowercased()
        let userAgent:String = HTTPHeader.defaultUserAgent.value
        
        let headers: HTTPHeaders = [
            "Content-Type":"application/json",
            "Accept":"application/json",
            "X-Request-Id":requestUUID,
            "user-agent":userAgent
        ]

        return headers
    }
}
