//
//  SettingViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/05/01.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit
import PagingKit

class SettingViewController: UITableViewController {
    
    let viewModel: SettingViewModelType
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: SettingViewModelType = SettingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = SettingViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupBindings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let identifier = segue.identifier ?? ""
//
//        if identifier == "HomeDetailSegue",
//           let selectedFeed = sender as? Lecture,
//           let feedVC = segue.destination as? HomeDetailViewController {
//            let feedViewModel = HomeDetailViewModel(selectedFeed)
//            feedVC.viewModel = feedViewModel
//        }
    }
}

extension SettingViewController {
    // MARK: - UI Setting
    func configure() {
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                switch(indexPath.row) {
                case 0:
                    self?.performSegue(withIdentifier: "InfoSegue", sender: nil)
                    break
                case 1:
                    break
                case 2:
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        // 처음 로딩할 때 하고, 당겨서 새로고침 할 때
        
        // 무한 스크롤

        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동

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
