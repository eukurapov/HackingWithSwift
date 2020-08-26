//
//  DetailViewController.swift
//  FlagList
//
//  Created by Evgeniy Kurapov on 13.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var imageName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = imageName
        navigationItem.largeTitleDisplayMode = .never
        
        if let imageToLoad = imageName {
            imageView.image = UIImage(named: imageToLoad)?.imageWithBorder(width: 1, color: UIColor.lightGray)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        if let imageName = imageName, let image = imageView.image { // UIImage(named: imageName) {
            let vc = UIActivityViewController(activityItems: [imageName, image], applicationActivities: nil)
            present(vc, animated: true)
        }
    }
    
}
