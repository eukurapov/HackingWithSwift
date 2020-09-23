//
//  DetailViewController.swift
//  Project1
//
//  Created by Evgeniy Kurapov on 06.10.2019.
//  Copyright © 2019 Evgeniy Kurapov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var imageTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = imageTitle
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        guard let image = watermarkedImage?.jpegData(compressionQuality: 0.8) else { return }
        
        let vc = UIActivityViewController(activityItems: [image, imageTitle!], applicationActivities: [])
        // to show it attached to bar button on iPad
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    private var watermarkedImage: UIImage? {
        guard let image = imageView.image else { return nil }
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let img = renderer.image { context in
            image.draw(in: rect)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            let text = "From Storm Viewer"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.black,
                .strokeColor: UIColor.white,
                .strokeWidth: -3
            ]
            let attrString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attrString.size()
            attrString.draw(
                with: CGRect(origin: CGPoint(x: rect.maxX - textSize.width, y: rect.maxY - textSize.height), size: textSize),
                options: .usesLineFragmentOrigin, context: nil)
        }
        return img
    }

}
