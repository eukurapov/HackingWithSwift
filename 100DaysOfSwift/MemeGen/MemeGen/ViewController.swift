//
//  ViewController.swift
//  MemeGen
//
//  Created by Eugene Kurapov on 24.09.2020.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController,
                      UITextViewDelegate,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topText: UITextView!
    @IBOutlet weak var bottomText: UITextView!
    @IBOutlet weak var imageViewCenterY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topText.delegate = self
        bottomText.delegate = self
        
        topText.layer.cornerRadius = 5
        bottomText.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(recogniser:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextViewLayout), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextViewLayout), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPicture))
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addPhoto)))
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
    
    @objc
    private func addPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc
    private func addPhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        imageView.image = image
    }
    
    @objc
    private func share() {
        guard let image = imageView.image else { return }
        
        let sideLength = max(image.size.height, image.size.width)
        let rect = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        let memeImage = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(rect)
            image.draw(in: rect)
            let imageScale = sideLength / imageView.frame.height
            let textRectHeight = topText.frame.height * imageScale
            let fontSize = 24*imageScale
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: topText.font!.withSize(fontSize),
                .foregroundColor: topText.textColor!,
                .paragraphStyle: paragraphStyle
            ]
            let topRect = CGRect(
                x: rect.minX + 20,
                y: rect.minY + 20 * imageScale,
                width: image.size.width - 40,
                height: textRectHeight)
            let topTextToDraw = NSAttributedString(string: topText.text, attributes: attributes)
            topTextToDraw.draw(in: topRect)
            let bottomRect = CGRect(
                x: rect.minX + 20,
                y: rect.maxY - 20 * imageScale - textRectHeight,
                width: image.size.width - 40,
                height: textRectHeight)
            let bottomTextToDraw = NSAttributedString(string: bottomText.text, attributes: attributes)
            bottomTextToDraw.draw(in: bottomRect)
        }
        
        let shareVC = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        present(shareVC, animated: true)
    }
    
    private var colors = [UIColor.black, UIColor.white, UIColor.red]
    private var currentColor = 0
    @objc
    private func imageTapped(recogniser: UITapGestureRecognizer) {
        if topText.isFirstResponder {
            topText.resignFirstResponder()
        } else if bottomText.isFirstResponder {
            bottomText.resignFirstResponder()
        } else {
            currentColor += 1
            if currentColor >= colors.count { currentColor = 0 }
            topText.textColor = colors[currentColor]
            bottomText.textColor = colors[currentColor]
        }
    }
    
    @objc
    private func updateTextViewLayout(notification: Notification) {
        guard bottomText.isFirstResponder else { return }
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            imageViewCenterY.constant = .zero
        } else {
            let imgBottomSpace = (view.frame.height - imageView.frame.height)/2
            imageViewCenterY.constant = -(keyboardViewEndFrame.height - imgBottomSpace)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let lines = textView.text.components(separatedBy: .newlines)
        if lines.count > 2 {
            textView.text = lines[0] + "\n" + lines[1]
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor.secondarySystemFill
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor.clear
    }

}

