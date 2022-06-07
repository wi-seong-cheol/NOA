//
//  TabBarViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import UIKit
import CropViewController

class TabBarViewController: UITabBarController {
    var imagePicker = UIImagePickerController()
    var index = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
}

extension TabBarViewController: UITabBarControllerDelegate {

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        item.title == "업로드" ? (index = false) : (index = true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if index == false {
            openGallary()
        }
        return index
    }
}

extension TabBarViewController: UINavigationControllerDelegate, CropViewControllerDelegate {

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
        let storyboard = UIStoryboard(name: "Upload", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Upload")// as! UploadViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        UserInfo.shared.setImage("workImage", image, 0.1)
        
        self.dismiss(animated: true, completion: nil)
        self.present(vc, animated: true, completion: nil)
    }
}

extension TabBarViewController: UIImagePickerControllerDelegate {
    func openGallary() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
}
