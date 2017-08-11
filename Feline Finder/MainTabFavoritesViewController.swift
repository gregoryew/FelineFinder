//
//  MainTabFavoritesViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 8/7/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import TransitionTreasury
import TransitionAnimation
import StoreKit

class MainTabFavoritesViewController: UIViewController, ModalTransitionDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    var statuses:[String: Favorite] = [:]
    @IBOutlet var tableView: UITableView!
    
    deinit {
        print ("FavoritesViewController deinit")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Favorites.loaded = false
        Favorites.Favorites.removeAll()
        Favorites.breedKeys.removeAll()
        Favorites.LoadFavorites()
        
        Favorites.assignStatus(self.tableView) { (Stats: [String: Favorite]) -> Void in
            self.statuses = Stats
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
        
        if #available( iOS 10.3,*){
            if Favorites.count > 0 {SKStoreReviewController.requestReview()}
        }
    }
        
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool
    {
        if Favorites.totalBreeds == 0 && identifier == "felineFinderDetail" {
            return false
        } else if Utilities.isNetworkAvailable() {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if Favorites.totalBreeds == 0 {
            return 1
        } else {
            return Favorites.totalBreeds
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if Favorites.totalBreeds == 0 {
            return 1
        } else {
            return Favorites.countBreedsInSection(section)
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if Favorites.totalBreeds == 0 {
            return ""
        } else {
            return Favorites.breedKeys[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainTabTableViewCell
        
        cell.accessoryType = .none
        //cell.backgroundColor = lightBackground
        //cell.CatName!.backgroundColor = lightBackground
        cell.CatName!.textColor = textColor
        //cell.CatName!.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        if Favorites.totalBreeds == 0 {
            cell.CatName!.text = "None yet. To add one tap a heart."
            cell.CatImage.isHidden = true
            return cell
        }
        
        cell.CatImage.isHidden = false
        
        let favorite = Favorites[indexPath.section, indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        
        //cell.lastCell = indexPath.row == Favorites.countBreedsInSection(indexPath.section) - 1
        
        let imgURL = URL(string: favorite.imageName)
        
        cell.CatName!.textColor = textColor
        
        var name = favorite.petName
        if let status = self.statuses[favorite.petID]?.Status {
            if status != "" {name += " (" + status + ")"}
            if (status.hasPrefix("Adopt")) {
                cell.CatName!.textColor = UIColor.red
            } else {
                cell.CatName!.textColor = textColor
            }
        }
        
        cell.CatName!.text = name
        
        cell.CatImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let felineDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdoptableCatsDetail") as! CatDetailViewController
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if Favorites.count == 0 {return}
            let favoritePet = Favorites[indexPath.section, indexPath.row]
            felineDetail.petID = favoritePet.petID
            felineDetail.petName = favoritePet.petName
            felineDetail.whichSegue = "Favorites"
            felineDetail.favoriteType = favoritePet.FavoriteDataSource
            felineDetail.modalDelegate = self
            tr_presentViewController(felineDetail, method: DemoPresent.CIZoom(transImage: .cat), completion: {
                print("Present finished.")
            })
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:false);
        
        Favorites.loaded = false
        Favorites.Favorites.removeAll()
        Favorites.breedKeys.removeAll()
        Favorites.LoadFavorites()
        
        Favorites.assignStatus(self.tableView) { (Stats: [String: Favorite]) -> Void in
            self.statuses = Stats
        }
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
}
