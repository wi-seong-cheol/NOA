//
//  ProfileViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift

protocol ProfileViewModelType {
    // MARK: INPUT
    
    // MARK: OUTPUT
    var errorMessage: Observable<NSError> { get }
}

class ProfileViewModel: ProfileViewModelType {
    
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