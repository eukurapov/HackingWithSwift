//
//  ThemePickerViewController.swift
//  MemoryGame
//
//  Created by Eugene Kurapov on 01.10.2020.
//

import UIKit

class ThemePickerViewController: UITableViewController {
    
    private var themes = Theme.defaults

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Memory Game"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: themeCellIdentifier, for: indexPath)
        if indexPath.row < themes.count {
            let theme = themes[indexPath.row]
            cell.textLabel?.text = theme.name
            cell.detailTextLabel?.text = theme.emojis.joined(separator: " ")
        } else {
            cell.textLabel?.text = "Any"
            cell.detailTextLabel?.text = "❓ ❓ ❓ ❓"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: gameFieldIdentifier) as? GameViewController else { return}
        if indexPath.row < themes.count {
            vc.theme = themes[indexPath.row]
        } else {
            vc.theme = Theme.any
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Constant Values
    
    private let themeCellIdentifier: String = "ThemeCell"
    private let gameFieldIdentifier: String = "GameField"

}
