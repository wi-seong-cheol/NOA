//
//  SearchViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/29.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit
import PagingKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var items = [String]()
    let samples = ["서울", "부산", "온수", "건대", "온수", "부천", "송파", "가", "가나", "가나다", "가나다라", "가카타파하", "에이", "a", "ab", "abc", "apple", "mac", "azxy"]
    
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
    
    let viewModel: SearchViewModelType
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    init(viewModel: SearchViewModelType = SearchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = SearchViewModel()
        super.init(coder: aDecoder)
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
//        if identifier == "SearchSegue",
//           let selectedFeed = sender as? Lecture,
//           let feedVC = segue.destination as? SearchWorkViewController {
//            let feedViewModel = SearchWorkViewModel(selectedFeed)
//            feedVC.viewModel = feedViewModel
//        }
    }
}

extension SearchViewController {
    // MARK: - UI Setting
    func configure() {
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        
        viewModel.items
            .drive(tableView.rx.items(cellIdentifier: SearchTableCell.identifier, cellType: SearchTableCell.self)) {
                _, item, cell in
                cell.onData.onNext(item)
            }
            .disposed(by: disposeBag)
        
        cancel.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     Page Move
        // ------------------------------
        
        // 페이지 이동
        Observable.zip(tableView.rx.modelSelected(Search.self), tableView.rx.itemSelected) .bind { [weak self] item, indexPath in
            self?.performSegue(withIdentifier: "SearchSegue", sender: item)
            
        } .disposed(by: disposeBag)
        
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
