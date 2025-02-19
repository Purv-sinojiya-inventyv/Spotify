import UIKit

class ProfileViewController: UIViewController {
    
    private var profile: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        fetchUserProfile()
    }
    
    private func fetchUserProfile() {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.profile = profile
                    self?.updateUI()
                case .failure(let error):
                    print("🚨 Failed to fetch profile:", error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI() {
        guard let profile = profile else { return }
        print("👤 User Profile:", profile)
    }
}
