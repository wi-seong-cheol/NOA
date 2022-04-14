//
//  UIApplication + Extension.swift
//  NOA
//
//  Created by wi_seong on 2022/04/14.
//

import Foundation
import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.first {$0.isKeyWindow}?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
