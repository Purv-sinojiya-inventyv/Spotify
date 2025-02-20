import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   // Ensure this is connected in the storyboard
    
    @IBOutlet weak var tablevVew: UITableView!
    private var profile: UserProfile?
    private var model = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
      
      
        // ✅ Register TableViewCell (only if not using Storyboard prototype)
   
        // ✅ Ensure data is loaded before table reload
        
        fetchUserProfile()
    }
    
    private func fetchUserProfile() {
        print("🔍 Fetching user profile...")
        
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("✅ Profile fetched: \(profile.display_name)")
                    self?.profile = profile
                    self?.updateUI()
                    
                case .failure(let error):
                    print("🚨 Failed to fetch profile:", error.localizedDescription)
                    self?.failedToGetProfile()
                }
            }
        }
    }

    private func updateUI() {
        print("**********************************************")
        guard let profile = profile else {
            print("⚠️ No profile data found")
            return
        }

        // ✅ Properly setting up model
        model = [
            "Full Name: \(profile.display_name)",
            "Email: \(profile.email)",
            "User ID: \(profile.id)"
        ]
        
        print("👤 User Profile Updated:", model)
        DispatchQueue.main.async {
            self.tablevVew.reloadData()
        }
       
    }
    
    private func failedToGetProfile() {
        print("❌ Failed to fetch profile")
    }

    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 Total rows in tableView: \(model.count)")
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ✅ Ensure correct identifier is used
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        
        print("🛠 Configuring cell at index: \(indexPath.row) with text: \(model[indexPath.row])")
        
        // ✅ Corrected label text assignment
        cell.textLabel?.text = model[indexPath.row]
        cell.accessoryType = .disclosureIndicator  // Adds an arrow for navigation
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("✅ Selected row at index: \(indexPath.row)")
    }
}
