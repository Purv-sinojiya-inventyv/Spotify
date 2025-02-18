//
//  AuthStoryBoardViewController.swift
//  Spotify
//
//  Created by Kailash Rajput on 17/02/25.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        guard let url = AuthManager.shared.signInUrl else{return}
        webView.load(URLRequest(url:url))
    }
    
    public var completionHandler: ((Bool) -> Void)?
    
    private func setUpWebKit() {
        let preff = WKWebpagePreferences()
        preff.allowsContentJavaScript = true
        preff.preferredContentMode = .mobile
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preff
        
//        webView.
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        
        let component = URLComponents(string: url.absoluteString)
        guard let code = component?.queryItems?.first(where: { $0.name == "code"})?.value else{
            return
        }
        
        print(code)
        webView.isHidden = true
        AuthManager.shared.exchangeToken(code: code) {[weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
}
