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

class PetFinderPicturesViewController: UIViewController, NavgationTransitionable, CardContainerDataSource, KYCircularProgressDelegate, ModalTransitionDelegate {
    
    var petData: Pet = Pet(pID: "", n: "", b: [], m: false, a: "", s: "", s2: "", o: [""], d: "", m2: [], s3: "", z: "", dis: 0.0, adoptionFee: "", location: "")
    var imageURLs:[picture] = []
    var images: Dictionary<String, UIImage> = [:]
    
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var circularProgress: KYCircularProgress!
    
    weak var tr_presentTransition: TRViewControllerTransitionDelegate?
    weak var modalDelegate: ModalViewControllerDelegate?
    
    var cardContainerView: UICardContainerView? = UICardContainerView()

    var currrentIndex = 0
    var progress = 0.0
    var totalImages = 0.0
    var currentImage = 0.0
    
    //let imgDownArrow = UIImageView.init(image: UIImage(named: "downarrow"))
    //var imgDownArrow: UIImageView? = UIImageView()
    
    let lblInstructions = UILabel()
    
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    deinit {
        print ("PetFinderPicturesViewController DEINIT")
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        //imgDownArrow = nil
        //lblInstructions = nil
        circularProgress.delegate = nil
        cardContainerView?.dataSource = nil
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.prompt = "Swipe down to see next up for previous"
        self.title = petData.name

        self.circularProgress.isHidden = false
        self.progressLabel.isHidden = false
        self.circularProgress.delegate = self
        
        cardContainerView?.clipsToBounds = false
        view.addSubview(cardContainerView!)
        view.addConstraint(NSLayoutConstraint(item: cardContainerView as Any, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cardContainerView as Any, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cardContainerView as Any, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 3/4, constant: 0))
        cardContainerView?.addConstraint(NSLayoutConstraint(item: cardContainerView as Any, attribute: .height, relatedBy: .equal, toItem: cardContainerView, attribute: .width, multiplier: 1, constant: 0))
        view.layoutIfNeeded()
        
        self.imageURLs = (self.petData.getAllImagesObjectsOfACertainSize("x"))
        totalImages = Double(self.imageURLs.count)
        currentImage = 0.0
        var errors = 0
        for url in self.imageURLs {
            let imgURL = URL(string: url.URL)
            if let urlImg = imgURL {
                let request: URLRequest = URLRequest(url: urlImg)
                //let mainQueue = NSOperationQueue.mainQueue()
                URLSession.shared.dataTask(with: request, completionHandler: {[unowned self] data, response, error in
                    self.currentImage += 1.0
                    self.circularProgress.progress = self.currentImage / self.totalImages
                    _ = Int((self.currentImage / self.totalImages) * 100.0)
                    //self.progressLabel.text = "\(p)%"
                    if error == nil {
                        // Convert the downloaded data in to a UIImage object
                        let image = UIImage(data: data!)
                        // Update the cell
                        self.images[url.URL] = image
                        if self.images.count + errors == self.imageURLs.count {
                            DispatchQueue.main.async(execute: {
                                //self.setupView()
                                self.circularProgress.isHidden = true
                                self.progressLabel.isHidden = true
                                if self.images.count > 1 {
                                    self.view.addSubview(self.lblInstructions)
                                    self.lblInstructions.textColor = UIColor.white
                                    self.lblInstructions.font = UIFont(name: "Helvetica", size: 12)
                                    self.lblInstructions.text = "Drag down image for next one"
                                    self.lblInstructions.textAlignment = NSTextAlignment.center
                                    let ypos = (self.cardContainerView?.bounds.origin.y)! + (self.cardContainerView?.frame.size.height)! + 200
                                    self.lblInstructions.frame = CGRect(x: ((self.view.frame.center.x) / 2), y: ypos, width: 300, height: 100)
                                    self.lblInstructions.center.x = self.view.frame.center.x
                                }
                                self.cardContainerView?.dataSource = self
                            })
                        }
                    } else {
                        errors += 1
                    }
                }).resume()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        circularProgress.delegate = self
        view.layoutIfNeeded()
    }
    
    //MARK: Card Container Data Source
    func numberOfCardsForCardContainerView(_ cardContainerView: UICardContainerView) -> Int{
        return imageURLs.count
    }
    
    func cardContainerView(_ cardContainerView: UICardContainerView, imageForCardAtIndex index: Int) -> UIImage?{
        return index < imageURLs.count ? images[imageURLs[index].URL] : nil
    }
    
    func cardIndexChanged(_ currentHeadCardIndex: Int) {
        if currentHeadCardIndex == 0 {
            lblInstructions.text = "Drag down for next image"
        } else if currentHeadCardIndex >= imageURLs.count - 1 {
            lblInstructions.text = "Drag up for previous image"
        } else {
            lblInstructions.text = "Drag up or down for images"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardContainerView!.contentMode = .scaleAspectFit
        cardContainerView?.respondsToSizeChange()
    }

    func progressChanged(progress: Double, circularProgress: KYCircularProgress) {
        //if circularProgress == self.circularProgress {
        DispatchQueue.main.async {
            let p = Int(progress * 100.0)
            self.progressLabel.text = "\(p)%"
            print("Progress = \(String(describing: self.progressLabel.text))")
            self.progressLabel.setNeedsDisplay()
        }
        //}
    }

}
