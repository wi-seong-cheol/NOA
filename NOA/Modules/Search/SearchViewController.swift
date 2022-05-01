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
        //        if identifier == "HomeDetailSegue",
        //           let selectedFeed = sender as? Lecture,
        //           let feedVC = segue.destination as? HomeDetailViewController {
        //            let feedViewModel = HomeDetailViewModel(selectedFeed)
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
//        viewModel.items
//            .bind(tableView.rx.items(cellIdentifier: SearchTableCell.identifier, cellType: SearchTableCell.self)) { _, item, cell in
//                cell.onData.onNext(item)
//            }
//            .disposed(by: disposeBag)
        
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
//extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: searchTableCell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as? searchTableViewCell else {
//            fatalError()
//        }
//        cell.blueText.text = self.items[indexPath.row] return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell: searchTableViewCell = tableView.cellForRow(at: indexPath) as? searchTableViewCell else {
//            return
//        }
//        self.selectLabel.text = cell.blueText.text
//    }
//}
