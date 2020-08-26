//
//  InitialViewController.swift
//  Project4
//
//  Created by Evgeniy Kurapov on 16.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit

class InitialViewController: UITableViewController {

    let hosts = ["apple.com", "hackingwithswift.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select a host to start"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hosts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Host", for: indexPath)
        cell.textLabel?.text = hosts[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ViewController()
        vc.websites = hosts
        vc.initIndex = indexPath.row
        navigationController?.setViewControllers([vc], animated: true)
    }

}
