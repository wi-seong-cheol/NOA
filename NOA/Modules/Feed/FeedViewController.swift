//
//  FeedViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/20.
//

import Foundation
import RxSwift
import RxViewController
import NVActivityIndicatorView
import UIKit

class FeedViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var exhibition: UIButton!
    
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
    
    let viewModel: FeedViewModelType
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupBindings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        
        if identifier == "FeedDetailSegue",
           let selectedFeed = sender as? Lecture,
           let feedVC = segue.destination as? FeedDetailViewController {
            let feedViewModel = FeedDetailViewModel(selectedFeed)
            feedVC.viewModel = feedViewModel
        }
    }
}

extension FeedViewController {
    // MARK: - UI Setting
    func configure() {
        collectionView.refreshControl = UIRefreshControl()
        search.titleLabel?.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
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
            .bind(to: self.viewModel.fetchList)
            .disposed(by: disposeBag)
        
        // 무한 스크롤
        self.collectionView.rx_reachedBottom
            .map { _ in () }
            .bind(to: self.viewModel.moreFetchList)
            .disposed(by: disposeBag)

        // ------------------------------
        //     Page Move
        // ------------------------------

        // 페이지 이동
        Observable.zip(collectionView.rx.modelSelected(Lecture.self), collectionView.rx.itemSelected) .bind { [weak self] item, indexPath in
            self?.performSegue(withIdentifier: "FeedDetailSegue", sender: item)
            
        } .disposed(by: disposeBag)
        
        search.rx.tap
            .bind { [weak self] in
                self?.performSegue(withIdentifier: "searchSegue", sender: nil)
            }
            .disposed(by: disposeBag)
        
        exhibition.rx.tap
            .bind{ [weak self] in
                self?.performSegue(withIdentifier: "exhibitionSegue", sender: nil)
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
        
        // 액티비티 인디케이터
        viewModel.activated
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
        viewModel
            .items
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCollectionCell.identifier, cellType: FeedCollectionCell.self)) {
                indexPath, item, cell in
                cell.onData.onNext(item)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width/2 - 1
        let height = width
        return CGSize(width: width, height: height)
    }
}
