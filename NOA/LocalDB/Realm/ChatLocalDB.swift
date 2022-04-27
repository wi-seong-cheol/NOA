//
//  ChatLocalDB.swift
//  NOA
//
//  Created by wi_seong on 2022/04/25.
//

import Foundation

class ChatLocalDB {
    static let shared = ChatLocalDB()
    
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
    
    internal func getData(_ key: String) -> Any{
        return userInfo.object(forKey: key)!
    }
    
    internal func setData(_ value: Any, _ key: String) {
        userInfo.setValue(value, forKey: key)
    }
}
