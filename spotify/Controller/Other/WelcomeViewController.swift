//
//  WelcomeViewController.swift
//  spotify
//
//  Created by Purv Sinojiya on 14/02/25.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBAction func signupButtonClick(_ sender: UIButton) {
        let signupScreen =
          self.storyboard?.instantiateViewController(
            identifier: "AuthViewController") as! AuthViewController
        signupScreen.completionHandler = { [weak self] success in
          DispatchQueue.main.async {
            self?.handleSignIn(success)
            print("Disputed to Main")
          }
        }
        self.navigationController?.pushViewController(
          signupScreen, animated: true)
      }
    private func handleSignIn(_ success: Bool) {
        if success {
          if let scene = UIApplication.shared.connectedScenes.first
            as? UIWindowScene
          {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)

              let homeVC = storyboard.instantiateViewController(identifier: "TabBarViewController") as! TabBarViewController
            scene.windows.first?.rootViewController = homeVC
          } else {
            self.signInFailed()
          }
        } else {
          self.signInFailed()
        }
      }

      private func signInFailed() {
        let alert = UIAlertController(
          title: "Oops...",
          message:
            "Something went wrong while signing in. Please try again later.",
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
      }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
