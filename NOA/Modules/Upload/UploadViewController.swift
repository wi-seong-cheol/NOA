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
import NVActivityIndicatorView

class UploadViewController: UIViewController {
    @IBOutlet weak var back: UIBarButtonItem!
    @IBOutlet weak var work: UIImageView!
    @IBOutlet weak var upload: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var contentsTextView: UITextView!
    
    lazy var indicator: NVActivityIndicatorView = {
        let indicator = NVActivityIndicatorView(
            frame: CGRect(
                x: self.view.frame.width/2 - 25,
                y: self.view.frame.height/2 - 25,
                width: 50,
                height: 50),
            type: .circleStrokeSpin,
            color: .black,
            padding: 0)
        
        indicator.center = self.view.center
                
        // 기타 옵션
        indicator.color = UIColor(red: 237, green: 106, blue: 201)
        
        indicator.stopAnimating()
        return indicator
    }()
    
    let viewModel: UploadViewModel
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    init(viewModel: UploadViewModel = UploadViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = UploadViewModel()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        work.image = UserInfo.shared.getIamge("workImage")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension UploadViewController {
    func configure() {
        self.view.addSubview(indicator)
        self.hideKeyboard()
        titleTextView.delegate = self
        contentsTextView.delegate = self
        textViewSetupView(titleTextView)
        textViewSetupView(contentsTextView)
        titleLabel.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        titleTextView.font = UIFont.NotoSansCJKkr(type: .regular, size: 12)
        contentsLabel.font = UIFont.NotoSansCJKkr(type: .medium, size: 14)
        contentsTextView.font = UIFont.NotoSansCJKkr(type: .regular, size: 12)
    }
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // --------------------------
        
        
        upload.rx.tap
            .debug()
            .subscribe(onNext: { [weak self] in
                self?.uploadAlert()
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.text
            .orEmpty
            .bind(to: viewModel.input.subject)
            .disposed(by: disposeBag)
        
        contentsTextView.rx.text
            .orEmpty
            .bind(to: viewModel.input.desc)
            .disposed(by: disposeBag)
        
        let image = UserDefaults.standard.object(forKey: "workImage") as! Data
        
        Observable.just(image)
            .bind(to: viewModel.input.image)
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
        viewModel.output.move
            .subscribe(onNext: {
                if $0 {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.activated
            .skip(1)
            .map { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] finished in
                if finished {
                    self?.indicator.startAnimating()
                } else {
                    self?.indicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        // Alert
        viewModel.output.alertMessage
            .skip(1)
            .map{ $0 as String }
            .subscribe(onNext: { [weak self] message in
                
                self?.OKDialog(message)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        viewModel.output.errorMessage
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
                    Observable<Void>.just(Void())
                        .subscribe(onNext: { _ in
                            self?.viewModel.input.uploadNFT.onNext(Void())
                        })
                        .disposed(by: (self?.disposeBag)!)
                } else if buttonIndex == 1 {
                    Observable<Void>.just(Void())
                        .subscribe(onNext: { _ in
                            self?.viewModel.input.upload.onNext(Void())
                        })
                        .disposed(by: (self?.disposeBag)!)
                }
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - textView 관련 메서드
extension UploadViewController {
    func textViewSetupView(_ textView: UITextView) {
        switch textView.restorationIdentifier {
        case "title":
            textCheck(textView, "작품 제목을 입력해주세요.")
        case "contents":
            textCheck(textView, "작품 설명을 입력해주세요.")
        default:
            return
        }
    }
    
    func textCheck(_ textView: UITextView, _ text: String) {
        if textView.text == text {
            textView.text = ""
            textView.textColor = UIColor.black
        } else if textView.text == "" {
            textView.text = text
            textView.textColor = UIColor.lightGray
        }
    }
}

//MARK: - UITextViewDelegate 관련 메서드
extension UploadViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetupView(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textViewSetupView(textView)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.restorationIdentifier != "contents" {
            if text == "\n" {
                textView.resignFirstResponder()
            } else if range.length == 1 {
                return true
            } else if range.location > 100 {
                return false
            } else if textView.numberOfLines() > 4 {
                return false
            } else {
                return true
            }
        } else {
            if range.length == 1 {
                return true
            } else if range.location > 100 {
                return false
            } else if textView.numberOfLines() > 8 {
                return false
            } else {
                return true
            }
        }
        return true
    }
}
