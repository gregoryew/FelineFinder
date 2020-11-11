//
//  FitQuestionSliderTableViewCell.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/18/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit
import Charts

extension UIResponder {
  
  func getOwningViewController() -> UIViewController? {
    var nextResponser = self
    while let next = nextResponser.next {
      nextResponser = next
      if let viewController = nextResponser as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}

var breedNames = [String]()

class FitQuestionSliderTableViewCell: UITableViewCell, ChartViewDelegate {

    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var HelpButton: UIButton!
    @IBOutlet weak var AnswerSlider: UISlider!
    
    var priorValue: Int = -1
    
    var delegate: calcStats?
    var question: Question?
    var breedPositions = [Int]()
    
    @IBAction func helpTapped(_ sender: Any) {
        let fitDialogVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FitDialog") as! FitDialogViewController
        fitDialogVC.modalPresentationStyle = .formSheet
        if let viewController = self.getOwningViewController() {
            fitDialogVC.titleString = question?.Name ?? ""
            fitDialogVC.message = question?.Description ?? ""
            fitDialogVC.image = question?.ImageName ?? ""
            viewController.present(fitDialogVC, animated: false, completion: nil)
        }
    }
    
    @IBAction func answerChanged(_ sender: Any) {
        var choice: Int = 0
        switch (AnswerSlider.value) {
        case 0.0..<0.01: choice = 0
        case 0.01...0.2: choice = 1
        case 0.21...0.4: choice = 2
        case 0.41...0.6: choice = 3
        case 0.61...0.8: choice = 4
        default: choice = 5
        }
        AnswerSlider.value = Float(Double(choice) * 0.2)
        if priorValue == choice {return}
        priorValue = choice
        delegate?.answerChanged(question: tag, answer: choice)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        delegate?.scrollBreeds(index: breedPositions[Int(entry.x) - 1])
    }
    */
    
    func configure(question: Question, answer: Float, breedEntries: [BarChartDataEntry], breedNamesParam: [String], breedPositionParams: [Int]) {
        if breedEntries.count > 0 {
            contentView.viewWithTag(-1)?.removeFromSuperview()
            let BreedHorizontalChart = HorizontalBarChartView()
            BreedHorizontalChart.tag = -1
            BreedHorizontalChart.frame = CGRect(x: 15, y: 78, width: contentView.frame.width - 25, height: CGFloat(breedNamesParam.count * 45))
            contentView.addSubview(BreedHorizontalChart)
            BreedHorizontalChart.delegate = self
            BreedHorizontalChart.legend.enabled = false
            BreedHorizontalChart.xAxis.labelPosition = .bottom
            breedNames = breedNamesParam
            
            let xAxis = BreedHorizontalChart.xAxis
            xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
            xAxis.centerAxisLabelsEnabled = false
            xAxis.valueFormatter = BreedsValueFormatter(chart: BreedHorizontalChart)
            xAxis.setLabelCount(breedNames.count, force: false)
            xAxis.axisMinimum = 0
            xAxis.axisMaximum = Double(breedNames.count)
            xAxis.drawGridLinesEnabled = false
            xAxis.labelPosition = .bottomInside
            xAxis.enabled = true
            
            let rightAxis = BreedHorizontalChart.rightAxis
            rightAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
            rightAxis.granularity = 1
            rightAxis.centerAxisLabelsEnabled = true
            rightAxis.valueFormatter = TraitValueFormatter(chart: BreedHorizontalChart)
            rightAxis.setLabelCount(6, force: false)
            rightAxis.axisMinimum = 0
            rightAxis.axisMaximum = 5

            let yAxis = BreedHorizontalChart.leftAxis
            yAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
            yAxis.granularity = 1
            yAxis.centerAxisLabelsEnabled = true
            yAxis.valueFormatter = TraitValueFormatter(chart: BreedHorizontalChart)
            yAxis.setLabelCount(6, force: false)
            yAxis.axisMinimum = 0
            yAxis.axisMaximum = 5
            
            let set = BarChartDataSet(entries: breedEntries)
            set.colors = ChartColorTemplates.colorful()
            set.drawValuesEnabled = false
            let data = BarChartData(dataSet: set)
            BreedHorizontalChart.data = data
            BreedHorizontalChart.notifyDataSetChanged()
            BreedHorizontalChart.isUserInteractionEnabled = false
            BreedHorizontalChart.setScaleEnabled(false)
            BreedHorizontalChart.reloadInputViews()
        }
        
        selectionStyle = .none
        
        breedPositions = breedPositionParams
        
        QuestionLabel.text = question.Name
        
        var choice: Int = 0
        switch (answer) {
        case 0.0..<0.01: choice = 0
        case 0.01...0.2: choice = 1
        case 0.21...0.4: choice = 2
        case 0.41...0.6: choice = 3
        case 0.61...0.8: choice = 4
        default: choice = 5
        }
        AnswerSlider.value = Float(Double(choice) * 0.2)
        self.question = question
    }
}

class ChartValueFormatter: NSObject, IValueFormatter {
    fileprivate var numberFormatter: NumberFormatter?

    convenience init(numberFormatter: NumberFormatter) {
        self.init()
        self.numberFormatter = numberFormatter
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let numberFormatter = numberFormatter
            else {
                return ""
        }
        return numberFormatter.string(for: value)!
    }
}

/// An interface for providing custom axis Strings.
@objc(ChartAxisValueFormatter)
public protocol AxisValueFormatter: class
{
    
    /// Called when a value from an axis is formatted before being drawn.
    ///
    /// For performance reasons, avoid excessive calculations and memory allocations inside this method.
    ///
    /// - Parameters:
    ///   - value:           the value that is currently being drawn
    ///   - axis:            the axis that the value belongs to
    /// - Returns: The customized label that is drawn on the x-axis.
    func stringForValue(_ value: Double,
                        axis: AxisBase?) -> String
    
}

public class IntAxisValueFormatter: NSObject, IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(value))"
    }
}

public class TraitValueFormatter: NSObject, IAxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    let traitValues = ["Any", "Low", "Low-Med", "Med", "Med-Hi", "High"]
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard value >= 0 && Int(value) < traitValues.count else {return ""}
        return traitValues[Int(value)]
    }
}

public class BreedsValueFormatter: NSObject, IAxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard value >= 0 && Int(value) < breedNames.count else {return ""}
        return breedNames[Int(value)]
    }
}
