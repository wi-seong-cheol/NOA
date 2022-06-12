//
//  UITextView.swift
//  NOA
//
//  Created by wi_seong on 2022/06/05.
//

import Foundation
import UIKit

extension UITextView{
    func numberOfLines() -> Int{
        if let fontUnwrapped = self.font{
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
}

