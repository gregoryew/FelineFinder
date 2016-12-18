//
//  TitleScreenViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 7/6/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit

class TitleScreenViewController: UIViewController {
    
    var timer = Timer()
    var counter = 0
    
    @IBOutlet var background: UIView!
    
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //background.frame = CGRectMake(0, 0, background.frame.width, background.frame.height)
        /*
        let img = UIImageView(image: UIImage(named: "background"))
        img.contentMode = .ScaleToFill
        if UIDevice().type != .iPhone6S {
            img.frame = CGRectMake(0, 0, background.frame.width, background.frame.height - 5)
        }
        img.tag = 999
        if let viewWithTag = background.viewWithTag(999) {
            viewWithTag.removeFromSuperview()
        } else {
            print("No!")
        }
        background.addSubview(img)
        background.sendSubviewToBack(img)
        background.backgroundColor = UIColor.blackColor()
        */
        if let viewWithTag = background.viewWithTag(999) {
            viewWithTag.sendSubview(toBack: self.view)
        } else {
            print("No!")
        }
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        //timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(TitleScreenViewController.doAnimation), userInfo: nil, repeats: true)
    }
    
    @IBAction func AdoptACat(_ sender: AnyObject) {
        performSegue(withIdentifier: "AdoptACat", sender: nil)
    }
    
    @IBAction func FindACatTouchUpInside(_ sender: AnyObject) {
        if questionList.count == 0 {
            self.performSegue(withIdentifier: "QuestionEntry", sender: nil)
            return
        }
        
        let alertController = UIAlertController(title: "New Search?", message: "Do you want a new search or to keep the existing one?", preferredStyle: .alert)
        
        // Create the actions.
        let newAction = UIAlertAction(title: "New", style: .cancel) { action in
            NSLog("New Button Pressed");
            questionList = QuestionList()
            questionList.getQuestions()
            SearchTitle = "SUMMARY"
            self.performSegue(withIdentifier: "QuestionEntry", sender: nil)
        }
        
        let existingAction = UIAlertAction(title: "Existing", style: .default) { action in
            self.performSegue(withIdentifier: "QuestionEntry", sender: nil)
        }
        
        // Add the actions.
        alertController.addAction(newAction)
        alertController.addAction(existingAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /*
    @IBAction func WarningTouchUpInside(sender: AnyObject) {
        let alert = UIAlertView()
        alert.title = "Alert"
        alert.message = "This App is provided as is without any guarantees or warranty.  In association with the production Gregory Edward Williams makes no warranties of any kind, either express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, of title, or of noninfringment of third party rights.  Use of the product by a user is at the user's risk."
        alert.addButtonWithTitle("Understood")
        alert.show()
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bottomMargin.constant = 5
        
        //timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(TitleScreenViewController.doAnimation), userInfo: nil, repeats: true)
        
    }
    
    /*
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    /*
    func doAnimation() {
        if counter == 10
        {
            timer.invalidate()
        }
        else {
            counter += 1
            welcomeImage.image = UIImage(named: "welcome_cat_\(counter).png")
        }
        
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdoptACat" {
            let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "");
            (segue.destination as! PetFinderViewController).breed = breed
        }
     }
}
