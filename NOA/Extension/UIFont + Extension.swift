//
//  UIFont + Extension.swift
//  NOA
//
//  Created by wi_seong on 2022/04/28.
//

import Foundation
import UIKit

extension UIFont {
    
    class func NotoSansCJKkr(type: NotoSansCJKkrType, size: CGFloat) -> UIFont! {
        let name = "NotoSansCJKkr"
        guard let font = UIFont(name: name + type.name, size: size) else {
            print("Do not Font")
            return nil
        }
        return font
    }
    
    enum NotoSansCJKkrType {
        case medium
        case regular
        
        var name: String {
            switch self {
            case .medium:
                return "-Medium"
            case .regular:
                return "-Regular"
            }
        }
    }
}
