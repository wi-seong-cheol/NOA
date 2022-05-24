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
    @IBOutlet weak var work: UIImageView!
    @IBOutlet weak var upload: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var contentsTextView: UITextView!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        work.image = UserInfo.shared.getIamge("workImage")
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
        viewModel.image
            .bind(to: work.rx.image)
            .disposed(by: disposeBag)
        
        upload.rx.tap
            .debug()
            .subscribe(onNext: { [weak self] in
                self?.uploadAlert()
            })
            .disposed(by: disposeBag)
        
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
        
        // Alert
        viewModel.alertMessage
            .skip(1)
            .map{ $0 as String }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog(message)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        viewModel.errorMessage
            .map { $0.domain }
            .subscribe(onNext: { [weak self] message in
                self?.OKDialog("Order Fail")
            }).disposed(by: disposeBag)
    }
    
    func uploadAlert() {
        let actions: [UIAlertController.AlertAction] = [
            .action(title: "NFT 발행"),
            .action(title: "작품 업로드"),
            .action(title: "취소", style: .cancel)
        ]

        UIAlertController
            .present(in: self, title: "Alert", message: "message", style: .actionSheet, actions: actions)
            .subscribe(onNext: { [weak self] buttonIndex in
                print(buttonIndex)
                if buttonIndex == 0 {
                    self?.showPasswordAlert()
                } else if buttonIndex == 1 {

                }
            })
            .disposed(by: disposeBag)
    }
    
    func showPasswordAlert(){
        let alert = UIAlertController(title: "Password", message: "", preferredStyle: .alert)
        alert.addTextField { textfied in
            textfied.isSecureTextEntry = true
            textfied.placeholder = "Password"
        }
        let createWallet = UIAlertAction(title: "NFT 발행하기", style: .default) { [weak self] _ in
            print("Clicked on Create NFT")
            self?.viewModel.createNFT() { message in
                self?.OKDialog(message)
            }
        }
        
        alert.textFields?[0].rx.text
            .orEmpty
            .skip(1)
            .distinctUntilChanged()
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(createWallet)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
