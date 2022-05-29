//
//  Storage.swift
//  NOA
//
//  Created by wi_seong on 2022/05/21.
//

import Foundation

public class Storage {
    static func isFirstTime() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTime") == nil {
            defaults.set("No", forKey:"isFirstTime")
            return true
        } else {
            return false
        }
    }
}
