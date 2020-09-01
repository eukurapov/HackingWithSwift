//
//  ViewController.swift
//  Project10
//
//  Created by Eugene Kurapov on 01.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
        navigationItem.leftBarButtonItems = [add]
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            navigationItem.leftBarButtonItems!.append(UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(photoPerson)))
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: personCellIdentifier, for: indexPath) as? PersonCell else {
            fatalError("Could not deque reusable cell as PersonCell for identifier \(personCellIdentifier)")
        }
        let person = people[indexPath.item]
        cell.nameLabel.text = person.name
        let path = documentDirectory.appendingPathComponent(person.imageName)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.cornerRadius = 3
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 7
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "Edit \(people[indexPath.item].name)", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(
            title: "Rename",
            style: .default) { [weak self] _ in
                self?.showRenameAlert(for: indexPath)
        })
        ac.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive) { _ in
                collectionView.performBatchUpdates({
                    self.people.remove(at: indexPath.item)
                    self.collectionView.deleteItems(at: [indexPath])
                })
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func showRenameAlert(for indexPath: IndexPath) {
        let ac = UIAlertController(title: "Rename \(people[indexPath.item].name)", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(
            title: "OK",
            style: .default) { [weak self, weak ac] _ in
                guard let newName = ac?.textFields?[0].text else { return }
                self?.people[indexPath.item].name = newName
                self?.collectionView.reloadItems(at: [indexPath])
            })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc
    private func addPerson() {
        showPicker()
    }
    
    @objc
    private func photoPerson() {
        showPicker(withCamera: true)
    }
    
    private func showPicker(withCamera: Bool = false) {
        let picker = UIImagePickerController()
        if withCamera {
            picker.sourceType = .camera
        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let newName = UUID().uuidString
        let path = documentDirectory.appendingPathComponent(newName)
        try? image.jpegData(compressionQuality: 0.8)?.write(to: path)
        
        let newPerson = Person(name: "Unknown", imageName: newName)
        people.append(newPerson)
        if let newItemIndex = people.firstIndex(where: { $0.imageName == newPerson.imageName }) {
            collectionView.insertItems(at: [IndexPath(item: newItemIndex, section: 0)])
        } else {
            collectionView.reloadData()
        }
        
        dismiss(animated: true)
    }
    
    private var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Constant Values
    
    private let personCellIdentifier = "Person"

}

