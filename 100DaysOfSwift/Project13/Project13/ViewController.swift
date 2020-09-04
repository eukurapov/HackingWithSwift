//
//  ViewController.swift
//  Project13
//
//  Created by Eugene Kurapov on 04.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var context: CIContext!
    private var filter: CIFilter!
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var intensitySlider: UISlider!
    
    private var currentImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importImage))
        
        context = CIContext()
        filter = CIFilter(name: "CISepiaTone")
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard currentImage != nil else { return }
        guard let image = processedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc
    private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let ac: UIAlertController
        if error != nil {
            ac = UIAlertController(title: "Save Error", message: error?.localizedDescription, preferredStyle: .alert)
        } else {
            ac = UIAlertController(title: "Saved Successfuly", message: nil, preferredStyle: .alert)
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Change Filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIBloom", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIHueAdjust", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func setFilter(alertAction: UIAlertAction) {
        guard let filterName = alertAction.title else { return }
        filter = CIFilter(name: filterName)
        
        guard currentImage != nil else { return }
        let ciImage = CIImage(image: currentImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        applyFilter()
    }

    @IBAction func intensityValueChanged(_ sender: UISlider) {
        applyFilter()
    }
    
    @objc
    private func importImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            dismiss(animated: true)
            currentImage = image
            let ciImage = CIImage(image: currentImage)
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            applyFilter()
        }
    }
    
    private func applyFilter() {
        let keys = filter.inputKeys
        
        if keys.contains(kCIInputIntensityKey) {
            filter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
        }
        
        if keys.contains(kCIInputRadiusKey) {
            filter.setValue(intensitySlider.value * 100, forKey: kCIInputRadiusKey)
        }
        
        if keys.contains(kCIInputAngleKey) {
            filter.setValue(intensitySlider.value * .pi, forKey: kCIInputAngleKey)
        }
        
        if keys.contains(kCIInputCenterKey) {
            filter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        imageView.image = processedImage
    }
    
    private var processedImage: UIImage? {
        if let cgimg = context.createCGImage(filter.outputImage!, from: CIImage(image: currentImage)!.extent) {
            return UIImage(cgImage: cgimg)
        } else {
            return nil
        }
    }

}

