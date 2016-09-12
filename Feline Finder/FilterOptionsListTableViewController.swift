//
//  FilterOptionsListTableViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 9/9/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class FilterOptionsListTableViewController: UITableViewController {
    
    var filterOpt: filterOption?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
    }
    
    @IBAction func unwindToFilterOptionList(sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
    {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filterOpt!.options.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        return (filterOpt?.name)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = filterOpt?.optionsArray()[indexPath.row]
        if ((filterOpt?.choosenListValues.contains(indexPath.row)) == true) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if ((filterOpt?.choosenListValues.contains(indexPath.row)) == true) {
            filterOpt?.choosenListValues = (filterOpt?.choosenListValues.filter(){$0 != indexPath.row})!
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
        } else {
            filterOpt?.choosenListValues.append(indexPath.row)
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        }
        return indexPath
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

}