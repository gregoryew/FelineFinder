//
//  PictureMasterViewController.swift
//  Character Collector
/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Foundation
import TransitionTreasury
import TransitionAnimation

class PictureMasterViewController: UICollectionViewController, NavgationTransitionable {
  
    var petData: Pet = Pet(pID: "", n: "", b: [], m: false, a: "", s: "", s2: "", o: [""], d: "", m2: [], s3: "", z: "", dis: 0.0, adoptionFee: "", location: "")
    var imageURLs:[picture] = []
  
  var currentCard: Int = 0
    
   weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.imageURLs = (self.petData.getAllImagesObjectsOfACertainSize("x"))
    
    navigationController!.isToolbarHidden = true
    
    // Refresh Control
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(PictureMasterViewController.refreshControlDidFire), for: .valueChanged)
    if #available(iOS 10.0, *) {
        collectionView?.refreshControl = refreshControl
    } else {
        // Fallback on earlier versions
    }
    
    // Initial Flow Layout Setup
    let layout = collectionViewLayout as! CharacterFlowLayout
    layout.estimatedItemSize = CGSize(width: 200.0 * layout.standardItemScale, 
                                      height: 300.0 * layout.standardItemScale)
    
    layout.minimumLineSpacing = -(layout.itemSize.height * 0.5)
    
  }
  
  @objc func refreshControlDidFire() {
    collectionView?.reloadData()
    if #available(iOS 10.0, *) {
        collectionView?.refreshControl?.endRefreshing()
    } else {
        // Fallback on earlier versions
    }
  }

override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)  -> Int
    {
        return imageURLs.count //charactersData.count
    }
    
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatImageCell", for: indexPath) as! CatPictureCollectionViewCell
        
        // Configure the cell
        let img = URL(string: imageURLs[indexPath.item].URL)
        cell.catImage.sd_setImage(with: img, placeholderImage: UIImage(named: "NoCatImage"))
        cell.sizeThatFits(CGSize(width: imageURLs[indexPath.item].width, height: imageURLs[indexPath.item].height))
    
        return cell
    }

override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView?.collectionViewLayout as! CharacterFlowLayout
        
        let cardSize = layout.itemSize.height + layout.minimumLineSpacing
        let offset = scrollView.contentOffset.y
        
        currentCard = Int(floor((offset - cardSize / 2) / cardSize) + 1)
    }

}
