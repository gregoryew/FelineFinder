//
//  FavoritesViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/11/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import SDWebImage

class FavoritesViewController: UITableViewController {
/*
    var statuses:[String: Favorite] = [:]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
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
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if Favorites.totalBreeds == 0 {
            return 1
        } else {
            return Favorites.totalBreeds
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if Favorites.totalBreeds == 0 {
            return 1
        } else {
            return Favorites.countBreedsInSection(section)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        if Favorites.totalBreeds == 0 {
            return ""
        } else {
            return Favorites.breedKeys[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FavoriteTableCell
        
        cell.accessoryType = .none
        cell.backgroundColor = lightBackground
        cell.CatName!.backgroundColor = lightBackground
        cell.CatName!.textColor = textColor
        cell.CatName!.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        if Favorites.totalBreeds == 0 {
            cell.CatName!.text = "None yet. To add one tap a heart."
            cell.CatImage.isHidden = true
            return cell
        }
        
        cell.CatImage.isHidden = false
        
        let favorite = Favorites[indexPath.section, indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
                
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let felineDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FelineDetail") as! PetFinderViewDetailController
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if Favorites.count == 0 {return}
            let favoritePet = Favorites[indexPath.section, indexPath.row]
            felineDetail.petID = favoritePet.petID
            felineDetail.petName = favoritePet.petName
            felineDetail.whichSegue = "Favorites"
            felineDetail.favoriteType = favoritePet.FavoriteDataSource
            felineDetail.modalPresentationStyle = .custom
            //felineDetail.transitioningDelegate = self
            //globalBreed = breed
            //present(details, animated: true, completion: nil)
        }
        //navigationController?.tr_pushViewController(felineDetail, method: DemoTransition.CIZoom(transImage: transitionImage.heart))
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.lightColor = headerLightColor
        header.darkColor = headerDarkColor
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        Favorites.LoadFavorites(tv: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        //self.navigationController?.setToolbarHidden(true, animated:false);
    }
    
    /*
    @IBAction func backTapped(_ sender: Any) {
        _ = navigationController?.tr_popViewController()
    }
    */
*/
}
