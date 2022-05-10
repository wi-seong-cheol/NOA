//
//  InformationViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/05/10.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit
import PagingKit

class InformationViewController: UITableViewController {
    
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle
    
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
        if let url = sender as? String,
           let webVC = segue.destination as? WebViewController {
            webVC.urlString = url
        }
    }
}

extension InformationViewController {
    // MARK: - UI Setting
    func configure() {
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                switch(indexPath.row) {
                case 0:
                    self?.performSegue(withIdentifier: "WebSegue", sender: DBInfo.dataPolicy)
                    break
                case 1:
                    self?.performSegue(withIdentifier: "WebSegue", sender: DBInfo.dataPolicy)
                    break
                case 2:
                    self?.performSegue(withIdentifier: "WebSegue", sender: DBInfo.dataPolicy)
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
