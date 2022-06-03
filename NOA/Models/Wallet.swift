//
//  Wallet.swift
//  NOA
//
//  Created by wi_seong on 2022/05/21.
//

import Foundation
import web3swift

struct WalletResponse: Codable {
    let walletAddress: String
    let privateKey: String
    
    init(walletAddress: String,
         privateKey: String) {
        self.walletAddress = walletAddress
        self.privateKey = privateKey
    }
}

struct Wallet: Codable {
    enum walletType {
        case EthereumKeystoreV3
        case BIP39(mnemonic: String)
    }
    
    init(address: String,
         data: Data,
         name: String,
         isHD: Bool) {
        self.address = address
        self.data = data
        self.name = name
        self.isHD = isHD
    }
    
    var name: String = "Wallet"
    var bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
    var password = "web3swift" // We recommend here and everywhere to use the password set by the user.

    var address: String

    var data: Data
    var mnemonics: String? {
        didSet {
            let keystore = try! BIP32Keystore(
                mnemonics: self.mnemonics!,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
            self.data = try! JSONEncoder().encode(keystore.keystoreParams)
            self.isHD = true
            self.address = keystore.addresses!.first!.address
        }
    }
    var isHD: Bool

    init(type: walletType) {
        switch type {
        case .EthereumKeystoreV3:
            let keystore = try! EthereumKeystoreV3(password: password)!
            self.address = keystore.addresses!.first!.address
            self.data = try! JSONEncoder().encode(keystore.keystoreParams)
            self.isHD = false
            self.address = keystore.addresses!.first!.address
           
        case .BIP39(mnemonic: let mnemonic):
                       let keystore = try! BIP32Keystore(
                               mnemonics: mnemonic,
                               password: password,
                               mnemonicsPassword: "",
                               language: .english)!
                       self.name = "HD Wallet"
                       self.data = try! JSONEncoder().encode(keystore.keystoreParams)
                       self.isHD = true
                       self.address = keystore.addresses!.first!.address
        }


    }
}

struct HDKey {
    let name: String?
    let address: String
}

struct ERC20Token {
    var name: String
    var address: String
    var decimals: String
    var symbol: String
}
