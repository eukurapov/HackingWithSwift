//
//  WebViewController.swift
//  Project16
//
//  Created by Eugene Kurapov on 10.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var url: URL?
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
}
