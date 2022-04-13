//
//  Inject.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

@propertyWrapper
class Inject<T> {
    
    let wrappedValue: T
    
    init() {
        self.wrappedValue = DIContainer.shared.resolve()
    }
}
