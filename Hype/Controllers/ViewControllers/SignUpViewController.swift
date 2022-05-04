//
//  SignUpViewController.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/4/22.
//

import UIKit

class SignUpViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    
    //MARK: - Properties
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    
    //MARK: - IBActions
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text,
              let bio = bioTextField.text,
              !username.isEmpty
        else { return }
        
        UserController.shared.createUser(with: username, bio: bio) { success in
            if success {
                self.presentHypeListVC()
            }
        }
    }
    
    //MARK: - Helper Methods
    func fetchUser() {
        UserController.shared.fetchUser { success in
            if success {
                self.presentHypeListVC()
            }
        }
    }//End of function
    
    func presentHypeListVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
}//End of class
