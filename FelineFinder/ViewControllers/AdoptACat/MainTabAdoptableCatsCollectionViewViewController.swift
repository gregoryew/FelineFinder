//
//  MainTabAdoptableCatsTableViewViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit
import CMMapLauncher
import PopMenu

var selectedImages: [Int] = []

var selectedImage: UIImageView!

class MainTabAdoptableCatsCollectionViewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, AlertDisplayer {

    @IBOutlet weak var SortMenu: UILabel!
    @IBOutlet weak var SortAscendingButton: UIButton!
    @IBOutlet weak var SortDescendingButton: UIButton!
    @IBOutlet weak var FilterButton: UIButton!
    
    @IBOutlet weak var AdoptableCatCollectionView: UICollectionView!
    
    private let refreshControl = UIRefreshControl()
    
    var pets: RescuePetsAPI5?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    var currentLocation : CLLocation!
    var locationManager: CLLocationManager? = CLLocationManager()
    
    var tempBreedName = ""
    var tempTitleLabel = ""
    
    var titles:[String] = []
    var totalRow = 0
    var times = 0
    var observer : Any!
    var observer2: Any!
    var observer3: Any!
    
    var totalRows = 0
    
    let transition = PopAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            AdoptableCatCollectionView.refreshControl = refreshControl
        } else {
            AdoptableCatCollectionView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshPetData(_:)), for: .valueChanged)
        
        let nc = NotificationCenter.default
        
        observer = nc.addObserver(forName:petsLoadedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.petsLoaded(notification: notification)
        }
                
        observer2 = nc.addObserver(forName:filterReturned, object:nil, queue:nil) { [weak self] notification in
            self?.retrieveData()
        }
        
        observer3 = nc.addObserver(forName:petsFailedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.petsFailed(notification: notification)
        }
        
        AdoptableCatCollectionView.isPrefetchingEnabled = true
        AdoptableCatCollectionView.delegate = self
        AdoptableCatCollectionView.prefetchDataSource = self
        
        let layout = PinterestLayout()
        layout.delegate = self
        self.AdoptableCatCollectionView.collectionViewLayout = layout
        
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
         
        pets = RescuePetsAPI5()
    }
    
    @objc private func refreshPetData(_ sender: Any) {
        PetFinderBreeds.removeValue(forKey: globalBreed!.BreedName)
        DownloadManager.loadPetList(reset: true)
    }
    
    func getZipCode() {
        let keyStore = NSUbiquitousKeyValueStore()
        zipCode = keyStore.string(forKey: "zipCode") ?? ""
        if zipCode != "" {
            self.pets?.loading = true
            DownloadManager.loadPetList(reset: true)
            return
        }
        
        LocationManager2.sharedInstance.getCurrentReverseGeoCodedLocation { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
            if error != nil {
                self.askForZipCode()
                return
            }
            guard location != nil else {
                return
            }
            
            zipCode = placemark?.postalCode ?? "19106"
            DownloadManager.loadPetList(reset: true)
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
            if DatabaseManager.sharedInstance.validateZipCode(zipCode: zipCode) {
                let keyStore = NSUbiquitousKeyValueStore()
                keyStore.set(zipCode, forKey: "zipCode")
                self.pets?.loading = true
                //self.setFilterDisplay()
                DispatchQueue.main.async {
                    self.AdoptableCatCollectionView.reloadData()
                }
                DownloadManager.loadPetList(reset: true)
                //self.setupReloadAndScroll()
            } else {
                let alert3 = UIAlertController(title: "Error", message: "You have not allowed Feline Finder to know where you are located so it cannot find cats which are closest to you.  The zip code has been set to the middle of the US population.  Zip code 66952.  You can change it from the find screen.  You can allow the app to use location services again by fliping the switch for Feline Finder in the iOS app system preferences.", preferredStyle: .alert)
                alert3.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert3, animated: true, completion: nil)
                zipCode = "66952"
                self.pets?.loading = true
                DispatchQueue.main.async {
                    self.AdoptableCatCollectionView.reloadData()
                }
                DownloadManager.loadPetList(reset: true)
            }
        }))
        
        // 4. Present the alert.
        self.present(alert2, animated: true, completion: nil)
    }
    
    func petsFailed(notification: Notification) -> Void {
        guard let userInfo = notification.userInfo,
              let reason = userInfo["error"] as? String
        else {
                print("No userInfo found in notification")
                return
        }

        DispatchQueue.main.async { [unowned self] in
            self.refreshControl.endRefreshing()
            let title = "Warning"
            let action = UIAlertAction(title: "OK", style: .default)
            displayAlert(with: title , message: reason, actions: [action])
            isFetchInProgress = false
        }
    }
        
    func petsLoaded(notification:Notification) -> Void {
        print("petLoaded notification")
        
        guard let userInfo = notification.userInfo,
              let p = userInfo["petList"] as? RescuePetsAPI5
        else {
                print("No userInfo found in notification")
                return
        }
        
        pets = p

        self.pets?.loading = false
        
        guard let newIndexPathsToReload = userInfo["newIndexPathsToReload"] as? [IndexPath] else {
          DispatchQueue.main.async { [unowned self] in
            totalRows = pets?.foundRows ?? 0
            self.AdoptableCatCollectionView.reloadData()
            selectedImages = [Int](repeating: 0, count: totalRows)
            isFetchInProgress = false
            self.refreshControl.endRefreshing()
          }
          return
        }
        
        DispatchQueue.main.async { [unowned self] in
            let indexPathsForVisibleRows = AdoptableCatCollectionView.indexPathsForVisibleItems
            let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(newIndexPathsToReload)
            let indexPathsToReload = Array(indexPathsIntersection)
            self.AdoptableCatCollectionView.reloadItems(at: indexPathsToReload)
            isFetchInProgress = false
            self.refreshControl.endRefreshing()
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let breed: Breed = Breed(id: 0, name: ALL_BREEDS, url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
        globalBreed = breed
        if zipCode == "" {
            getZipCode()
        } else {
            self.pets?.loading = true
            DownloadManager.loadPetList(reset: true)
        }
        Favorites.LoadFavorites(tv: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Favorites.storeIDs()
    }
    
    @objc func retrieveData() {
        if viewPopped {
            self.pets?.dateCreated = INITIAL_DATE
            DownloadManager.loadPetList(reset: true)
            viewPopped = false
        }
        DispatchQueue.main.async { [unowned self] in
            self.AdoptableCatCollectionView.reloadData()
            if totalRows > 0 {self.AdoptableCatCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)}
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func Refresh() {
        self.pets?.loading = true
        DownloadManager.loadPetList()
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
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! MainTabAdoptableCatsCollectionViewCell
        
        selectedImage = UIImageView(frame: cell.frame)
        selectedImage.image = cell.photo.image
        
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdoptDetail") as! MainTabAdoptableCatsDetailViewController

        details.pet = self.pets!.Pets[indexPath.item]
        
        details.modalPresentationStyle = .overFullScreen
        
        details.transitioningDelegate = self
        
        present(details, animated: true, completion: nil)

    }

    @IBAction func sortMenuTapped(_ sender: Any) {
/*
        func presentMenu() {
            let menuViewController = PopMenuViewController(actions: [
                PopMenuDefaultAction(title: "Best Matches", image: UIImage(named: "sortiing-reversed-numerical")),
                PopMenuDefaultAction(title: "Alphabetical", image: UIImage(named: "sorting-alphabetical"))])
            present(menuViewController, animated: true, completion: nil)
        }
*/
    }
    
    @IBAction func SortAscendingTapped(_ sender: Any) {
    }
    
    @IBAction func SortDescendingTapped(_ sender: Any) {
    }

    @IBAction func FilterButtonTapped(_ sender: Any) {
        let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        PetFinderFind.breed = globalBreed
        self.present(PetFinderFind, animated: true, completion: nil)
    }
}

extension MainTabAdoptableCatsCollectionViewViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            DownloadManager.loadPetList(reset: false)
        }
    }
  
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        DispatchQueue.main.async { [unowned self] in
 
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            AdoptableCatCollectionView.isHidden = false
            AdoptableCatCollectionView.reloadData()
            return
        }
        let indexPathsForVisibleRows = AdoptableCatCollectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(newIndexPathsToReload)
        let indexPathsToReload = Array(indexPathsIntersection)
            AdoptableCatCollectionView.reloadItems(at: indexPathsToReload)
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        if isFetchInProgress {return false}
      if indexPath.row >= pets!.Pets.count {
          print ("isLoadingCell row = \(indexPath.row) count = \(pets!.Pets.count)")
          DownloadManager.loadPetList(reset: false)
      } else {
          print ("NOT isLoadingCell row = \(indexPath.row) count = \(pets!.Pets.count)")
      }
      return indexPath.row >= pets!.Pets.count
    }
}

extension MainTabAdoptableCatsCollectionViewViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.originFrame = selectedImage.frame

    transition.presenting = true
    selectedImage!.isHidden = false

    return transition
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.presenting = false
    return transition
  }
}

extension MainTabAdoptableCatsCollectionViewViewController {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = AdoptableCatCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "emptyCell", for: indexPath) as? EmptyTableViewCell
        if (isFetchInProgress == false) {
            if totalRows == 0 {
                sectionHeader?.MessageButton.setTitle("Sorry nothing found.  I can search once a day for it if you tap here.", for: .normal)
            } else if pets!.Pets.count == indexPath.row + 1 {
                sectionHeader?.MessageButton.setTitle("End of Results.  If you didn't find what you want tap here.", for: .normal)
            }
        } else if (isFetchInProgress == true) {
            sectionHeader?.MessageButton.setTitle( "Please Wait While Cats Are Loading...", for: .normal)
        }
        return sectionHeader ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = AdoptableCatCollectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! MainTabAdoptableCatsCollectionViewCell
        if isLoadingCell(for: indexPath) {
            cell.configure(pd: nil)
        } else {
            cell.configure(pd: self.pets![indexPath.row])
        }
        cell.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalRows
    }
}

extension MainTabAdoptableCatsCollectionViewViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        if let pets = pets {
            guard indexPath.row < pets.count && indexPath.row >= 0
            else {return 400}
            
            let width = CGFloat((view.frame.size.width - (10 * 3)) / 2)
            let img = self.pets![indexPath.row].getAllImagesObjectsOfACertainSize("x")
            if img.isEmpty {
                return 400
            }
            let ratio: CGFloat = CGFloat(width) / CGFloat(img.first?.width ?? 1)
            var height = CGFloat((img.first?.height ?? 0) + 180) * (ratio + 0.10)
            height = min(400, height)
            if width == 0 || height == 0 {print("0 Width or Height detected")}
                return height }
        else {
            return 400
        }
    }
}

/*
extension MainTabAdoptableCatsCollectionViewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = view.frame.size.width - (10 * 3)
        if UIDevice.current.userInterfaceIdiom == .pad {
            size /= 6
        } else {
            size /= 2
        }
        return CGSize(width: size, height: size * 1.3)
    }
}
*/
