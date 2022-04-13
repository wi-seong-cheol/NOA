//
//  APIService.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation

class APIUrlService {
    
    @Inject var readPList: ReadPList
    
    func serviceUrl(version: String, path: String) -> String {
       //개발
        return readPList.getAPIUrlPlistInfo() + version + path
   }
}
