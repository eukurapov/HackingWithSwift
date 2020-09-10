//
//  ViewController.swift
//  Countries
//
//  Created by Eugene Kurapov on 10.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var countries = [Country]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Countries"
        fetchCountries()
    }
    
    private func fetchCountries() {
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            if let url = Bundle.main.url(forResource: "countries", withExtension: "json") {
                if let data = try? Data(contentsOf: url) {
                    let decoder = JSONDecoder()
                    self.countries = (try? decoder.decode([Country].self, from: data)) ?? []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: coutryCellIdentifier, for: indexPath)
        let country = countries[indexPath.row]
        if let countryCell = cell as? CountryTableViewCell {
            countryCell.name.text = country.name
            countryCell.flag.url = country.flagUrl
            countryCell.flag.layer.shadowColor = UIColor.darkGray.cgColor
            countryCell.flag.layer.shadowOffset = CGSize(width: 0, height: 1)
            countryCell.flag.layer.shadowRadius = 2
            countryCell.flag.layer.shadowOpacity = 0.5
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: detailVCIdentifier) as? DetailViewController {
            detailVC.country = countries[indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: - Constant Values
    
    private let coutryCellIdentifier = "CountryCell"
    private let detailVCIdentifier = "DetailsView"

}

