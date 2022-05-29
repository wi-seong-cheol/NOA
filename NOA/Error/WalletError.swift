//
//  WalletError.swift
//  NOA
//
//  Created by wi_seong on 2022/05/31.
//

import Foundation

enum WalletError: Error {
    case validation(String)
    case notFound(String)
    case unable(String)
}
