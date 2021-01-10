//
//  MainBreedCollectionViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/24/20.
//

import UIKit
import BDKCollectionIndexView
import PopMenu

class MainBreedCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var BreedCollectionView: UICollectionView!
    @IBOutlet weak var breedIndexView: BDKCollectionIndexView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortMenu: UIButton!
    
    var popMenu: PopMenuViewController? = nil
    
    var breeds = [Breed]()
    var filteredBreeds: [Breed] = []
    var breedGroups: [String: [Breed]] = [:]
    var breedLetters = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            self.filteredBreeds = breeds
            DispatchQueue.main.async(execute: {
                self.setupIndex()
                let indexView = BDKCollectionIndexView(frame: self.breedIndexView.frame, indexTitles: nil)
                indexView!.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
                indexView!.addTarget(self, action: #selector(self.indexViewValueChanged), for: .valueChanged)
                self.view.addSubview(indexView!)
                self.view.bringSubviewToFront(indexView!)
                indexView!.indexTitles = self.breedLetters
                                
                self.BreedCollectionView.reloadData()
                
                self.searchBar.delegate = self
            })
        }
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as?
            MainBreedCollectionViewCell {
            guard cell.Border.frame != CGRect.zero else {return CGSize.zero}
            return cell.Border.frame.inset(by: UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)).size
        }
        
        return CGSize.zero
    }
    */
    
    func setupIndex() {
        breedGroups = [:]
        breedLetters = []
        for breed in filteredBreeds {
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        if searchText != "" {
            filteredBreeds = breeds.filter { (breed: Breed) -> Bool in
                return breed.BreedName.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredBreeds = breeds
        }
        
        setupIndex()
        
        self.BreedCollectionView.reloadData()
    }
}

extension MainBreedCollectionViewController: PopMenuViewControllerDelegate {
    func popMenuCustomSize() -> PopMenuViewController {
        let action1 = PopMenuDefaultAction(title: "Breed Name", color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        let action2 = PopMenuDefaultAction(title: "Best Match", color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))

        let actions = [
            action1,
            action2
        ]
        
        let popMenu = PopMenuViewController(actions: actions)
        
        popMenu.appearance.popMenuColor.backgroundColor = .solid(fill: .white)
        
        return popMenu
    }

    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        sortMenu.setTitle("Sort By: " + popMenuViewController.actions[index].title!, for: .normal)
    }

    @IBAction func sortMenuTapped(_ sender: Any) {
        popMenu = popMenuCustomSize()
        popMenu?.shouldDismissOnSelection = true
        popMenu?.delegate = self
        var origin = sortMenu.frame.origin
        origin.x = (sortMenu.frame.origin.x + sortMenu.frame.width) -  (popMenu?.contentFrame.width)!
        origin.y = sortMenu.frame.origin.y - (popMenu?.contentFrame.height ?? sortMenu.frame.origin.y)
        popMenu?.view.frame.origin = origin
        if let popMenuViewController = popMenu {
            present(popMenuViewController, animated: true, completion: nil)
        }
    }
}
