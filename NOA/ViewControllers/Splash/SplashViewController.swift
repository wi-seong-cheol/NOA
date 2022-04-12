//
//  SplashViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/08.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet var viewModel: SplashViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // activity 추후에 다른 것으로 변경
        let activity = UIActivityIndicatorView()
        view.addSubview(activity)
        activity.tintColor = .red
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        viewModel.loadingStarted = { [weak activity] in
            activity?.isHidden = false
            activity?.startAnimating()
        }
        
        viewModel.loadingEnded = { [weak activity] in
            activity?.stopAnimating()
            
            // 나중에 시간초 제거
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.performSegue(withIdentifier: "MainSegue", sender: nil)
            }
        }
        
        viewModel.initialization()
    }
}
