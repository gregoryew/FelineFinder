//
//  MasterViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 6/4/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

/*
import UIKit
import TransitionTreasury
import TransitionAnimation

class MasterViewController: UITableViewController, NavgationTransitionable {

    var breeds: Dictionary<String, [Breed]> = [:]
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101:"", playListID: "");
    var whichSeque: String = ""
    var breedStat: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101: "", playListID: "")
    var titles:[String] = []
    
    @IBOutlet weak var leftBarItem: UIBarButtonItem!
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    deinit {
        print ("MasterViewController deinit")
    }
    
    @IBAction func goBackTapped(_ sender: AnyObject) {
        if (whichSeque == "results") {
            _ = navigationController?.tr_popViewController()
        } else {
            let title = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Title") as! TitleScreenViewController
            self.navigationController?.tr_pushViewController(title, method: DemoTransition.CIZoom(transImage: transitionImage.cat))
        }
    }
 
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let background = UIImageView(image: UIImage(named: "main_bg.jpg"))
        self.tableView.backgroundView = background;
        
        if (whichSeque == "results")
        {
            DatabaseManager.sharedInstance.fetchBreeds(true) { (breeds) -> Void in
                self.titles = breeds.keys.sorted{ $0 < $1 }
                self.breeds = breeds
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            self.leftBarItem.title = ""
            self.leftBarItem.image = UIImage(named: "back-1")
            self.title = "Matches"
        }
        else {
            DatabaseManager.sharedInstance.fetchBreeds(false) { (breeds) -> Void in
                self.titles = breeds.keys.sorted{ $0 < $1 }
                self.breeds = breeds
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            self.title = "Breeds"
            self.leftBarItem.image = nil
            self.leftBarItem.title = "Menu"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            guard let _: MasterViewCell = tableView.cellForRow(at: indexPath) as? MasterViewCell else {
                return }
            let breed = breeds[titles[indexPath.section]]![indexPath.row]
            let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "breedTabBar") as! BreedTabBarControllerViewController
            globalBreed = breed
            navigationController?.tr_pushViewController(details, method: TRPushTransitionMethod.page, completion: {})
            filterOptions.reset()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.titles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = titles[section]
        return breeds[sectionTitle]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MasterViewCell)

        let breed = breeds[titles[indexPath.section]]![indexPath.row]
 
        cell.backgroundColor = lightBackground
        
        cell.CatNameLabel.backgroundColor = UIColor.clear
        cell.CatNameLabel.highlightedTextColor = textColor
        cell.CatNameLabel.textColor = textColor
        cell.CatNameLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        cell.accessoryType = .disclosureIndicator
        cell.lastCell = indexPath.row == self.breeds[titles[indexPath.section]]!.count - 1
        
        if (breed.PercentMatch != -1) {
            cell.CatNameLabel.text = "\(breed.PercentMatch)% \(breed.BreedName)"
        }
        else {
            cell.CatNameLabel.text = breed.BreedName
        }
        
        cell.CatImage.image = UIImage(named: breed.PictureHeadShotName)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let trimmedString = titles[section].trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
        return trimmedString
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        breedStat = breeds[titles[indexPath.section]]![indexPath.row]
        globalBreed = breedStat
        self.performSegue(withIdentifier: "BreedStats", sender: nil)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if whichSeque != "results" {
            return titles
        } else {
            return []
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if whichSeque != "results" {
            let temp = titles as NSArray
            return temp.index(of: title)
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeader()
        header.lightColor = UIColor.blue
        header.darkColor = UIColor.darkGray
        header.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
*/
