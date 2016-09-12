//
//  PetFinderPicturesViewController.swift
//  Cat Appz
//
//  Created by Gregory Williams on 8/20/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import Foundation

class PetFinderPicturesViewController: UIViewController {
    
    var petData: Pet = Pet(pID: "", n: "", b: [], m: false, a: "", s: "", s2: "", o: [""], d: "", lu: "", m2: [], s3: "", z: "", dis: 0.0)
    var breedName: String = ""
    var imageURLs:[String] = []
    var images: Dictionary<String, UIImage> = [:]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = petData.name
        self.imageURLs = (self.petData.getAllImagesOfACertainSize("x"))
        var errors = 0
        for url in self.imageURLs {
            let imgURL = NSURL(string: url)
            let request: NSURLRequest = NSURLRequest(URL: imgURL!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Update the cell
                    self.images[url] = image
                    if self.images.count + errors == self.imageURLs.count {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setupView()
                    })
                    }
                } else {
                    errors += 1
                }
            })
        }
    }
    
    func setupView() {
        swipeLeftRec.direction = .Left
        swipeLeftRec.addTarget(self, action: #selector(PetFinderPicturesViewController.swipeUp))
        swipeDownRec.direction = .Down
        swipeDownRec.addTarget(self, action: #selector(PetFinderPicturesViewController.swipeDown))
        swipeUpRec.direction = .Up
        swipeUpRec.addTarget(self, action: #selector(PetFinderPicturesViewController.swipeUp))
        swipeRightRec.direction = .Right
        swipeRightRec.addTarget(self, action: #selector(PetFinderPicturesViewController.swipeDown))
        
        container.addGestureRecognizer(swipeLeftRec)
        container.addGestureRecognizer(swipeRightRec)
        container.addGestureRecognizer(swipeUpRec)
        container.addGestureRecognizer(swipeDownRec)
        
        // set container frame and add to the screen
        self.container.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 20)
        self.view.addSubview(container)
        self.pageControl.frame = CGRectMake(0, self.view.bounds.height - 20, self.view.bounds.width, 20)
        self.pageControl.currentPage = 1
        self.pageControl.numberOfPages = self.imageURLs.count
        self.pageControl.backgroundColor = UIColor.blackColor()
        self.pageControl.tintColor = UIColor.lightGrayColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        self.view.addSubview(self.pageControl)
        
        // set background colors
        self.redSquare.backgroundColor = UIColor.blackColor()
        self.blueSquare.backgroundColor = UIColor.blackColor()
        self.outerRedSquare.backgroundColor = UIColor.blackColor()
        self.outerBlueSquare.backgroundColor = UIColor.blackColor()
        
        // set red square frame up
        // we want the blue square to have the same position as redSquare
        // so lets just reuse blueSquare.frame
        self.redSquare.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 20)
        self.blueSquare.frame = redSquare.frame
        self.outerRedSquare.frame = redSquare.frame
        self.outerBlueSquare.frame = redSquare.frame
        
        self.outerBlueSquare.addSubview(blueSquare)
        self.outerRedSquare.addSubview(redSquare)
        
        let i = images[imageURLs[0]]
        self.redSquare.image = i
        self.redSquare.frame = self.getActualSizeInPixels(i!)
        
        // for now just add the redSquare
        // we'll add blueSquare as part of the transition animation
        self.container.addSubview(self.redSquare)
    }
    
    func getActualSizeInPixels(i: UIImage) -> CGRect {
        let w = i.size.width * i.scale
        let h = i.size.height * i.scale
        let cw = self.container.frame.width
        let ch = self.container.frame.height
        let x = (cw / 2) - (w / 2)
        let y = (ch / 2) - (h / 2)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func swipeUp(){
        // create a 'tuple' (a pair or more of objects assigned to a single variable)
        if currentIndex + 1 == images.count { return }
        self.redSquare.image = images[imageURLs[currentIndex]]
        self.redSquare.frame = self.getActualSizeInPixels(images[imageURLs[currentIndex]]!)
        currentIndex += 1
        pageControl.currentPage = currentIndex
        self.blueSquare.image = images[imageURLs[currentIndex]]
        self.blueSquare.frame = self.getActualSizeInPixels(images[imageURLs[currentIndex]]!)
        let views = (frontView: self.outerRedSquare, backView: self.outerBlueSquare)
        
        // set a transition style
        let transitionOptions = UIViewAnimationOptions.TransitionCurlUp
        
        UIView.transitionWithView(self.container, duration: 1.0, options: transitionOptions, animations: {
            // remove the front object...
            views.frontView.removeFromSuperview()
            
            // ... and add the other object
            self.container.addSubview(views.backView)
            
            }, completion: { finished in
                // any code entered here will be applied
                // .once the animation has completed
        })
    }
    
    func swipeDown(){
        if currentIndex == 0 { return }
        self.redSquare.image = images[imageURLs[currentIndex]]
        self.redSquare.frame = self.getActualSizeInPixels(images[imageURLs[currentIndex]]!)
        self.blueSquare.image = images[imageURLs[currentIndex - 1]]
        self.blueSquare.frame = self.getActualSizeInPixels(images[imageURLs[currentIndex - 1]]!)
        currentIndex -= 1
        pageControl.currentPage = currentIndex
        // create a 'tuple' (a pair or more of objects assigned to a single variable)
        let views = (frontView: self.outerRedSquare, backView: self.outerBlueSquare)
        
        // set a transition style
        let transitionOptions = UIViewAnimationOptions.TransitionCurlDown
        
        UIView.transitionWithView(self.container, duration: 1.0, options: transitionOptions, animations: {
            // remove the front object...
            views.frontView.removeFromSuperview()
            
            // ... and add the other object
            self.container.addSubview(views.backView)
            
            }, completion: { finished in
                // any code entered here will be applied
                // .once the animation has completed
        })
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated:true)
    }
}