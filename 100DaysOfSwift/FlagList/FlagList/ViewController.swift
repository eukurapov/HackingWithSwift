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
            let pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal)
            pageController.dataSource = self
            pageController.delegate = self
            pageController.setViewControllers([vc], direction: .forward, animated: false)
            pageController.navigationItem.title = vc.imageName
            navigationController?.pushViewController(pageController, animated: true)
        }
    }
}

extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let detailVC = viewController as? DetailViewController, let imageName = detailVC.imageName {
            if let index = flags.firstIndex(of: imageName) {
                if index > 0 {
                    if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
                        vc.imageName = flags[index - 1]
                        return vc
                    }
                }
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let detailVC = viewController as? DetailViewController, let imageName = detailVC.imageName {
            if let index = flags.firstIndex(of: imageName) {
                if index < flags.count - 1 {
                    if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
                        vc.imageName = flags[index + 1]
                        return vc
                    }
                }
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let detailVC = pageViewController.viewControllers?.first as? DetailViewController {
            pageViewController.navigationItem.title = detailVC.imageName
        }
    }
    
}
