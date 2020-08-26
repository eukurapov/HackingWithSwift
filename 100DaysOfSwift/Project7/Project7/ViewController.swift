//
//  ViewController.swift
//  Project7
//
//  Created by Evgeniy Kurapov on 24.05.2020.
//  Copyright © 2020 Evgeniy Kurapov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var petitions = [Petition]()
    private var filterText: String?
    private var filteredPetitions: [Petition] {
        if let filterText = filterText {
            return petitions.filter {
                $0.title.lowercased().contains(filterText.lowercased()) ||
                $0.body.lowercased().contains(filterText.lowercased())
            }
        } else {
            return petitions
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Petitions"
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        
        showError()
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "Can load data. Please try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let petitionsJson = try? decoder.decode(Petitions.self, from: json) {
            petitions = petitionsJson.results
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Bar Button Items and Actions
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    @IBAction func search(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Search", message: "Input text to filter petitions", preferredStyle: .alert)
        ac.addTextField { textField in
            textField.text = self.filterText
        }
        ac.addAction(UIAlertAction(title: "Search", style: .default, handler: { action in
            if let searchText = ac.textFields?.first?.text, !searchText.isEmpty {
                self.filterText = searchText
                self.tableView.reloadData()
                self.title = "Filtered by: \(self.filterText!)"
                self.clearButton.isEnabled = true
            }
        }))
        present(ac, animated: true)
    }
    
    @IBAction func clear(_ sender: UIBarButtonItem) {
        filterText = nil
        tableView.reloadData()
        self.title = "Petitions"
        clearButton.isEnabled = false
    }
    
}

