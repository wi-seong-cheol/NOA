//
//  DIContainer.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation

class DIContainer {
    
    static let shared = DIContainer()
    
    private var dependencies = [String: Any]()
    
    private init() {}

    func register<T>(_ dependency: T) {
        let key = String(describing: type(of: T.self))
        dependencies[key] = dependency
    }
    
    func resolve<T>() -> T { //Generic Parameter T
        let key = String(describing: type(of: T.self))
        let dependency = dependencies[key]
        
        precondition(dependency != nil, "\(key)는 register되지 않음. register 해주세요.")
        
        return dependency as! T
    }
}
