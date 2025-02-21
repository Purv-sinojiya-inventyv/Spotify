import UIKit

class ViewController: UIViewController {

    @IBAction func settingButtonTapped(_ sender: UIBarButtonItem) {  // ✅ Renamed function for better clarity
        guard let vc = self.storyboard?.instantiateViewController(identifier: "SettingViewController") as? SettingViewController else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }

    private func fetchData() {
        APICaller.shared.getNewReleases{ result in
            switch result {
            case .success(let model):
                break  // ✅ Placeholder, should handle model properly
            case .failure(let error):
                print("❌ Error fetching new releases: \(error.localizedDescription)") // ✅ Added logging for errors
            }
        }
    }
}
