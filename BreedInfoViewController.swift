//
//  BreedInfoViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 6/30/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class BreedInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModalTransitionDelegate {
    
    var breeds: Dictionary<String, [Breed]> = [:]
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101:"", playListID: "");
    var whichSeque: String = ""
    var breedStat: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101: "", playListID: "")
    var titles:[String] = []
    
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var leftBarItem: UIBarButtonItem!
    
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    
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
        TableView.backgroundView = background;
        
        if (whichSeque == "results")
        {
            DatabaseManager.sharedInstance.fetchBreeds(true) { (breeds) -> Void in
                self.titles = breeds.keys.sorted{ $0 < $1 }
                self.breeds = breeds
                DispatchQueue.main.async(execute: {
                    self.TableView.reloadData()
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
                    self.TableView.reloadData()
                })
            }
            self.title = "Breeds"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = self.TableView.indexPathForSelectedRow {
            guard let _: BreedInfoTableViewCell = TableView.cellForRow(at: indexPath) as? BreedInfoTableViewCell else {
                return }
            let breed = breeds[titles[indexPath.section]]![indexPath.row]
            let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreedInfoDetail2") as! BreedInfoDetailViewController
            globalBreed = breed
            details.modalDelegate = self
            tr_presentViewController(details, method: DemoPresent.CIZoom(transImage: .cat), completion: {
                print("Present finished.")
            })
            //navigationController?.tr_pushViewController(details, method: TRPushTransitionMethod.page, completion: {})
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = titles[section]
        return breeds[sectionTitle]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BreedInfoTableViewCell)
        
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let trimmedString = titles[section].trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
        return trimmedString
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        breedStat = breeds[titles[indexPath.section]]![indexPath.row]
        globalBreed = breedStat
        self.performSegue(withIdentifier: "BreedStats", sender: nil)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if whichSeque != "results" {
            return titles
        } else {
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if whichSeque != "results" {
            let temp = titles as NSArray
            return temp.index(of: title)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
