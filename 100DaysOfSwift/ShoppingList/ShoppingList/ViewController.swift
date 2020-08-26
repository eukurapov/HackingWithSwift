//
//  ViewController.swift
//  ShoppingList
//
//  Created by Evgeniy Kurapov on 23.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var shoppingList: [(value: String, isSelected: Bool)]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shoppingList = [("bread", false), ("butter", false), ("coffee", false)]
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed)),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePressed))
            ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshPressed))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shoppingList[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingItem", for: indexPath)
        let item = shoppingList[indexPath.row]
        let attributedString = NSMutableAttributedString(string: item.value)
        if item.isSelected {
            cell.accessoryType = .checkmark
            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributedString.length))
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.attributedText = attributedString
        return cell
    }
    
    @objc func addPressed() {
        let vc = UIAlertController(title: "Add item", message: nil, preferredStyle: .alert)
        vc.addTextField()
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let itemValueToAdd = vc.textFields?[0].text else { return }
            self.addItem(itemValue: itemValueToAdd)
        })
        present(vc, animated: true)
    }
    
    func addItem(itemValue: String) {
        shoppingList.insert((itemValue, false), at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    @objc func refreshPressed() {
        shoppingList = []
        tableView.reloadData()
    }
    
    @objc func sharePressed() {
        let listToShare = shoppingList.reduce(into: "") { result, item in
            result += item.value + (item.isSelected ? " ✓" : "") + "\n"
        }
        let vc = UIActivityViewController(activityItems: [listToShare], applicationActivities: nil)
        present(vc, animated: true)
    }
}

