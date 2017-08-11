//
//  SurveyMatchesTableView.swift
//  
//
//  Created by gregoryew1 on 8/5/17.
//
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class SurveyMatchesTableViewController: SurveyBaseViewController, UITableViewDelegate, UITableViewDataSource, ModalTransitionDelegate {

    var breeds: Dictionary<String, [Breed]> = [:]
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101:"", playListID: "");
    var whichSeque: String = ""
    var breedStat: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101: "", playListID: "")
    var titles:[String] = []
    
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func startOverTapped(_ sender: Any) {
        let mpvc = (parent) as! SurveyManagePageViewController
        
        let viewController = mpvc.viewQuestionEntry(0)
    
        mpvc.setViewControllers([viewController!], direction: .reverse, animated: true, completion: nil)
    }
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    deinit {
        print ("MasterViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        DatabaseManager.sharedInstance.fetchBreeds(true) { (breeds) -> Void in
            self.titles = breeds.keys.sorted{ $0 < $1 }
            self.breeds = breeds
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            guard let _: SurveyMatchesTableViewCell = tableView.cellForRow(at: indexPath) as? SurveyMatchesTableViewCell else {
                return }
            let breed = breeds[titles[indexPath.section]]![indexPath.row]
            let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreedInfoDetail2") as! BreedInfoDetailViewController
            globalBreed = breed
            details.modalDelegate = self
            tr_presentViewController(details, method: DemoPresent.CIZoom(transImage: .cat), completion: {
                print("Present finished.")
            })
            filterOptions.reset()
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
        let cell = (tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SurveyMatchesTableViewCell)
        
        cell.selectionStyle = .none
        
        let breed = breeds[titles[indexPath.section]]![indexPath.row]
        
        cell.backgroundColor = lightBackground
        
        cell.CatNameLabel.backgroundColor = UIColor.clear
        cell.CatNameLabel.highlightedTextColor = textColor
        cell.CatNameLabel.textColor = textColor
        //cell.CatNameLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        cell.accessoryType = .disclosureIndicator
        
        cell.CatNameLabel.text = breed.BreedName

        cell.CatImage.image = UIImage(named: breed.PictureHeadShotName)
        
        cell.CatPercentage.text = "\(breed.PercentMatch)%"
        
        let valueView = ViewValue()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        valueView.valueView = cell.CatValueView
        
        valueView.maxValue = 100
        valueView.statValue = Double(breed.PercentMatch)
        cell.CatValueView.layer.addSublayer(valueView)
        DispatchQueue.main.async(execute: {
            valueView.needsLayout()
            valueView.layoutSublayers()
            valueView.setNeedsDisplay()
            valueView.frame = cell.CatValueView.frame
            CATransaction.commit()
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let trimmedString = "   \(titles[section])"
        return trimmedString
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        breedStat = breeds[titles[indexPath.section]]![indexPath.row]
        globalBreed = breedStat
        self.performSegue(withIdentifier: "BreedStats", sender: nil)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return []
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int{
        let temp = titles as NSArray
        return temp.index(of: title)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell2") as! SurveyMatchesHeaderTableViewCell
        cell.titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        cell.backgroundColor = UIColor(red: 193.0/255.0, green: 231.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
