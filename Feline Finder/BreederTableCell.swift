//
//  BreederTableCell.swift
//  Purrfect4U
//
//  Created by Gregory Williams on 6/20/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import UIKit

class BreederCell: UITableViewCell {
    
    @IBOutlet weak var BreederName: UILabel!
    @IBOutlet weak var CallBtn: UIButton!
    @IBOutlet weak var EmailBtn: UIButton!
    @IBOutlet weak var WebBtn: UIButton!
    @IBOutlet weak var Distance: UILabel!
    
    @IBAction func CallTouchUp(sender: AnyObject) {
        #if DEBUG
            phone = "1-856-425-8233"
        #endif
        let url:NSURL = NSURL(string: "tel:\(phone)")!
        let actionSheetController: UIAlertController = UIAlertController(title: "Call Breeder?", message: "Do you want to call \(BreederName.text!) at \(phone) now?", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let callAction: UIAlertAction = UIAlertAction(title: "Call", style: .Default) { action -> Void in
            UIApplication.sharedApplication().openURL(url)
        }
        actionSheetController.addAction(callAction)
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = sender as! UIView;
        
        //Present the AlertController
        tvc!.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func EmailTouchUp(sender: AnyObject) {
        //var url:NSURL = NSURL(string: "mailto:\(email)")!
        //UIApplication.sharedApplication().openURL(url)
        tvc!.sendEmail(email)
    }
    
    @IBAction func WebTouchUp(sender: AnyObject) {
        let url:NSURL = NSURL(string: "http://\(website)")!
        UIApplication.sharedApplication().openURL(url)
    }

    var phone = ""
    var email = ""
    var website = ""
    var tvc: BreedersViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
