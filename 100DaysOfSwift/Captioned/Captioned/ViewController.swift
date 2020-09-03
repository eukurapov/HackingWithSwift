//
//  ViewController.swift
//  Captioned
//
//  Created by Eugene Kurapov on 02.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var photos = [CaptionedPhoto]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [editButtonItem]
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            navigationItem.rightBarButtonItems?.insert(
                UIBarButtonItem(
                    barButtonSystemItem: .camera,
                    target: self,
                    action: #selector(addPressed)),
                at: 0)
        }
        
        load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc
    private func addPressed() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let photo = photos[indexPath.row]
        if let photoCell = cell as? PhotoCell {
            photoCell.caption.text = photo.caption
            photoCell.photo?.image = UIImage(contentsOfFile: photo.imagePath.path)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return fixedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                photos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                save()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            showEditAlert { [weak self] caption in
                self?.photos[indexPath.row].caption = caption
                self?.save()
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        } else {
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: detailViewControllerIdentifier) as? DetailViewController {
                let photo = photos[indexPath.row]
                detailVC.caption = photo.caption
                detailVC.image = UIImage(contentsOfFile: photo.imagePath.path)
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    private var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        showEditAlert { [weak self] caption in
            if let self = self {
                let newName = UUID().uuidString
                let path = self.documentDirectory.appendingPathComponent(newName)
                try? image.jpegData(compressionQuality: 0.8)?.write(to: path)
                
                let photo = CaptionedPhoto(caption: caption, imageName: newName)
                self.photos.append(photo)
                self.save()
                if let index = self.photos.firstIndex(where: { $0.imageName == photo.imageName }) {
                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func showEditAlert(handler: @escaping (String)->Void) {
        let ac = UIAlertController(title: "Set Caption", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                if let text = ac.textFields?.first?.text, !text.isEmpty {
                    handler(text)
                }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // MARK: - UserDefaults
    
    private func save() {
        let encoder = JSONEncoder()
        if let photosData = try? encoder.encode(photos) {
            UserDefaults.standard.set(photosData, forKey: photosDefaultsKey)
        } else {
            print("Coudn't save photos")
        }
    }
    
    private func load() {
        let decoder = JSONDecoder()
        if let photosData = UserDefaults.standard.value(forKey: photosDefaultsKey) as? Data {
            photos = (try? decoder.decode([CaptionedPhoto].self, from: photosData)) ?? []
        }
    }
    
    // MARK: - Constant Values
    
    // Keys
    private var photosDefaultsKey = "CaptionedPhotos"
    
    // Storyboard IDs
    private var cellIdentifier = "PhotoCell"
    private var detailViewControllerIdentifier = "Detail"
    
    // Size restrictions
    private var fixedRowHeight: CGFloat = 116

}

extension CaptionedPhoto {
    var imagePath: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(imageName)
    }
}
