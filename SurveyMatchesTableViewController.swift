//
//  SurveyMatchesTableView.swift
//  
//
//  Created by gregoryew1 on 8/5/17.
//
//

import UIKit

class SurveyMatchesTableViewController: SurveyBaseViewController, UITableViewDelegate, UITableViewDataSource {

    var breeds: Dictionary<String, [Breed]> = [:]
    var breed: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101:"", playListID: "");
    var whichSeque: String = ""
    var breedStat: Breed = Breed(id: 0, name: "", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "0", youTubeURL: "", cats101: "", playListID: "")
    var titles:[String] = []
        
    @IBOutlet var tableView: UITableView!
    
    @IBAction func startOverTapped(_ sender: Any) {
        //let mpvc = (parent) as! SurveyManagePageViewController
        
        //let viewController = mpvc.viewQuestionEntry(0)
    
        //mpvc.setViewControllers([viewController!], direction: .reverse, animated: true, completion: nil)
    }
        
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
            //let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreedInfoDetail2") as! BreedInfoDetailViewController
            //details.modalPresentationStyle = .custom
            //details.transitioningDelegate = self
            //globalBreed = breed
            //present(details, animated: true, completion: nil)
            //filterOptions.reset()
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
        
        DispatchQueue.main.async(execute: {
            let vv = cell.CatValueView
            vv?.percent = CGFloat((Double(breed.PercentMatch) / 100.00) * Double(cell.CatValueView.bounds.size.width))
            vv?.setNeedsDisplay()
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


class ValueView2: UIView {
    
    var percent: CGFloat = 0.0
    
    func drawProgressBar(_ frame: CGRect = CGRect(x: 0, y: 0, width: 300, height: 16), progress: CGFloat = 265) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let color = UIColor(red: 0.910, green: 0.969, blue: 0.839, alpha: 1.000)
        let color2 = UIColor(red: 0.361, green: 0.796, blue: 0.980, alpha: 1.000)
        let color3 = UIColor(red: 0.976, green: 0.996, blue: 0.945, alpha: 1.000)
        
        let colours = [color2.cgColor, UIColor.blue.cgColor] as CFArray
        
        //// Gradient Declarations
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colours, locations: [0, 1])!
        
        //// Progress Border Drawing
        let progressBorderPath = UIBezierPath(roundedRect: CGRect(x: frame.minX + 1, y: frame.minY + 1, width: floor((frame.width - 1) * 0.99666 + 0.5), height: 25), cornerRadius: 10)
        color3.setFill()
        progressBorderPath.fill()
        color.setStroke()
        progressBorderPath.lineWidth = 1
        progressBorderPath.stroke()
        
        
        //// Progress Active Drawing
        let progressActivePath = UIBezierPath(roundedRect: CGRect(x: 1, y: 1, width: progress, height: 25), cornerRadius: 10)
        context!.saveGState()
        progressActivePath.addClip()
        let progressActiveRotatedPath = UIBezierPath()
        progressActiveRotatedPath.append(progressActivePath)
        var progressActiveTransform = CGAffineTransform(rotationAngle: -45*(-CGFloat(Double.pi)/180))
        progressActiveRotatedPath.apply(progressActiveTransform)
        let progressActiveBounds = progressActiveRotatedPath.cgPath.boundingBoxOfPath
        progressActiveTransform = progressActiveTransform.inverted()
        
        context!.drawLinearGradient(gradient,
                                    start: CGPoint(x: progressActiveBounds.minX, y: progressActiveBounds.midY).applying(progressActiveTransform),
                                    end: CGPoint(x: progressActiveBounds.maxX, y: progressActiveBounds.midY).applying(progressActiveTransform),
                                    options: CGGradientDrawingOptions())
        context!.restoreGState()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawProgressBar(rect, progress: percent)
    }
}
