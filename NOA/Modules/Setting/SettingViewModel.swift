//
//  SettingViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/05/01.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift

protocol SettingViewModelType {
    // MARK: INPUT
    
    // MARK: OUTPUT
    var errorMessage: Observable<NSError> { get }
}

class SettingViewModel: SettingViewModelType {
    
    let disposeBag = DisposeBag()
    
    let realm = try! Realm()
    // MARK: INPUT
    
    // MARK: OUTPUT
    let errorMessage: Observable<NSError>
    
    init(service: FeedFetchable = FeedService()) {
        let error = PublishSubject<Error>()
        
        // MARK: INPUT
        
        // MARK: OUTPUT
        errorMessage = error.map { $0 as NSError }
    }
}

