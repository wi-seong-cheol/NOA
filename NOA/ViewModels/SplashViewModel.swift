//
//  SplashViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation

class SplashViewModel: NSObject {
    
    var loadingStarted: () -> Void = { }
    var loadingEnded: () -> Void = { }
    
    func initialization() {
        loadingStarted()
        // API Call
        loadingEnded()
    }
    
    func versionCheck() {
        
    }
    
    func concurrentWorkItems() {
        
    }
    
    func comparePushToken() {
        
    }
}
