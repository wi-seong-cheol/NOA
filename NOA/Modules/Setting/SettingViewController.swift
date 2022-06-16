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
    
    let viewModel: SettingViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: SettingViewModel = SettingViewModel()) {
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
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
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
                    print("click")
                    UserInfo.shared.saveIsLogin(false)
                    let keyWindow = UIApplication.shared.connectedScenes
                            .filter({$0.activationState == .foregroundActive})
                            .map({$0 as? UIWindowScene})
                            .compactMap({$0})
                            .first?.windows
                            .filter({$0.isKeyWindow}).first
                    let storyboard = UIStoryboard(name:"Main", bundle: nil)
                    if let viewController = storyboard.instantiateViewController(identifier: "SplashViewController") as? SplashViewController {
                        keyWindow?.replaceRootViewController(viewController, animated: true, completion: nil)
                    }
                    break
                case 2:
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
            

        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        viewModel.output.present
            .skip(1)
            .filter{ $0 }
            .subscribe(onNext: {[weak self] _ in
                let storyboard = UIStoryboard(name:"Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SplashViewController")
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------

        // 에러 처리
        viewModel.output.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
}
