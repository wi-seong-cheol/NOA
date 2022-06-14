//
//  ProfileEditViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/05/10.
//

import RxCocoa
import RxSwift
import RxViewController
import NVActivityIndicatorView
import CropViewController
import UIKit

class ProfileEditViewController: UIViewController {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var statusMessage: UITextView!
    @IBOutlet weak var edit: UIBarButtonItem!
    
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
    
    var imagePicker = UIImagePickerController()
    let viewModel: ProfileEditViewModel
    var disposeBag = DisposeBag()

    // MARK: - Life Cycle

    init(viewModel: ProfileEditViewModel = ProfileEditViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = ProfileEditViewModel()
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

extension ProfileEditViewController {
    // MARK: - UI Setting
    func configure() {
        profile.layer.cornerRadius = profile.frame.width / 2
        self.profile.isUserInteractionEnabled = true
        self.profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectedProfile(_:))))
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        // ------------------------------
        //     INPUT
        // ------------------------------
        
        nickname.rx.text
            .orEmpty
            .bind(to: viewModel.input.nicknameInput)
            .disposed(by: disposeBag)
        
        statusMessage.rx.text
            .orEmpty
            .bind(to: viewModel.input.statusMessageInput)
            .disposed(by: disposeBag)
        
        edit.rx.tap
            .debug()
            .bind(to: viewModel.input.edit)
            .disposed(by: disposeBag)
        
        
        // ------------------------------
        //     Page Move
        // ------------------------------

        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
        viewModel.output.profile
            .drive(profile.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.output.nickname
            .drive(nickname.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.statusMessage
            .drive(statusMessage.rx.text)
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
    
    @objc func didSelectedProfile(_ sender: UIButton) {
        openGallary()
    }
}

extension ProfileEditViewController: UINavigationControllerDelegate, CropViewControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Error: \(info)")
            return
        }
        dismiss(animated: true, completion: nil)
        self.presentCropViewController(image: selectedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }

    func presentCropViewController(image:UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.rotateButtonsHidden = true
        cropViewController.resetButtonHidden = true
        self.present(cropViewController, animated: true, completion: nil)
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        Observable<UIImage>.just(image)
            .subscribe(onNext: { _ in
                print("dfdsf")
                self.viewModel.input.profileInput.onNext(image)
            })
            .disposed(by: disposeBag)
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileEditViewController: UIImagePickerControllerDelegate {
    func openGallary() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
}
