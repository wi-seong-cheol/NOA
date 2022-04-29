//
//  UploadViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxViewController

class UploadViewController: UIViewController {
    @IBOutlet weak var back: UIButton!
    
    let viewModel: UploadViewModelType
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    init(viewModel: UploadViewModelType = UploadViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = UploadViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let identifier = segue.identifier ?? ""
//
//        if identifier == "FeedDetailSegue",
//           let selectedFeed = sender as? Lecture,
//           let feedVC = segue.destination as? FeedDetailViewController {
//            let feedViewModel = FeedDetailViewModel(selectedFeed)
//            feedVC.viewModel = feedViewModel
//        }
    }
}

extension UploadViewController {
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        
        // ------------------------------
        //     Page Move
        // ------------------------------
        
        // 페이지 이동
        back.rx.tap
            .bind{ [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
        // 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
}
