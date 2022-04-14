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
    
    let viewModel: SplashViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: SplashViewModelType = SplashViewModel()) {
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
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------

        // 처음 로딩할 때 하고, 당겨서 새로고침 할 때
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        firstLoad
            .bind(to: viewModel.fetchList)
            .disposed(by: disposeBag)

        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        viewModel.activated
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                self?.performSegue(withIdentifier: "MainSegue",
                                   sender: nil)
            })
            .disposed(by: disposeBag)

        // ------------------------------
        //     OUTPUT
        // ------------------------------

        // 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            })
            .disposed(by: disposeBag)
        
        viewModel.lectureList
            .bind() { result in
                print(result)
            }
            .disposed(by: disposeBag)
    }
}
