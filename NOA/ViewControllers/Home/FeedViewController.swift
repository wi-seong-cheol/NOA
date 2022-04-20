//
//  FeedViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/19.
//

import RxCocoa
import RxSwift
import RxDataSources
import RxViewController
import NVActivityIndicatorView
import UIKit

class FeedViewController: UIViewController {
    
    static let identifier = "FeedViewController"
    @IBOutlet weak var work: UIImageView!
    
    lazy var indicator: NVActivityIndicatorView = {
        let indicator = NVActivityIndicatorView(
            frame: CGRect(
                x: self.view.frame.width/2 - 25,
                y: self.view.frame.height/2 - 25,
                width: 50,
                height: 50),
            type: .ballScaleMultiple,
            color: .black,
            padding: 0)
        
        indicator.center = self.view.center
                
        // 기타 옵션
        indicator.color = .purple
        
        indicator.stopAnimating()
        return indicator
    }()
    
    var viewModel: FeedViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: FeedViewModelType = FeedViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = FeedViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
}

extension FeedViewController {
    // MARK: - UI Binding
    func setupBindings() {
        viewModel.work
            .bind(to: work.rx.image)
            .disposed(by: disposeBag)
        
    }
}
