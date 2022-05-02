//
//  HypeListViewController.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/2/22.
//

import UIKit

class HypeListViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var hypeListTableView: UITableView!
    
    //MARK: - Properties
    var refresh: UIRefreshControl = UIRefreshControl()
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    //MARK: - IBActions
    @IBAction func addHypeButtonTapped(_ sender: Any) {
        presentAddHypeAlert()
    }

    //MARK: - Helper Methods
    @objc func loadData() {
        HypeController.shared.fetchHypes { success in
            if success {
                self.updateViews()
            }
        }
    }//End of function
    
    func setupViews() {
        hypeListTableView.delegate = self
        hypeListTableView.dataSource = self
        refresh.attributedTitle = NSAttributedString(string: "Pull to see more Hypes!")
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)
        hypeListTableView.addSubview(refresh)
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.hypeListTableView.reloadData()
            self.refresh.endRefreshing()
        }
    }//End of function
    
    func presentAddHypeAlert() {
        let alert = UIAlertController(title: "Get Hype!", message: "What is hype may never die", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "What is hype today?"
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addHypeAction = UIAlertAction(title: "Send", style: .default) { _ in
            guard let text = alert.textFields?.first?.text,
                  !text.isEmpty
            else { return }
            
            HypeController.shared.saveHype(with: text) { success in
                if success {
                    self.updateViews()
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(addHypeAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}//End of class

extension HypeListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hypeListTableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
        let hypeToDisplay = HypeController.shared.hypes[indexPath.row]
        
        cell.textLabel?.text = hypeToDisplay.body
        cell.detailTextLabel?.text = hypeToDisplay.timestamp.formatDate()
        
        return cell
    }
    
}//End of extension
