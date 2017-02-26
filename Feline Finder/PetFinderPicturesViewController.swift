//
//  PetFinderPicturesViewController.swift
//  Cat Appz
//
//  Created by Gregory Williams on 8/20/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//
import UIKit
import Foundation
import TransitionTreasury
import TransitionAnimation

protocol SDECardSource{
    var cardCount: Int {get set}
    func cardImageAtIndex(_ index:Int) -> UIImage?
}

enum panScrollDirection{
    case up, down
}

class PetFinderPicturesViewController: UIViewController, CardContainerDataSource, NavgationTransitionable, KYCircularProgressDelegate {
    
    var petData: Pet = Pet(pID: "", n: "", b: [], m: false, a: "", s: "", s2: "", o: [""], d: "", m2: [], s3: "", z: "", dis: 0.0)
    var imageURLs:[String] = []
    var images: Dictionary<String, UIImage> = [:]
    
    @IBOutlet weak var circularProgress: KYCircularProgress!
    @IBOutlet weak var progressLabel: UILabel!
    
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    
    let container = UIView()
    let redSquare = UIImageView()
    let blueSquare = UIImageView()
    let outerRedSquare = UIView()
    let outerBlueSquare = UIView()
    let pageControl = UIPageControl()
    var currentIndex = 0
    var progress = 0.0
    var totalImages = 0.0
    var currentImage = 0.0
    
    //let imgDownArrow = UIImageView.init(image: UIImage(named: "downarrow"))
    let imgDownArrow = UIImageView()
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    @IBAction func doneTapped(_ sender: Any) {
        _ = navigationController?.tr_popViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.prompt = "Swipe down to see next up for previous"
        self.title = petData.name

        self.circularProgress.isHidden = false
        self.progressLabel.isHidden = true
        
        cardContainerView.clipsToBounds = false
        view.addSubview(cardContainerView)
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 3/4, constant: 0))
        cardContainerView.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .height, relatedBy: .equal, toItem: cardContainerView, attribute: .width, multiplier: 1, constant: 0))
        view.layoutIfNeeded()
        
        self.imageURLs = (self.petData.getAllImagesOfACertainSize("x"))
        totalImages = Double(self.imageURLs.count)
        currentImage = 0.0
        var errors = 0
        for url in self.imageURLs {
            let imgURL = URL(string: url)
            let request: URLRequest = URLRequest(url: imgURL!)
            //let mainQueue = NSOperationQueue.mainQueue()
            _ = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                self.currentImage += 1.0
                self.circularProgress.progress = self.currentImage / self.totalImages
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Update the cell
                    self.images[url] = image
                    if self.images.count + errors == self.imageURLs.count {
                    DispatchQueue.main.async(execute: {
                        //self.setupView()
                        self.circularProgress.isHidden = true
                        self.progressLabel.isHidden = true
                        self.view.addSubview(self.imgDownArrow)
                        let ypos = self.cardContainerView.bounds.origin.y + self.cardContainerView.frame.size.height + 200
                        self.imgDownArrow.frame = CGRect(x: self.cardContainerView.frame.center.x, y: ypos, width: 100, height: 100)
                        self.imgDownArrow.image = UIImage(named: "DownArrow")
                    self.cardContainerView.dataSource = self
                    })
                    }
                } else {
                    errors += 1
                }
            }).resume()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        circularProgress.delegate = self
        view.layoutIfNeeded()
    }
    
    let cardContainerView = UICardContainerView()
    
    //MARK: Card Container Data Source
    func numberOfCardsForCardContainerView(_ cardContainerView: UICardContainerView) -> Int{
        return imageURLs.count
    }
    
    func cardContainerView(_ cardContainerView: UICardContainerView, imageForCardAtIndex index: Int) -> UIImage?{
        return index < imageURLs.count ? images[imageURLs[index]] : nil
    }
    
    func cardIndexChanged(_ currentHeadCardIndex: Int) {
        if currentHeadCardIndex == 0 {
            imgDownArrow.image = UIImage(named: "DownArrow")
        } else if currentHeadCardIndex >= imageURLs.count - 1 {
            imgDownArrow.image = UIImage(named: "UpArrow")
        } else {
            imgDownArrow.image = UIImage(named: "DoubleArrow")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardContainerView.respondsToSizeChange()
    }

    func progressChanged(progress: Double, circularProgress: KYCircularProgress) {
        if circularProgress == self.circularProgress {
            //progressLabel.text = "\(Int(progress * 100.0))%"
        }
    }

}
