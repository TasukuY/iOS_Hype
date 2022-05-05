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
    @IBOutlet weak var photoContainerView: UIView!
    
    //MARK: - Properties
    var profilePhoto: UIImage?
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchUser()
    }
    
    //MARK: - IBActions
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text,
              let bio = bioTextField.text,
              !username.isEmpty
        else { return }
        
        UserController.shared.createUser(with: username, bio: bio, profilePhoto: profilePhoto) { success in
            if success {
                self.presentHypeListVC()
            }
        }
    }
    
    //MARK: - Helper Methods
    func setupViews() {
        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 2
        photoContainerView.clipsToBounds = true
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
    
}//End of class

extension SignUpViewController: PhotoPickerDelegate {
    
    func photoPickerSelected(image: UIImage) {
        self.profilePhoto = image
    }
    
}//End of extension
