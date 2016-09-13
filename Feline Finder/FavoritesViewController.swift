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
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
    }
    
    @IBAction func unwindToFavorites(sender: UIStoryboardSegue)
    {
        Favorites.loaded = false
        Favorites.Favorites.removeAll()
        Favorites.breedKeys.removeAll()
        Favorites.LoadFavorites()
        
        Favorites.assignStatus(self.tableView) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
    {
        if Utilities.isNetworkAvailable() {
            return true
        } else {
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "petFinderDetail") {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let favoritePet = Favorites[indexPath.section, indexPath.row]
                (segue.destinationViewController as! PetFinderViewDetailController).petID = favoritePet.petID
                (segue.destinationViewController as! PetFinderViewDetailController).petName = favoritePet.petName
                (segue.destinationViewController as! PetFinderViewDetailController).whichSegue = "Favorites"
                (segue.destinationViewController as! PetFinderViewDetailController).favoriteType = favoritePet.FavoriteDataSource
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        if Favorites.totalBreeds == 0 {
            return 1
        } else {
            return Favorites.totalBreeds
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if Favorites.totalBreeds == 0 {
            return 1
        } else {
            return Favorites.countBreedsInSection(section)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        if Favorites.totalBreeds == 0 {
            return ""
        } else {
            return Favorites.breedKeys[section]
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FavoriteTableCell
        
        //cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        
        if ((cell.backgroundView is CustomCellBackground) == false) {
            let backgroundCell = CustomCellBackground()
            cell.backgroundView = backgroundCell
        }
        
        //if ((cell.selectedBackgroundView is CustomCellBackground) == false) {
        //    let selectedBackgroundCell = CustomCellBackground()
        //    cell.selectedBackgroundView = selectedBackgroundCell
        //}
        
        cell.accessoryType = .None
        
        cell.CatName!.backgroundColor = UIColor.clearColor()
        cell.CatName!.highlightedTextColor = UIColor.whiteColor()
        cell.CatName!.textColor = UIColor.whiteColor()
        cell.CatName!.font = UIFont.boldSystemFontOfSize(14.0)
        
        if Favorites.totalBreeds == 0 {
            cell.CatName!.text = "None yet. To add one tap a heart."
            cell.CatImage.hidden = true
            cell.detailTextLabel!.hidden = true
            return cell
        }
        
        cell.CatImage.hidden = false
        //cell.detailTextLabel!.hidden = false
        
        let favorite = Favorites[indexPath.section, indexPath.row]
        
        cell.accessoryType = .DisclosureIndicator
        
        cell.lastCell = indexPath.row == Favorites.countBreedsInSection(indexPath.section) - 1
        
        let imgURL = NSURL(string: favorite.imageName)
        
        var name = favorite.petName
        if favorite.Status != "" {
            name += " (" + favorite.Status + ")"
        }
        
        cell.CatName!.text = name
        //cell.detailTextLabel!.font = cell.detailTextLabel!.font.fontWithSize(11)
        if favorite.Status.hasPrefix("Adopt") {
            cell.CatName!.textColor = UIColor.redColor()
        } else {
            cell.CatName!.textColor = UIColor.whiteColor()
        }
        //cell.detailTextLabel!.text = favorite.Status
        
        cell.CatImage?.image = UIImage(named: "Cat-50")
        
        if let img = imageCache[favorite.imageName] {
            cell.CatImage?.image = img
        } else {
            let request: NSURLRequest = NSURLRequest(URL: imgURL!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FavoriteTableCell {
                            cellToUpdate.CatImage?.image = image
                        }
                    })
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    {
        self.performSegueWithIdentifier("petFinderDetail", sender: nil)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true);
    }
}