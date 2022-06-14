//
//  SearchWrokViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/05/03.
//

import Foundation
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit

class SearchWorkViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var keyword: UILabel!
    
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
    
    var viewModel: SearchWorkViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: SearchWorkViewModel = SearchWorkViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = SearchWorkViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
        let identifier = segue.identifier ?? ""
        
        if identifier == "FeedDetailSegue",
           let selectedFeed = sender as? Feed,
           let feedVC = segue.destination as? FeedDetailViewController {
            let feedViewModel = FeedDetailViewModel(selectedFeed)
            feedVC.viewModel = feedViewModel
        }
    }
}

extension SearchWorkViewController {
    // MARK: - UI Setting
    func configure() {
        collectionView.refreshControl = UIRefreshControl()
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
        let reload = collectionView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        Observable.merge([firstLoad, reload])
            .bind(to: self.viewModel.input.fetchList)
            .disposed(by: disposeBag)
        
        // 무한 스크롤
        self.collectionView.rx_reachedBottom
            .map { _ in () }
            .bind(to: self.viewModel.input.moreFetchList)
            .disposed(by: disposeBag)

        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        Observable.zip(collectionView.rx.modelSelected(Feed.self), collectionView.rx.itemSelected) .bind { [weak self] item, indexPath in
            let storyboard = UIStoryboard(name:"Feed", bundle: nil)
            let pushVC = storyboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as! FeedDetailViewController
            pushVC.viewModel = FeedDetailViewModel(item)
            self?.navigationController?.pushViewController(pushVC, animated: true)
        } .disposed(by: disposeBag)
        
        back.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        

        // ------------------------------
        //     OUTPUT
        // ------------------------------
        viewModel.output.keyword
            .drive(keyword.rx.text)
            .disposed(by: disposeBag)
        
        // 에러 처리
        viewModel.output.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
        
        // 액티비티 인디케이터
        viewModel.output.activated
            .map { !$0 }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] finished in
                if finished {
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            })
            .bind(to: indicator.rx.isHidden)
            .disposed(by: disposeBag)
                
        // 테이블뷰 아이템들
        viewModel.output.items
            .drive(collectionView.rx.items(cellIdentifier: FeedCollectionCell.identifier, cellType: FeedCollectionCell.self)) {
                indexPath, item, cell in
                cell.onData.onNext(item)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension SearchWorkViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width/2 - 1
        let height = width
        return CGSize(width: width, height: height)
    }
}
