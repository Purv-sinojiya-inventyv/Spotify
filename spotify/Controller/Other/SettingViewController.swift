//
//  SettingViewController.swift
//  Spotify
//
//  Created by Purv Sinojiya on 14/02/25.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!  // Ensure it's connected in Storyboard

    private var sections = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
       

        configureModels() // Load data
       
        // ✅ Check if tableView is connected

        // Set up tableView
        tableView.dataSource = self
        tableView.delegate = self

        // ✅ Register TableViewCell (only if not using Storyboard prototype)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        
        // ✅ Ensure data is loaded before table reload
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
       
            self.tableView.reloadData()
        }
    }

    private func configureModels() {
     
        
        sections.append(Section(title: "Profile", options: [
            Option(title: "View Your Profile", handler: { [weak self] in
                DispatchQueue.main.async {
                    print("👤 View Profile Tapped")
                    self?.viewProfile()
                }
            })
        ]))
        sections.append(Section(title: "Account", options: [
            Option(title: "Sign Out", handler: { [weak self] in
                DispatchQueue.main.async {
                    print("🚪 Sign Out Tapped")
                    self?.signOutTapped()
                }
            })
        ]))

       
    }

    // MARK: - TableView DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
       
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
     

        // ✅ Ensure correct cell identifier is used
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.accessoryType = .disclosureIndicator  // Adds an arrow for navigation
        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
       
        model.handler()
    }

    // MARK: - Helper Methods

    private func viewProfile() {
        let vc = self.storyboard?.instantiateViewController(
            identifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(
            vc, animated: true)
        // Implement navigation or logic to view profile
    }

    private func signOutTapped() {
       
        // Implement sign-out logic
    }
}
