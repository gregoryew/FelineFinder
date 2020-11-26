//
//  MainBreedCollectionViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/24/20.
//

import UIKit
import BDKCollectionIndexView

class MainBreedCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var BreedCollectionView: UICollectionView!
    @IBOutlet weak var breedIndexView: BDKCollectionIndexView!

    var breeds = [Breed]()
    var breedGroups: [String: [Breed]] = [:]
    var breedLetters = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            DispatchQueue.main.async(execute: {
                self.setupIndex()
                let indexView = BDKCollectionIndexView(frame: self.breedIndexView.frame, indexTitles: nil)
                indexView!.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
                indexView!.addTarget(self, action: #selector(self.indexViewValueChanged), for: .valueChanged)
                self.view.addSubview(indexView!)
                self.view.bringSubviewToFront(indexView!)
                indexView!.indexTitles = self.breedLetters
                self.BreedCollectionView.reloadData()
            })
        }
    }
    
    func setupIndex() {
        breedGroups = [:]
        breedLetters = []
        for breed in breeds {
            breedGroups[String(breed.BreedName.prefix(1)), default: []].append(breed)
        }
        breedLetters = breedGroups.keys.sorted()
    }
    
    @objc func indexViewValueChanged(sender: BDKCollectionIndexView) {
        let path = NSIndexPath(item: 0, section: Int(sender.currentIndex))
        BreedCollectionView.scrollToItem(at: path as IndexPath, at: .top, animated: true)
        // If you're using a collection view, bump the y-offset by a certain number of points
        // because it won't otherwise account for any section headers you may have.
        BreedCollectionView.contentOffset = CGPoint(x: BreedCollectionView.contentOffset.x,
            y: BreedCollectionView.contentOffset.y - 45.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.breedGroups[breedLetters[section]]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as!
            MainBreedCollectionViewCell
        cell.configure(breed: self.breedGroups[breedLetters[indexPath.section]]![indexPath.item])
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return breedLetters.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       viewForSupplementaryElementOfKind kind: String,
                       at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "breedHeader", for: indexPath) as! BreedSectionHeaderCollectionReusableView

        headerView.configure(letter: breedLetters[indexPath.section])

        return headerView
   }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let breedDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "breedDetail") as! BreedDetailViewController
        breedDetail.modalPresentationStyle = .fullScreen
        breedDetail.breed = self.breedGroups[breedLetters[indexPath.section]]![indexPath.item]
        present(breedDetail, animated: false, completion: nil)
    }
}
