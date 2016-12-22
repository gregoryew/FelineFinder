//
//  FavoritesViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/11/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController: UITableViewController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Favorites.loaded = false
        Favorites.Favorites.removeAll()
        Favorites.breedKeys.removeAll()
        Favorites.LoadFavorites()
        
        Favorites.assignStatus(self.tableView) { () -> Void in
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
    }
    
    @IBAction func unwindToFavorites(_ sender: UIStoryboardSegue)
    {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "felineFinderDetail") {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let favoritePet = Favorites[indexPath.section, indexPath.row]
                (segue.destination as! PetFinderViewDetailController).petID = favoritePet.petID
                (segue.destination as! PetFinderViewDetailController).petName = favoritePet.petName
                (segue.destination as! PetFinderViewDetailController).whichSegue = "Favorites"
                (segue.destination as! PetFinderViewDetailController).favoriteType = favoritePet.FavoriteDataSource
            }
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
        
        //cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        
        /*
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        */
        
        //if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
        //    let selectedBackgroundCell = CustomCellBackground()
        //    cell.selectedBackgroundView = selectedBackgroundCell
        //}
        
        cell.accessoryType = .none
        
        cell.backgroundColor = UIColor.black
        cell.CatName!.backgroundColor = UIColor.black
        //cell.CatName!.highlightedTextColor = UIColor.white
        cell.CatName!.textColor = UIColor.white
        cell.CatName!.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        if Favorites.totalBreeds == 0 {
            cell.CatName!.text = "None yet. To add one tap a heart."
            cell.CatImage.isHidden = true
            //cell.detailTextLabel!.isHidden = true
            return cell
        }
        
        cell.CatImage.isHidden = false
        //cell.detailTextLabel!.hidden = false
        
        let favorite = Favorites[indexPath.section, indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        
        cell.lastCell = indexPath.row == Favorites.countBreedsInSection(indexPath.section) - 1
        
        let imgURL = URL(string: favorite.imageName)
        
        var name = favorite.petName
        if favorite.Status != "" {
            name += " (" + favorite.Status + ")"
        }
        
        cell.CatName!.text = name
        //cell.detailTextLabel!.font = cell.detailTextLabel!.font.fontWithSize(11)
        if favorite.Status.hasPrefix("Adopt") {
            cell.CatName!.textColor = UIColor.red
        } else {
            cell.CatName!.textColor = UIColor.white
        }
        //cell.detailTextLabel!.text = favorite.Status
        
        cell.CatImage?.image = UIImage(named: "Cat-50")
        
        if let img = imageCache[favorite.imageName] {
            cell.CatImage?.image = img
        } else {
            let request: URLRequest = URLRequest(url: imgURL!)
            //let mainQueue = NSOperationQueue.mainQueue()
            //NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            _ = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                    if error == nil {
                        // Convert the downloaded data in to a UIImage object
                        let image = UIImage(data: data!)
                        // Update the cell
                        DispatchQueue.main.async(execute: {
                            if let cellToUpdate = tableView.cellForRow(at: indexPath) as? FavoriteTableCell {
                                cellToUpdate.CatImage?.image = image
                            }
                        })
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                }).resume()
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "felineFinderDetail", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.lightColor = UIColor(red:0.51, green:0.73, blue:0.84, alpha:1.0)
        header.darkColor = UIColor(red:0.51, green:0.73, blue:0.84, alpha:1.0)
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
        Favorites.loaded = false
        Favorites.Favorites.removeAll()
        Favorites.breedKeys.removeAll()
        Favorites.LoadFavorites()
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
        Favorites.assignStatus(self.tableView) { () -> Void in
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
}
