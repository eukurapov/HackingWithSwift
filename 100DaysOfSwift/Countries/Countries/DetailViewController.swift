//
//  DetailViewController.swift
//  Countries
//
//  Created by Eugene Kurapov on 10.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var country: Country?
    
    @IBOutlet weak var flag: FetchedImageView!
    @IBOutlet weak var details: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        details.delegate = self
        details.dataSource = self
        
        title = "Coutry name"
        
        if let country = country {
            title = country.name
            flag.url = country.flagUrl
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
    
    @objc
    private func share() {
        guard let image = flag.image else { return }
        guard let country = country else { return }
        let description = "\(country.name)\nCurrency: \(country.currency)\nCode: \(country.isoCode)"
        let vc = UIActivityViewController(activityItems: [image, description], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: detailCellIdentifier, for: indexPath)
        guard let country = country else { return cell }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "Capital\n\n"
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = "\(country.capital.name)\n\(country.capital.details)"
        case 1:
            cell.textLabel?.text = "Population"
            cell.detailTextLabel?.text = "\(country.localizedPopulation)"
        case 2:
            cell.textLabel?.text = "Area, km²"
            cell.detailTextLabel?.text = "\(country.localizedArea)"
        case 3:
            cell.textLabel?.text = "Currency"
            cell.detailTextLabel?.text = "\(country.currency)"
        case 4:
            cell.textLabel?.text = "Code"
            cell.detailTextLabel?.text = "\(country.isoCode)"
        default: break
        }
        return cell
    }
    
    // MARK: - Constant Values
    
    private let detailCellIdentifier = "DetailCell"

}

extension Country {
    var localizedPopulation: String {
        NumberFormatter.localizedString(from: NSNumber(value: population), number: .decimal)
    }
    
    var localizedArea: String {
        NumberFormatter.localizedString(from: NSNumber(value: area), number: .decimal)
    }
}

extension Country.City {
    var details: String {
        """
        Population: \(NumberFormatter.localizedString(from: NSNumber(value: population), number: .decimal))
        Area, km²: \(NumberFormatter.localizedString(from: NSNumber(value: area), number: .decimal))
        """
    }
}
