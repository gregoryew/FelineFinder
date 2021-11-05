//
//  MainBreedCollectionViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/24/20.
//

import UIKit

class MainBreedCollectionViewController: ParentViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var BreedCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortMenu: UIButton!
    
    //var popMenu: PopMenuViewController? = nil
    
    var breedsLocal = [Breed]()
    var filteredBreeds: [Breed] = []
    var breedGroups: [String: [Breed]] = [:]
    var breedLetters = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        let layout = BreedCollectionView.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        DatabaseManager.sharedInstance.fetchBreedsFit { (breedsParam) -> Void in
            self.breedsLocal = breedsParam
            self.filteredBreeds = breedsParam
            DispatchQueue.main.async(execute: {
                self.setupIndex()
                                
                self.BreedCollectionView.reloadData()
                
                self.searchBar.delegate = self
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupIndex()
    }
    
    func scrollToIndex(index:Int) {
        if breedLetters.count > 0 {
            self.BreedCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: false)
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
        var c = 0
        if choosenBreedSortOption == .name {
            for breed in filteredBreeds {
                breedGroups[String(breed.BreedName.prefix(1)), default: []].append(breed)
            }
        } else {
            for breed in filteredBreeds {
                let breedLocal = breeds.filter({ breedParam in
                    return breedParam.BreedID == breed.BreedID
                })
                var category: match = .purrfect
                switch breedLocal[0].Percentage {
                case 0..<0.2: category = .bad
                case 0.2..<0.4: category = .poor
                case 0.4..<0.6: category = .maybe
                case 0.6..<0.8: category = .good
                case 0.8..<1: category = .great
                case 1: category = .purrfect
                default: break
                }
                c += 1
                print("\(c) \(category)")
                breedGroups[String(category.rawValue), default: []].append(breed)
            }
        }
        breedLetters = breedGroups.keys.sorted()
        DispatchQueue.main.async(execute: {
            self.BreedCollectionView.reloadData()
            if self.breedLetters.count > 0 {
                self.BreedCollectionView.scrollToItem(at: previouslySelectedBreed, at: .centeredVertically, animated: false)
            }
        })
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
        breed = self.breedGroups[breedLetters[indexPath.section]]![indexPath.item]
        updateFilterBreeds(breedsParam: [breed!])
        previouslySelectedBreed = indexPath
        present(breedDetail, animated: false, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        if searchText != "" {
            filteredBreeds = breedsLocal.filter { (breed: Breed) -> Bool in
                return breed.BreedName.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredBreeds = breedsLocal
        }
        
        setupIndex()
        
        self.BreedCollectionView.reloadData()
    }
}

extension MainBreedCollectionViewController {
    func popMenuDidSelectItem(index: Int) {
        var title: String = ""
        switch index {
        case 0:
            title = "Breed Name"
            choosenBreedSortOption = .name
        case 1:
            title = "Best Match"
            choosenBreedSortOption = .match
        default: break
        }
        sortMenu.setTitle("Sort By: \(title)", for: .normal)
        setupIndex()
        scrollToIndex(index: 0)
    }

    @IBAction func sortMenuTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
        
        let breedNamebutton = UIAlertAction(title: "Breed Name", style: .default, handler: { _ in
            self.popMenuDidSelectItem(index: 0)
        })
        actionSheetController.addAction(breedNamebutton)
        
        let bestMatchButton = UIAlertAction(title: "Best Match", style: .default, handler: { _ in
            self.popMenuDidSelectItem(index: 1)
        })
        actionSheetController.addAction(bestMatchButton)

        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = self.view
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
}
