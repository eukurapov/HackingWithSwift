//
//  ViewController.swift
//  Project25
//
//  Created by Eugene Kurapov on 21.09.2020.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController,
                      UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                      MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    private var images = [UIImage]()
    
    private var mcPeer: MCPeerID!
    private var mcSession: MCSession!
    private var mcAdvertiserAssistant: MCAdvertiserAssistant!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie Share"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(connect))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showImagePicker))
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(sendMessage)))
        
        mcPeer = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: mcPeer, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    @objc
    private func sendMessage() {
        let ac = UIAlertController(title: "Send Message", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Message Text"
        }
        ac.addAction(UIAlertAction(title: "Send", style: .default) { [unowned self] _ in
            if !self.mcSession.connectedPeers.isEmpty {
                if let text = ac.textFields?.first?.text, !text.isEmpty {
                    if let data = text.data(using: .utf8) {
                        do {
                            try self.mcSession.send(data, toPeers: self.mcSession.connectedPeers, with: .reliable)
                        } catch {
                            let errorAC = UIAlertController(title: "Failed to send message", message: error.localizedDescription, preferredStyle: .alert)
                            errorAC.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(errorAC, animated: true)
                        }
                    }
                }
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // MARK: - MultipeerConnectivity
    
    @objc
    private func connect() {
        let ac = UIAlertController(title: "Connect", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host", style: .default, handler: createSession))
        ac.addAction(UIAlertAction(title: "Join", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func createSession(_ action: UIAlertAction) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: mcServiceType, discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    private func joinSession(_ action: UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: mcServiceType, session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected: print("Connected \(peerID.displayName)")
        case .connecting: print("Connecting… \(peerID.displayName)")
        case .notConnected: print("Disconnected \(peerID.displayName)")
        @unknown default: print("Unknown state for \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [weak self] in
                self?.images.insert(image, at: 0)
                self?.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            }
        } else {
            let text = String(decoding: data, as: UTF8.self)
            if !text.isEmpty {
                DispatchQueue.main.async { [weak self] in
                    let ac = UIAlertController(
                        title: "Message from \(peerID.displayName)",
                        message: text,
                        preferredStyle: .alert
                    )
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath)
        if let imageView = cell.viewWithTag(imageViewTag) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        return cell
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    @objc
    private func showImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        images.insert(image, at: 0)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        sendImage(image)
    }
    
    private func sendImage(_ image: UIImage) {
        if !mcSession.connectedPeers.isEmpty {
            if let data = image.pngData() {
                do {
                    try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    let ac = UIAlertController(title: "Sendning Error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    // MARK: - Constant Values
    
    private let imageCellIdentifier: String = "ImageCell"
    private let imageViewTag: Int = 1000
    
    private let mcServiceType: String = "keu-project25"

}

