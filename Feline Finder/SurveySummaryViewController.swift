//
//  SurveySummaryViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 8/5/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import Foundation
import UIKit
import TransitionTreasury
import TransitionAnimation

class SurveySummaryViewController: SurveyBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultsButton: UIButton!
    
    @IBAction func resultsButtonTapped(_ sender: AnyObject) {
        let mpvc = (parent) as! SurveyManagePageViewController
        let savedLists = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SurveyMatches") as! SurveyMatchesTableViewController
        mpvc.setViewControllers([savedLists], direction: .forward, animated: true, completion: nil)
        if let b = chosenBreed {
            savedLists.breed = b
        }
        savedLists.whichSeque = "results"
    }
    
    deinit {
        print ("SavedListsViewController deinit")
    }
    
    var whichSegue: String = ""
    var whichQuestion: Int = 0
    var whichSavedList: Int = 0
    var txtfld: UITextField = UITextField()
    var chosenBreed: Breed?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        whichSegueGlobal = ""
        SavedSearches.loadSearches(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(tableView.frame)
        if tableView.frame.origin.y == 20 {
            tableView.frame = tableView.frame.offsetBy(dx: 0, dy: 45)
        }
        resultsButton.twinkle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SavedSearches[section].SavedSearchDetails.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return SearchTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let valueView = ViewValue()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SurveySummaryTableViewCell
        
        cell.QuestionChoice?.font = UIFont.systemFont(ofSize: 14.0)
        cell.backgroundColor = lightBackground
        cell.QuestionChoice!.backgroundColor = UIColor.clear
        cell.QuestionChoice!.highlightedTextColor = darkTextColor
        cell.QuestionChoice!.textColor = textColor
        
        cell.QuestionChoice!.font = UIFont.boldSystemFont(ofSize: 14.0)
        
        let ss = SavedSearches[indexPath.section].SavedSearchDetails[indexPath.row]
        
        cell.QuestionChoice?.font = UIFont.systemFont(ofSize: 13.0)
        
        cell.QuestionChoice!.text = "\(ss.Question)   |"
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        valueView.valueView = cell.ValueView
        
        let answer = questionList.getAnswer(indexPath.row)
        
        if indexPath.row < 8 {
            var v = 0
            switch answer.Order {
            case 1:
                v = 0
            case 6:
                v = 1
            case 5:
                v = 2
            case 4:
                v = 3
            case 3:
                v = 4
            case 2:
                v = 5
            default:
                v = 0
            }
            print("i = \(indexPath.row) value = \(v)")
            valueView.statValue = Double(v)
        } else {
            print("i = \(indexPath.row) value = \(answer.Order - 1))")
            valueView.statValue = Double(answer.Order - 1)
        }

        cell.ValueView.layer.addSublayer(valueView)
        cell.ValueView.frame = CGRect(x: 0, y: 0, width: 300.0, height: cell.QuestionChoice!.frame.height)
        valueView.frame = CGRect(x: 0, y: 0, width: 300.0, height: cell.QuestionChoice!.frame.height)
        valueView.setNeedsDisplay()
        
        CATransaction.commit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let trackLayer = ViewTrackLayer()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! SurveySummaryHeaderTableViewCell2
        
        trackLayer.contentsScale = UIScreen.main.scale
        trackLayer.ticksSlider = cell.trackerView
        cell.trackerView.layer.addSublayer(trackLayer)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = CGRect(x: 0, y: 0, width: cell.trackerView.bounds.width, height: 30.0)
        trackLayer.setNeedsDisplay()
        
        CATransaction.commit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

class ViewValue: CALayer {
    var startColor: CGColor = UIColor.cyan.cgColor
    var endColor: CGColor = UIColor.blue.cgColor
    weak var valueView: UIView?
    var statValue = 0.0
    var maxValue = 5.0
    override func draw(in ctx: CGContext) {
        if let valueView = valueView {
            print("statValue = \(statValue)")
            let valueLayer = CAGradientLayer()
            
            let backgroundLayer = CALayer()
            backgroundLayer.backgroundColor = UIColor.white.cgColor
            backgroundLayer.frame = CGRect(x: 0, y: 19, width: bounds.maxX + 10, height: 10)
            valueView.layer.addSublayer(backgroundLayer)
            
            let statV = CGFloat((Double(bounds.maxX) / maxValue) * self.statValue)
            valueLayer.frame = CGRect(x: 0, y: 19, width: statV, height: 10)
            valueLayer.colors = [UIColor.cyan.cgColor, UIColor.blue.cgColor]
            valueLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            valueLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            valueView.layer.addSublayer(valueLayer)
            print("frame = \(valueLayer.frame)")
        }
    }
}

class ViewTrackLayer: CALayer {
    weak var ticksSlider: UIView?
    var trackHight: CGFloat = 10.0
    var trackColor: CGColor = UIColor.black.cgColor
    
    var minimumValue: Double = 0.0
    var maximumValue: Double = 5.0
    
    var tickWidth: CGFloat = 2.0
    var tickColor: CGColor = UIColor.black.cgColor
    var tickHight:CGFloat = 8.0
    
    override func draw(in ctx: CGContext) {
        if let slider = ticksSlider {
            // Path without ticks
            let trackPath = UIBezierPath(rect: CGRect(x: 0, y: bounds.height - 2.0, width: bounds.width, height: 2.0))
            // Fill the track
            ctx.setFillColor(trackColor)
            ctx.addPath(trackPath.cgPath)
            ctx.fillPath()
            
            let backgroundLayer = CALayer()
            backgroundLayer.backgroundColor = UIColor.clear.cgColor
            backgroundLayer.frame = CGRect(x: 0, y: 19, width: bounds.maxX + 10, height: 10)
            slider.layer.addSublayer(backgroundLayer)
            
            // Draw ticks
            for index in Int(minimumValue)...Int(maximumValue) {
                let delta = (slider.bounds.width / CGFloat(maximumValue))
                
                // Clip
                let tickPath = UIBezierPath(rect: CGRect(x: (CGFloat(index) * delta - 0.5 * tickWidth) - 5.0 , y: slider.bounds.height - tickHight, width: tickWidth, height: tickHight))
                
                // Fill the tick
                ctx.setFillColor(tickColor)
                ctx.addPath(tickPath.cgPath)
                ctx.fillPath()
            }
        }
    }
}
