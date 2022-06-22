//
//  AuthService.swift
//  NOA
//
//  Created by wi_seong on 2022/05/26.
//

import Foundation
import RxSwift
import Alamofire
import web3swift

protocol AuthFetchable {
    func duplicate(_ nickname: String) -> Observable<CommonResponse>
    func refresh() -> Observable<[Duplicate]>
    func register(nickname: String, address: String) -> Observable<CommonResponse>
    func login(nickname: String, address: String) -> Observable<LoginResponse>
    func importWalletWith(privateKey: String) -> Observable<WalletResponse>
    func importWalletWith(mnemonics: String) -> Observable<WalletResponse>
    func createWallet(password: String) -> Observable<WalletResponse>
}

class AuthService: AuthFetchable {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    // MARK: Nickname 중복 확인
    func duplicate(_ nickname: String) -> Observable<CommonResponse> {
        
        let URL: String = apiUrlService.serviceUrl(.duplication)
        let query: [String: Any] = ["user_nickname": nickname]
        return apiRequestService.getable(URL: URL, query: query, interceptor: .none) ?? Observable.empty()
    }
    
    // MARK: 회원가입
    func register(nickname: String, address: String) -> Observable<CommonResponse> {
        
        let URL = apiUrlService.serviceUrl(.register)
        let body: [String: Any] = ["user_nickname": nickname, "user_wallet": address]
        print("---> body : \(body)")
        return apiRequestService.postable(URL: URL, body: body, interceptor: .none) ?? Observable.empty()
    }
    
    // MARK: 로그인
    func login(nickname: String, address: String) -> Observable<LoginResponse> {
        
        let URL = apiUrlService.serviceUrl(.login)
        let body: [String: Any] = ["user_nickname": nickname, "user_wallet": address]
        print(body)
        return apiRequestService.postable(URL: URL, body: body, interceptor: .none) ?? Observable.empty()
    }
    
    // MARK: Refresh Token 갱신
    func refresh() -> Observable<[Duplicate]> {
        let URL: String = apiUrlService.serviceUrl(.login)
        let refreshToken = Token.shared.load(account: "refreshToken")!
        let query: [String: Any] = ["refresh_token": refreshToken]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.getable(URL: URL, query: query, interceptor: interceptor) ?? Observable.empty()
    }
    
    // MARK: ImportWallet by PrivateKey
    func importWalletWith(privateKey: String) -> Observable<WalletResponse> {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            return .error(WalletError.validation("Please enter correct Private key"))
        }
        do {
            let name = "New Wallet"
            guard let keystore = try EthereumKeystoreV3(privateKey: dataKey, password: "web3swift") else {
                return .error(WalletError.notFound("Keystore get fail"))
            }
            let keyData = try JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
            UserInfo.shared.saveWallet(wallet)
            let result = WalletResponse(walletAddress: address, privateKey: privateKey)
            return .just(result)
        } catch {
#if DEBUG
            print("error creating keyStrore")
            print("Private key error.")
#endif
            return .error(WalletError.validation("Please enter correct Private key"))
        }
    }
    
    // MARK: ImportWallet by Mnemonics
    func importWalletWith(mnemonics: String) -> Observable<WalletResponse> {
        let walletAddress = try? BIP32Keystore(mnemonics: mnemonics , prefixPath: "m/44'/77777'/0'/0")
        print(walletAddress?.addresses as Any)
//        self?._walletAddress = "\(walletAddress?.addresses?.first?.address ?? "0x")"
        do {
            let password = "web3swift"
            let mnemonics = "fine have legal roof fury bread egg knee wrong idea must edit" // Some mnemonic phrase
            let keystore = try! BIP32Keystore(
                mnemonics: mnemonics,
                password: password,
                mnemonicsPassword: "",
                language: .english)!
            
            let address = keystore.addresses!.first!.address
            let keystoreManager: KeystoreManager
            keystoreManager = KeystoreManager([keystore])
            
            let ethereumAddress = EthereumAddress(address)!
            let privateKey = try keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
            let result = WalletResponse(walletAddress: address, privateKey: privateKey)
            return .just(result)
        } catch {
            return .error(WalletError.notFound("privateKey를 가져오지 못헀습니다."))
        }
        
    }
    
    // MARK: Create Wallet
    func createWallet(password: String) -> Observable<WalletResponse> {
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        do {
            if (web3KeystoreManager?.addresses?.count ?? 0 >= 0) {
                let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 256)
                guard let tMnemonics = tempMnemonics else {
                    return .error(WalletError.unable("We are unable to create wallet"))
                }
                let keystore = try! BIP32Keystore(
                    mnemonics: tMnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english,
                    prefixPath: "m/44'/77777'/0'/0")!
                print("--> \(keystore.addresses?.first?.address as Any)")
                guard let walletAddress = keystore.addresses?.first else {
                    return .error(WalletError.unable("We are unable to create wallet"))
                }
                let address = walletAddress.address
                let privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: walletAddress).toHexString()
                
#if DEBUG
                print(privateKey as Any, "Is the private key")
#endif
                let keyData = try? JSONEncoder().encode(keystore.keystoreParams)
                
                FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keyData, attributes: nil)
                let wallet = WalletResponse(walletAddress: address, privateKey: privateKey)
                return .just(wallet)
                
            } else {
                return .error(WalletError.notFound("web3KeystoreManager를 가져올 수 없습니다."))
            }
        } catch {
            return .error(WalletError.notFound("privateKey를 가져오지 못헀습니다."))
        }
    }
    
}
