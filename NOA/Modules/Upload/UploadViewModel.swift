//
//  UploadViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift
import web3swift
import SwiftyJSON

protocol UploadViewModelType {
    // MARK: INPUT
//    var upload: AnyObserver<Void> { get }
//    var uploadNFT: AnyObserver<Void> { get }
    var image: BehaviorRelay<UIImage> { get }
    var desc: BehaviorRelay<String> { get }
    var subject: BehaviorRelay<String> { get }
    var password: BehaviorRelay<String> { get }
    
    // MARK: OUTPUT
    var alertMessage: Observable<String> { get }
    var errorMessage: Observable<NSError> { get }
    
    func create() -> String
    func createNFT(_ completion: @escaping (String) -> Void)
}

class UploadViewModel: UploadViewModelType {
    
    let disposeBag = DisposeBag()
    
    let realm = try! Realm()
    // MARK: INPUT
    let image = BehaviorRelay(value: UIImage())
    let desc = BehaviorRelay(value: "")
    let subject = BehaviorRelay(value: "")
    let password = BehaviorRelay(value: "")
    
    // MARK: OUTPUT
    let alertMessage: Observable<String>
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        let alert = BehaviorSubject<String>(value: "")
        let error = PublishSubject<Error>()
        
        
        // MARK: OUTPUT
        
        alertMessage = alert.map { $0 as String }
        
        errorMessage = error.map { $0 as NSError }
        
        // MARK: INPUT
    }
    
    func load() -> Data? {
        // 1. 불러올 파일 이름
        let fileNm: String = "ABI"
        // 2. 불러올 파일의 확장자명
        let extensionType = "json"
        
        // 3. 파일 위치
        guard let fileLocation = Bundle.main.url(forResource: fileNm, withExtension: extensionType) else { return nil }
        
        
        do {
            // 4. 해당 위치의 파일을 Data로 초기화하기
            let data = try Data(contentsOf: fileLocation)
            return data
        } catch {
            // 5. 잘못된 위치나 불가능한 파일 처리 (오늘은 따로 안하기)
            return nil
        }
    }
    
    func create() -> String {
        return ""
    }
    
    func createNFT(_ completion: @escaping (String) -> Void) {
        var web3:web3?
        var contract:web3.web3contract?
        let abiVersion = 2

        let wallet = UserInfo.shared.getWallet()
        let myAddress = wallet.address
        let contractAddress = DBInfo.contractAddress
        
        let data = wallet.data
        let keystoreManager: KeystoreManager
        if wallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
//        let uploadImage = image.image
        DispatchQueue.global(qos: .background).async { [weak self] in
            do {
                web3 = try Web3.new(URL(string: DBInfo.nftUrl)!)
                web3!.addKeystoreManager(keystoreManager)
                let ethContractAddress = EthereumAddress(contractAddress, ignoreChecksum: true)!
                guard
                    let jsonData = self?.load(),
                    let abi = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else {
                    completion("ABI를 가져오지 못했습니다.")
                    return
                }
                
                let contractABI = abi
                contract = web3!.contract(contractABI, at: ethContractAddress, abiVersion: abiVersion)!
                
                let value: String = "0.000000000000000001"
                let walletAddress = EthereumAddress(myAddress)!
                let contractMethod = "uploadPhoto" // Contract method you want to write
                let url = URL(string: "https://smtmap.com/wp-content/uploads/2019/05/20190509_220956.jpg")
                let image = try Data(contentsOf: url!)
//                44670
//                311317
//                let image = NSDataAsset(name: "Icon")?.data
                    //.jpegData(compressionQuality: 0.01))!)//UIImage(named: "Icon")!.jpegData(compressionQuality: 0.01)//pngData()
//                let image = uploadImage?.pngData()
                let photo = image.bytes
                print(image.count)
                let title = "qweq"
                let description = "asdfafd"
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
                    completion("contract nil")
                    return
                }
                
                let mainTransaction = try tokenTransactionIntermediate.send(password: (self?.password.value)!, transactionOptions: options)
                completion("\(mainTransaction.hash) is the hash of your transaction")
            } catch DecodingError.dataCorrupted(let context) {
                print("Decoding Error Message:")
                print(context.codingPath)
                print(context.debugDescription)
                print(context.underlyingError ?? "")
                
                completion("Decoding Error")
            } catch  {
                completion("Error Message: \(error)")
            }
        }
    }
}

