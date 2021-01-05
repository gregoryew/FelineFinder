//
//  MainTabAdoptableCatsDetailViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit

class AdoptableCatsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, descriptionChanged {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pet: Pet!
    
    var rowHeight = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Favorites.storeIDs()
    }
    
    @IBAction func backButtonTapped(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "header") as? AdoptableHeaderTableViewCell {
                cell.setup(pet: self.pet)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "description") as? AdoptableDescriptionTableViewCell {
                cell.delegate = self
                cell.setup(pet: self.pet, shelter: globalShelterCache[pet.shelterID]!)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return CGFloat(max(100, rowHeight) + 40)
        } else {
            return 584
        }
    }
    
    func heightChanged(heigth: Int) {
        if rowHeight != heigth {
            rowHeight = heigth
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.view.layoutSubviews()
            })
        }
    }
}
