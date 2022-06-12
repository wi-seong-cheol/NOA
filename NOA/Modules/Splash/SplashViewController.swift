//
//  SplashViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/08.
//

import RxCocoa
import RxSwift
import RxViewController
import UIKit

class SplashViewController: UIViewController {
    
    let viewModel: SplashViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: SplashViewModel = SplashViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = SplashViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SplashViewController {
    
    // MARK: - UI Binding
    func setupBindings() {

        // ------------------------------
        //     Page Move
        // ------------------------------
        
        // 페이지 이동
        viewModel.output.isLogin
            .map { $0 as Bool }
            .delay(.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                if status {
                    Observable<Void>.just(Void())
                        .subscribe(onNext: { _ in
                            self?.viewModel.input.getUser.onNext(Void())
            
                        })
                        .disposed(by: (self?.disposeBag)!)
                } else {
                    self?.performSegue(withIdentifier: "LoginSegue",
                                       sender: nil)
                }
            })
            .disposed(by: disposeBag)
        

        // ------------------------------
        //     OUTPUT
        // ------------------------------
        viewModel.output.move
            .subscribe(onNext: {
                if $0 {
                    self.performSegue(withIdentifier: "MainSegue",
                                                   sender: nil)
                }
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        viewModel.output.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            })
            .disposed(by: disposeBag)
    }
}
