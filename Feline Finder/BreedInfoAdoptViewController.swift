//
//  AdoptableCatsTabViewController.swift
//  Feline Finder
//
//  Created by gregoryew1 on 6/26/17.
//  Copyright © 2017 Gregory Williams. All rights reserved.
//

import UIKit
import SwiftLocation
import CoreLocation

//let handlerDelay2 = 1.5

class BreedInfoAdoptViewController: ZoomAnimationViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout { //, NavgationTransitionable {
    
    var viewDidLayoutSubviewsForTheFirstTime = true
    
    deinit {
        print ("AdoptableCatsTabViewController deinit")
        NotificationCenter.default.removeObserver(observer)
        if (collectionView?.infiniteScrollingHasBeenSetup)! {
            collectionView?.infiniteScrollingHasBeenSetup = false
            collectionView?.removeObserver((collectionView?.infiniteScrollingView)!, forKeyPath: "contentOffset")
            collectionView?.removeObserver((collectionView?.infiniteScrollingView)!, forKeyPath: "contentSize")
            collectionView?.infiniteScrollingView.resetScrollViewContentInset()
            collectionView?.delegate = nil
            //collectionView?.infiniteScrollingView.isObserving = false
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pets: RescuePetList?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    var titles:[String] = []
    var totalRow = 0
    var times = 0
    var observer : Any!
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellSpacing = CGFloat(0) //Define the space between each cell
        let leftRightMargin = CGFloat(0) //If defined in Interface Builder for "Section Insets"
        var numColumns: CGFloat = 0
        if UIDevice().model.hasPrefix("iPad") {
            numColumns = CGFloat(5) //The total number of columns you want
        } else {
            numColumns = CGFloat(2)
        }
        
        let totalCellSpace = cellSpacing * (numColumns - 1)
        let screenWidth = UIScreen.main.bounds.width - 45
        let width = (screenWidth - leftRightMargin - totalCellSpace) / numColumns
        let height = CGFloat(205) //whatever height you want
        
        return CGSize(width: width, height: height);
    }
    
    func getZipCode() {
        let keyStore = NSUbiquitousKeyValueStore()
        zipCode = keyStore.string(forKey: "zipCode") ?? ""
        if zipCode != "" {
            self.setFilterDisplay()
            self.pets?.loading = true
            DownloadManager.loadPetList()
            self.setupReloadAndScroll()
            return
        }
        
        LocationManager2.sharedInstance.getCurrentReverseGeoCodedLocation { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
            if error != nil {
                self.askForZipCode()
                return
            }
            
            guard let _ = location else {
                return
            }
            
            zipCode = placemark?.postalCode ?? "19106"
            self.setFilterDisplay()
            self.pets?.loading = true
            DownloadManager.loadPetList()
            self.setupReloadAndScroll()
            print("Found \(placemark?.postalCode ?? "")")
        }
    }
    
    func askForZipCode() {
        let alert2 = UIAlertController(title: "Please Enter Zip Code", message: "Please enter a zip code for the area you want to search?", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert2.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (btn) in
            let textField = alert2.textFields![0] // Force unwrapping because we know it exists.
            zipCode = (textField.text)!
            let keyStore = NSUbiquitousKeyValueStore()
            keyStore.set(zipCode, forKey: "zipCode")
            if DatabaseManager.sharedInstance.validateZipCode(zipCode: zipCode) {
                self.pets?.loading = true
                self.setFilterDisplay()
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                DownloadManager.loadPetList()
                self.setupReloadAndScroll()
            } else {
                let alert3 = UIAlertController(title: "Error", message: "You have not allowed Feline Finder to know where you are located so it cannot find cats which are closest to you.  The zip code has been set to the middle of the US population.  Zip code 66952.  You can change it from the find screen.  You can allow the app to use location services again by fliping the switch for Feline Finder in the iOS app system preferences.", preferredStyle: .alert)
                alert3.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert3, animated: true, completion: nil)
                zipCode = "66952"
                self.pets?.loading = true
                self.setFilterDisplay()
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                DownloadManager.loadPetList()
                self.setupReloadAndScroll()
            }
        }))
        
        // 4. Present the alert.
        self.present(alert2, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        observer = nc.addObserver(forName:petsLoadedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.petsLoaded(notification: notification)
        }
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.topItem!.title = "Cats for Adoption"
            
            let searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 22 ))
            searchButton.setBackgroundImage(UIImage(named: "TopSearchIcon"), for: .normal)
            searchButton.addTarget(self, action: #selector(searchOptions(_:)), for: .touchUpInside)
            navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        }
        
        if (!Favorites.loaded) {Favorites.LoadFavorites(tv: nil)}
        
        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        } else {
            // Fallback on earlier versions
        }
        
        // Sticky Headers
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        
        pets = RescuePetList()
        
        navigationItem.title = "\(globalBreed!.BreedName)"

    
    }
    
    func petsLoaded(notification:Notification) -> Void {
        print("petLoaded notification")
        
        guard let userInfo = notification.userInfo,
            let p = userInfo["petList"] as? RescuePetList,
            let t = userInfo["titles"] as? [String] else {
                print("No userInfo found in notification")
                return
        }
        
        pets = p
        titles = t
        
        self.pets?.loading = false
        
        DispatchQueue.main.async { [unowned self] in
            self.collectionView?.reloadData()
        }
        
    }
    
    func setupReloadAndScroll() {
        // Pull to refresh
        /*
         collectionView.addPullToRefreshWithActionHandler {
         let delayTime = DispatchTime.now() + Double(Int64(handlerDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
         DispatchQueue.main.asyncAfter(deadline: delayTime) {
         self.collectionView.stopPullToRefresh()
         zipCodeGlobal = ""
         PetFinderBreeds[(globalBreed?.BreedName)!] = nil
         DownloadManager.loadPetList()
         }
         }
         collectionView.pullRefreshColor = UIColor.white
         */
        collectionView.addInfiniteScrollingWithActionHandler {[weak self] () -> Void in
            
            //let strongSelf = self
            
            let delayTime = DispatchTime.now() + Double(Int64(handlerDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                //withExtendedLifetime(self) {
                if let cv = self?.collectionView {
                    cv.infiniteScrollingView.stopAnimating()
                }
                zipCodeGlobal = ""
                DownloadManager.loadPetList(more: true)
            }
            self?.collectionView.infiniteScrollingView.color = UIColor.white
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        setFilterDisplay()
        if viewPopped {
            PetFinderBreeds[(globalBreed?.BreedName)!] = nil
            zipCodeGlobal = ""
            self.pets?.loading = true
            collectionView?.reloadData()
            DownloadManager.loadPetList()
            viewPopped = false
        }
        DispatchQueue.main.async { [unowned self] in
            self.collectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterOptions.reset()
        if zipCode == "" {
            getZipCode()
        } else {
            setFilterDisplay()
            self.pets?.loading = true
            DownloadManager.loadPetList()
            setupReloadAndScroll()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFilterDisplay() {
        if let navigationBar = self.navigationController?.navigationBar {
            let filter = "Zip:\(zipCode)"
            navigationBar.topItem!.prompt = filter
        }
    }
    
    func Refresh() {
        zipCodeGlobal = ""
        PetFinderBreeds[(globalBreed?.BreedName)!] = nil
        self.pets?.loading = true
        DownloadManager.loadPetList()
    }
    
    @IBAction func unwindToPetFinderList(_ sender: UIStoryboardSegue)
    {
        //let sourceViewController = sender.sourceViewController
        setFilterDisplay()
        DownloadManager.loadPetList()
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    func totalRows(_ p: PetList) -> Int {
        var total = 0
        var i = 0
        if totalRow == -1 {
            while i < titles.count {
                total += self.pets!.distances[titles[i]]!.count
                i += 1
            }
            totalRow = total
        }
        return totalRow
    }
    
}

// MARK: UICollectionViewDataSource
extension BreedInfoAdoptViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var t = 0
        if let p = self.pets {
            if p.loading || self.pets!.distances.count == 0 {
                t = 1
            }
            else {
                t = self.titles.count
            }
        }
        return t
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var c = 0
        
        if let p = self.pets {
            if p.loading || self.pets!.distances.count == 0 {
                c = 0
            } else {
                let sectionTitle = titles[section]
                c = self.pets!.distances[sectionTitle]!.count
            }
        }
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        let FelineDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdoptableCatsDetail") as! CatDetailViewController
        
        FelineDetail.pet = petData
        FelineDetail.petID = petData.petID
        FelineDetail.petName = petData.name
        FelineDetail.breedName = globalBreed!.BreedName

        present(FelineDetail, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! BreedinfoSectionHeaderCollectionReusableView
        
        if self.pets?.loading == false && titles.count == 0 {
            sectionHeaderView.SectionHeaderLabel.isUserInteractionEnabled = true
            sectionHeaderView.SectionHeaderLabel.textColor = UIColor.red
            sectionHeaderView.SectionHeaderLabel.text = "Currently not available but tap for options."
            let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(gesture:)))
            tap.numberOfTapsRequired = 1
            sectionHeaderView.SectionHeaderLabel.addGestureRecognizer(tap)
            sectionHeaderView.SectionHeaderLabel.tag = indexPath.row
            return sectionHeaderView
        } else if self.pets?.loading == true {
            sectionHeaderView.SectionHeaderLabel.textColor = UIColor.blue
            sectionHeaderView.SectionHeaderLabel.text = "Please wait while the cats are loading..."
            return sectionHeaderView
        }
        
        sectionHeaderView.SectionHeaderLabel.text = titles[indexPath.section]
        
        return sectionHeaderView
    }
    
    @objc func labelTapped(gesture: UITapGestureRecognizer) {
        //If host is not reachable, display a UIAlertController informing the user
        let alert = UIAlertController(title: "Search Daily Until Found?", message: "Would you like to setup a search for this breed until one is availabe?  I will search daily and report back when I find one?", preferredStyle: UIAlertController.Style.alert)
        
        //Add alert action
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in self.searchOptions(self)}))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))

        //Present alert
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func searchOptions(_ sender: Any) {
        let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        PetFinderFind.breed = globalBreed
        
        //var breedsList: Dictionary<String, [Breed]> = [:]
        //var breedChoices: [(displayName: String?, search: String?, value: Int?)] = []
        //breedChoices.append((displayName: globalBreed?.BreedName, search: globalBreed?.RescueBreedID, value: 0))
        
        //filterOptions.load(nil)
        var filter = filterOptions.filteringOptions
        filter = filterOptions.filteringOptions.filter { (value) -> Bool in
            value.fieldName == "animalPrimaryBreedID"
        }
        let breed = filter[0].options.filter { listOption -> Bool in
            listOption.displayName == globalBreed!.BreedName
        }
        
        filterOptions.setFilter(name: "animalPrimaryBreedID", value: [Int(breed[0].value!)])
        
        PetFinderFind.modalPresentationStyle = .custom
        PetFinderFind.transitioningDelegate = self
        present(PetFinderFind, animated: true, completion: nil)
        
        //navigationController?.tr_pushViewController(PetFinderFind, method: DemoTransition.Flip)
    }
    
    func setupSearch() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BreedInfoCollectionViewCell
        
        if titles.count == 0 || indexPath.section >= titles.count {
            return cell
        }
        
        let d = self.pets!.distances[titles[indexPath.section]]
        
        if d == nil {
            return cell
        }
        
        if (d?.count)! == 0 || indexPath.row >= (d?.count)! {
            return cell
        }
        
        let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        
        if petData.videos.count > 0 {
            cell.Video.isHidden = false
            cell.Video.image = UIImage(named: "VideoAvailableIcon")
            print("\(cell.Video.frame)")
            print("\(String(describing: cell.Video.image))")
        } else {
            cell.Video.isHidden = true
        }
        
        if Favorites.isFavorite(petData.petID, dataSource: .RescueGroup) {
            cell.Favorite.image = UIImage(named: "AdoptHeart")
        } else {
            cell.Favorite.image = UIImage(named: "AdoptHeartEmpty")
        }
        
        let urlString: String? = petData.getImage(1, size: "pnt")
        
        cell.BreedName.text = petData.breeds.first
        cell.City.text = petData.location
        cell.CatNameLabel.text = petData.name
        cell.Status.text = petData.status
        
        if urlString == "" {
            cell.CatImager?.backgroundColor = getRandomColor()
            cell.CatImager?.image = UIImage(named: "NoCatImage")
            return cell
        }
        
        let imgURL = URL(string: urlString!)
        cell.CatImager.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"))
        
        return cell
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}

