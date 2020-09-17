//
//  ViewController.swift
//  Notes
//
//  Created by Eugene Kurapov on 16.09.2020.
//  Copyright © 2020 Eugene Kurapov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    private var notes = {
        [
            Note(text: "Some text for the test note to display"),
            Note(text: ""),
            Note(text: "Some text for the test note to display and some more text for the test note to display and some more text for the test note to display and some more text for the test note to display"),
            Note(text: "Some text for the test note to display\nand some more text for the test note to display\n\nand some more text for the test note to display"),
            Note(text: "This is untitled note with some text for the test note to display")
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        if let patternImage = UIImage(named: "paper") {
            tableView.backgroundColor = UIColor(patternImage: patternImage)
        }
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(compose))
        setToolbarItems([spacer, composeButton], animated: true)
        
        registerCategories()
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.reloadData()
    }
    
    @objc
    private func compose() {
        let note = Note(text: "")
        let firstIndexPath = IndexPath(row: 0, section: 0)
        notes.insert(note, at: 0)
        tableView.insertRows(at: [firstIndexPath], with: .none)
        tableView.selectRow(at: firstIndexPath, animated: false, scrollPosition: .top)
        showDetailsForNoteAt(firstIndexPath)
    }
    
    private func remove(at indexPath: IndexPath) {
        notes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        save()
    }
    
    private func showDetailsForNoteAt(_ indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: detailVCIdentifier) as? DetailViewController else { return }
        detailVC.note = notes[indexPath.row]
        detailVC.composeAction = { [unowned self] in self.compose() }
        detailVC.removeAction = { [unowned self] in self.remove(at: indexPath) }
        detailVC.editCompletionHandler = { [unowned self] in self.save() }
        navigationController?.popViewController(animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: noteCellIdentifier, for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = dateFormatter.string(from: note.lastEdit) + (note.text.isEmpty ? "" : ", " + note.text)
        if let patternImage = UIImage(named: "paper") {
            cell.backgroundColor = UIColor(patternImage: patternImage)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetailsForNoteAt(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            remove(at: indexPath)
        }
    }
    
    // MARK: - Storage
    
    private func load() {
        guard let url = fileUrl else { return }
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            notes = (try? decoder.decode([Note].self, from: data)) ?? notes
        }
    }
    
    private func save() {
        guard let url = fileUrl else { return }
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(notes) {
            try? data.write(to: url)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let category = UNNotificationCategory(identifier: "reminder", actions: [], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let noteID = userInfo["noteID"] as? String {
            if let index = notes.firstIndex { $0.id.uuidString == noteID } {
                showDetailsForNoteAt(IndexPath(row: index, section: 0))
            }
        }
        completionHandler()
    }
    
    // MARK: - Constant Values
    
    private let notesFileName = "notes"
    private var fileUrl: URL? {
        let fileManager = FileManager.default
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(notesFileName)
    }
    
    private let noteCellIdentifier: String = "NoteCell"
    private let detailVCIdentifier: String = "DetailVC"
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

}

