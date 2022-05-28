//
//  UploadService.swift
//  NOA
//
//  Created by wi_seong on 2022/05/28.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire
import web3swift

protocol UploadFetchable {
    func upload(data: Data, post_nft: Int, post_title: String, post_text: String, post_tag: String) -> Observable<CommonResponse>
    func createNFT(url: String, title: String, desc: String) -> Observable<String>
}

class UploadService: UploadFetchable {
    
    @Inject private var apiUrlService: APIUrlService
    @Inject private var apiRequestService: APIRequestService
    
    func upload(data: Data, post_nft: Int, post_title: String, post_text: String, post_tag: String) -> Observable<CommonResponse> {
        let URL = apiUrlService.serviceUrl(.posting)
        let user = UserInfo.shared.getUser()
        let userNickname = user.nickname
        let body: [String: Any] = ["post_owner": userNickname,
                                   "post_nft": post_nft,
                                   "post_title": post_title,
                                   "post_text": post_text,
                                   "post_tag": post_tag]
        let interceptor: Interceptor = Interceptor(interceptors: [BaseInterceptor()])
        return apiRequestService.postUploadable(data: data, URL: URL, body: body, interceptor: interceptor) ?? Observable.empty()
    }
    
    func createNFT(url: String, title: String, desc: String) -> Observable<String> {
        var web3:web3?
        var contract:web3.web3contract?
        let abiVersion = 2
        
        let wallet = UserInfo.shared.getWallet()
        let myAddress = wallet.address
        let contractAddress = DBInfo.contractAddress
        
        let data = wallet.data
        let password = wallet.password
        let keystoreManager: KeystoreManager
        if wallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        //        let uploadImage = image.image
        do {
            web3 = try Web3.new(URL(string: DBInfo.nftUrl)!)
            
            web3!.addKeystoreManager(keystoreManager)
            let ethContractAddress = EthereumAddress(contractAddress, ignoreChecksum: true)!
            guard
                let jsonData = ReadJson.shared.loadABI(),
                let abi = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else {
                return .just("ABI를 가져오지 못했습니다.")
            }
            
            let contractABI = abi
            contract = web3!.contract(contractABI, at: ethContractAddress, abiVersion: abiVersion)!
            
            let value: String = "0.000000000000000001"
            let walletAddress = EthereumAddress(myAddress)!
            let contractMethod = "uploadPhoto" // Contract method you want to write
            let url = URL(string: url)
            let image = try Data(contentsOf: url!)
            let photo = image.bytes
            print(image.count)
            let title = title
            let description = desc
            let parameters: [AnyObject] = [photo, title, description] as [AnyObject] // Parameters for contract method
            let extraData: Data = Data() // Extra data for contract method
            
            let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
            
            var options = TransactionOptions.defaultOptions
            options.value = amount
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .manual(8500000)
            
            guard let tokenTransactionIntermediate =
                    contract?.method(contractMethod,
                                     parameters: parameters,
                                     extraData: extraData,
                                     transactionOptions: options) else {
                return .just("contract nil")
            }
            
            let mainTransaction = try tokenTransactionIntermediate.send(password: password, transactionOptions: options)
            return .just("\(mainTransaction.hash) is the hash of your transaction")
        } catch DecodingError.dataCorrupted(let context) {
            print("Decoding Error Message:")
            print(context.codingPath)
            print(context.debugDescription)
            print(context.underlyingError ?? "")
            
            return .just("Decoding Error")
        } catch  {
            return .just("Error Message: \(error)")
        }
    }
}
