//
//  UserInfo.swift
//  NOA
//
//  Created by wi_seong on 2022/05/11.
//

import Foundation

import UIKit

class UserInfo {
    static let shared = UserInfo()
    
    private let userInfo = UserDefaults.standard
    
    internal func getIamge(_ key: String) -> UIImage{
        if let imgData = UserDefaults.standard.object(forKey: key) as? NSData {
            if let image = UIImage(data: imgData as Data) {
                return image
            }
        }
        return UIImage()
    }
    
    internal func setImage(_ key: String, _ image: UIImage, _ compression: CGFloat) {
        userInfo.setValue(image.jpegData(compressionQuality: compression), forKey: key)
        
    }
    
    // 처음 어플 시작할 경우
    internal func isJoin() -> Bool {
        if userInfo.object(forKey: "isJoin") == nil {
            return false
        } else {
            return true
        }
    }
    
    internal func joinCkeck() {
        userInfo.set(true, forKey:"isJoin")
    }
    
    internal func saveWallet(_ wallet :Wallet) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(wallet) {
            userInfo.set(encoded, forKey: "wallet")
        }
    }
    
    internal func getWallet() -> Wallet {
        if let wallet = userInfo.object(forKey: "wallet") as? Data {
            let decoder = JSONDecoder()
            let result = try? decoder.decode(Wallet.self, from: wallet)
            return result!
        } else {
            return Wallet(address: "", data: Data(), name: "", isHD: false)
        }
    }
    
    // Save User Data
    internal func saveUser(_ user :User) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            userInfo.set(encoded, forKey: "user")
        }
    }
    
    internal func getUser() -> User {
        if let user = userInfo.object(forKey: "user") as? Data {
            let decoder = JSONDecoder()
            let result = try? decoder.decode(User.self, from: user)
            return result!
        } else {
            return User(id: -1, nickname: "", profile: "", status_message: "", push_token: "")
        }
    }
    
//    // Save Push Token
//    internal func savePushToken(_ pushToken :String) {
//        userInfo.set(pushToken, forKey: "pushToken")
//    }
//
//    internal func getPushToken() -> String {
//        if userInfo.object(forKey: "pushToken") == nil {
//            userInfo.set("", forKey: "pushToken")
//            return ""
//        } else {
//            return userInfo.object(forKey: "pushToken") as! String
//        }
//    }
    
    internal func getDeviceID() -> String {
        if userInfo.object(forKey: "deviceId") == nil {
            let deviceId = UIDevice.current.identifierForVendor!.uuidString
            userInfo.set(deviceId, forKey: "deviceId")
            return deviceId
        } else {
            return userInfo.object(forKey: "deviceId") as! String
        }
    }
    
    internal func saveIsLogin(_ isLogin :Bool) {
        userInfo.set(isLogin, forKey: "isLogin")
    }
    
    internal func getIsLogin() -> Bool {
        if userInfo.object(forKey: "isLogin") == nil {
            userInfo.set(false, forKey: "isLogin")
            return false
        } else {
            return userInfo.object(forKey: "isLogin") as! Bool
        }
    }
}
