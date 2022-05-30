//
//  Token.swift
//  NOA
//
//  Created by wi_seong on 2022/05/27.
//

import Foundation
import Alamofire

class Token {
    
    static let shared: Token = Token()
    
    private let serviceID = "com.wi-seong.NOA"
    // 키 체인에 값을 저장
    func save(account: String, value: String) {
        // 키 체인 쿼리
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.serviceID,
            kSecAttrAccount: account,
            kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
        ]
        
        // 현재 저장되어 있는 값 삭제 (기존의 값을 덮어쓰지 못하기 때문)
        SecItemDelete(keyChainQuery)
        
        // 새로운 키 체인 아이템 등록
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "토큰 값 저장에 실패했습니다")
        NSLog("status=\(status)")
    }
    
    // 키 체인에 저장된 값을 읽어옴
    func load(account: String) -> String? {
        // 키 체인 쿼리
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.serviceID,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        // 키 체인에 저장된 값을 읽어옴
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataTypeRef)
        
        // 처리 결과가 성공이면 Data 타입으로 변환 - 다시 String 타입으로 변환
        if (status == errSecSuccess) {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: String.Encoding.utf8)
            return value
        } else { // 실패면 nil 반환
            print("Nothing was retrieved from the keychain. Status code \(status)")
            return nil
        }
    }
    
    // 키 체인에 저장된 값을 삭제
    func delete(account: String) {
        // 키 체인 쿼리
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.serviceID,
            kSecAttrAccount: account
        ]
        
        // 저장되어 있는 값 삭제
        let status = SecItemDelete(keyChainQuery)
        assert(status == noErr, "토큰 값 삭제에 실패했습니다")
        NSLog("status=\(status)")
    }
}
