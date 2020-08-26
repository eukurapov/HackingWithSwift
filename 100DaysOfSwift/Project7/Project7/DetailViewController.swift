//
//  DetailViewController.swift
//  Project7
//
//  Created by Evgeniy Kurapov on 24.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var detailItem: Petition?
    var webView: WKWebView?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailItem = detailItem else { return }
        
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 150%; } </style>
        </head>
        <body>
        \(detailItem.body)
        </body>
        </html>
        """
        
        webView?.loadHTMLString(html, baseURL: nil)
    }

}
