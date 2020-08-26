//
//  ViewController.swift
//  FlagList
//
//  Created by Evgeniy Kurapov on 13.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var flags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Flags"
        navigationItem.largeTitleDisplayMode = .always
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let contents = try! fm.contentsOfDirectory(atPath: path)
        flags.append(contentsOf: contents.filter{ $0.hasSuffix(".png") })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flag", for: indexPath)
        let imageName = flags[indexPath.row]
        cell.textLabel?.text = imageName.dropLast(4).uppercased()
        cell.imageView?.image = UIImage(named: imageName)?.imageWithBorder(width: 0.5, color: UIColor.systemGray)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.imageName = flags[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

