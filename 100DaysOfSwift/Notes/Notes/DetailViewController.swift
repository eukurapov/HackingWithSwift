//
//  DetailViewController.swift
//  Notes
//
//  Created by Eugene Kurapov on 16.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    
    var note: Note!
    
    var composeAction: (()->())?
    var removeAction: (()->())?
    var editCompletionHandler: (()->())?
    
    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let patternImage = UIImage(named: "paper") {
            view.backgroundColor = UIColor(patternImage: patternImage)
        }
        
        textView.text = note.text
        
        textView.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        
        if note.text.isEmpty {
            textView.becomeFirstResponder()
        }
        
        var toolbarItems = [UIBarButtonItem]()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems.append(spacer)
        if removeAction != nil {
            let removeButton = UIButton()
            removeButton.setImage(UIImage(systemName: "trash"), for: .normal)
            removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
            let removeItem = UIBarButtonItem(customView: removeButton)
            toolbarItems.append(removeItem)
        }
        let fixedSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpacer.width = 10
        toolbarItems.append(fixedSpacer)
        if composeAction != nil {
            let composeItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(compose))
            toolbarItems.append(composeItem)
        }
        setToolbarItems(toolbarItems, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        note.text = textView.text
        editCompletionHandler?()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let doneItem = (UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completeEdit)))
        navigationItem.rightBarButtonItems?.insert(doneItem, at: 0)
    }
    
    @objc
    private func completeEdit() {
        textView.resignFirstResponder()
        navigationItem.rightBarButtonItems?.removeFirst()
        editCompletionHandler?()
    }
    
    @objc
    func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        var contentInset = textView.contentInset
        if notification.name == UIResponder.keyboardWillHideNotification {
            contentInset.bottom = .zero
        } else {
            contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        }
        textView.contentInset = contentInset
        
        textView.scrollIndicatorInsets = textView.contentInset
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    @objc
    private func share() {
        let ac = UIActivityViewController(activityItems: [textView.text!], applicationActivities: nil)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    @objc
    private func compose() {
        composeAction?()
    }
    
    @objc
    private func remove() {
        navigationController?.popViewController(animated: false)
        removeAction?()
    }
}
