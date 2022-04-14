//
//  UIViewController + Extension.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation
import UIKit

extension UIViewController {
    func alert(title: String, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.view.tintColor = .black
        actions.forEach {
            alertController.addAction($0)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func OKDialog(_ message: String){
        DispatchQueue.main.async {
            let message = NSLocalizedString(message,
                                            comment: "message")
            let actions = [
                UIAlertAction(title: NSLocalizedString("OK", comment: "Alert ok"),
                              style: .`default`,
                              handler: nil)
            ]
            self.alert(title: "", message: message, actions: actions)
        }
    }
}
