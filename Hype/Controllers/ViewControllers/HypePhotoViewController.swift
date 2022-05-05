//
//  HypePhotoViewController.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/5/22.
//

import UIKit

class HypePhotoViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var hypeTextField: UITextField!
    @IBOutlet weak var photocontainerView: UIView!
    
    //MARK: - Properties
    var image: UIImage?
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard let text = hypeTextField.text,
              !text.isEmpty,
              let image = image
        else { return }
        
        HypeController.shared.saveHype(with: text, photo: image) { success in
            if success {
                self.dismissView()
            }
        }
    }
    
    //MARK: - Helper Methods
    func setupViews() {
        photocontainerView.layer.cornerRadius = photocontainerView.frame.height / 10
        photocontainerView.clipsToBounds = true
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
    
}//End of class

extension HypePhotoViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
    
}//End of extension
