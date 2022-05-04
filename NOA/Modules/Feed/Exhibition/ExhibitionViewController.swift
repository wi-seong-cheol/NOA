//
//  ExhibitionViewController.swift
//  NOA
//
//  Created by wi_seong on 2022/04/28.
//

import Foundation
import UIKit
import WebKit

class ExhibitionViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @Inject var globalAlert: GlobalAlert
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let service = APIRequestService()
        guard service.isInternetAvailable() else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            if let vc = window?.rootViewController {
                globalAlert.commonAlert(title: "네트워크 연결 확인\n", content: "네트워크 연결이 되어있지 않습니다.\n연결상태를 확인해주세요.", vc: vc)
            }
            return
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webViewInit()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ExhibitionViewController {
    func configure() {
        
    }
    
    func webViewInit(){
        
        WKWebsiteDataStore.default().removeData(ofTypes:
                                                    [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0)) {
        }
        
        webView.allowsBackForwardNavigationGestures = true
        
        if let url = URL(string: "https://m.officecheckin.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
    }
}

extension ExhibitionViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default) { (action) in
            completionHandler(false)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
//, WKUIDelegate, WKNavigationDelegate
