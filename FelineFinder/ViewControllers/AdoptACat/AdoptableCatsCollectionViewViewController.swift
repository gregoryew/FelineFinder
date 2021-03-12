//
//  MainTabAdoptableCatsTableViewViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit
import CMMapLauncher
import PopMenu
import DZNEmptyDataSet

var selectedImages: [Int] = []

var selectedImage: UIImageView!

class AdoptableCatsCollectionViewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, AlertDisplayer, PopMenuViewControllerDelegate, adoptableCatsViewControllerDelegate
{

    @IBOutlet weak var SortMenu: UIButton!
    @IBOutlet weak var FilterButton: UIButton!
    
    @IBOutlet weak var AdoptableCatCollectionView: UICollectionView!
    
    var popMenu: PopMenuViewController? = nil
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
    
    //let transition = PopAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add Refresh Control to Table View

        Favorites.LoadFavorites()

        if #available(iOS 10.0, *) {
            AdoptableCatCollectionView.refreshControl = refreshControl
        } else {
            AdoptableCatCollectionView.addSubview(refreshControl)
        }
        
        self.view.tag = ADOPTABLE_CATS_VC
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshPetData(_:)), for: .valueChanged)
        
        let nc = NotificationCenter.default
        
        if self.view.tag == FAVORITES_VC {
            observer = nc.addObserver(forName:favoritesLoadedMessage, object:nil, queue:nil) { [weak self] notification in
                self?.petsLoaded(notification: notification)
            }
            
            observer3 = nc.addObserver(forName:favoritesFailedMessage, object:nil, queue:nil) { [weak self] notification in
                self?.petsFailed(notification: notification)
            }
        } else {
            observer = nc.addObserver(forName:petsLoadedMessage, object:nil, queue:nil) { [weak self] notification in
                self?.petsLoaded(notification: notification)
            }
                    
            observer2 = nc.addObserver(forName:filterReturned, object:nil, queue:nil) { [weak self] notification in
                self?.retrieveData()
            }
            
            observer3 = nc.addObserver(forName:petsFailedMessage, object:nil, queue:nil) { [weak self] notification in
                self?.petsFailed(notification: notification)
            }
        }
        
        AdoptableCatCollectionView.isPrefetchingEnabled = true
        AdoptableCatCollectionView.delegate = self
        AdoptableCatCollectionView.prefetchDataSource = self
        AdoptableCatCollectionView.emptyDataSetDelegate = self
        AdoptableCatCollectionView.emptyDataSetSource = self
        
        let layout = PinterestLayout()
        layout.delegate = self
        self.AdoptableCatCollectionView.collectionViewLayout = layout
        
        locationManager?.delegate = self
//        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
         
        pets = RescuePetsAPI5()
    }
    
    func downloadData(reset: Bool) {
        if self.view.tag == ADOPTABLE_CATS_VC {
            DownloadManager.loadPetList(reset: reset)
        } else {
            DownloadManager.loadFavorites(reset: reset)
        }
    }
    
    @objc private func refreshPetData(_ sender: Any) {
        PetFinderBreeds.removeValue(forKey: globalBreed!.BreedName)
        downloadData(reset: true)
    }
    
    deinit {
        print("Deinit Collection")
    }
    
    func getZipCode() {
        let keyStore = NSUbiquitousKeyValueStore()
        zipCode = keyStore.string(forKey: "zipCode") ?? ""
        if zipCode != "" {
            self.pets?.loading = true
            downloadData(reset: true)
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
            self.downloadData(reset: true)
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
                self.downloadData(reset: true)
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
                self.downloadData(reset: true)
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

/*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let breed: Breed = Breed(id: 0, name: ALL_BREEDS, url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
        globalBreed = breed
        if zipCode == "" {
            getZipCode()
        } else {
            self.pets?.loading = true
            downloadData(reset: true)
        }
    }
 */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let breed: Breed = Breed(id: 0, name: ALL_BREEDS, url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
        globalBreed = breed
        if zipCode == "" {
            getZipCode()
        } else {
            self.pets?.loading = true
            downloadData(reset: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Favorites.storeIDs()
    }
    
    @objc func retrieveData() {
        if viewPopped {
            self.pets?.dateCreated = INITIAL_DATE
            downloadData(reset: true)
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
        downloadData(reset: true)
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
        
        let cell = collectionView.cellForItem(at: indexPath) as! AdoptableCatsCollectionViewCell
        
        selectedImage = UIImageView(frame: cell.frame)
        selectedImage.image = cell.photo.image
        
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdoptDetail") as! AdoptableCatsDetailViewController

        details.pet = self.pets!.Pets[indexPath.item]
        
        details.modalPresentationStyle = .automatic
        
        details.delegate = self
        
        present(details, animated: false, completion: nil)

    }
    
    func closeAdoptDetailVC(_ adoptVC: AdoptableCatsDetailViewController) {
        rowHeight = 0
        dismiss(animated: true)
    }
    
    //When tapped will bring up the filter search
    //Pass query to search screen
    //Next set search daily to yes
    //Finally present dialog asking user to modify filter
    //And save and the system will search daily
    //Until the user sets the offline search to no and saves
    @IBAction func OfflineSearchTapped(_ sender: Any) {
        //let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        //self.present(PetFinderFind, animated: true, completion: nil)
    }
    
    @IBAction func FilterButtonTapped(_ sender: Any) {
        //let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        //self.present(PetFinderFind, animated: true, completion: nil)
    }
    
    func popMenuCustomSize() -> PopMenuViewController {
        let action1 = PopMenuDefaultAction(title: "Closest", color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        let action2 = PopMenuDefaultAction(title: "Newest", color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        let action3 = PopMenuDefaultAction(title: "Best Match", color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))

        let actions = [
            action1,
            action2,
            action3
        ]
        
        let popMenu = PopMenuViewController(actions: actions)
        
        popMenu.appearance.popMenuColor.backgroundColor = .solid(fill: .white)
        
        return popMenu
    }

    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        SortMenu.setTitle("Sort By: " + popMenuViewController.actions[index].title!, for: .normal)
    }
    
    @IBAction func SortMenuTapped(_ sender: Any) {
        popMenu = popMenuCustomSize()
        popMenu?.shouldDismissOnSelection = true
        popMenu?.delegate = self
        var origin = SortMenu.frame.origin
        origin.x = (SortMenu.frame.origin.x + SortMenu.frame.width) -  (popMenu?.contentFrame.width)!
        origin.y = SortMenu.frame.origin.y - (popMenu?.contentFrame.height ?? SortMenu.frame.origin.y)
        popMenu?.view.frame.origin = origin
        if let popMenuViewController = popMenu {
            present(popMenuViewController, animated: true, completion: nil)
        }
    }
}

extension AdoptableCatsCollectionViewViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            downloadData(reset: false)
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
          downloadData(reset: false)
      } else {
          print ("NOT isLoadingCell row = \(indexPath.row) count = \(pets!.Pets.count)")
      }
      return indexPath.row >= pets!.Pets.count
    }
}

extension AdoptableCatsCollectionViewViewController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = AdoptableCatCollectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! AdoptableCatsCollectionViewCell
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

extension AdoptableCatsCollectionViewViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "cat")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if (isFetchInProgress == false) {
            if totalRows == 0 {
                return NSAttributedString(string: "Sorry nothing found.  I can search once a day for it if you tap the search icon above.")
            }
        } else if (isFetchInProgress == true) {
            return NSAttributedString(string: "Please Wait While Cats Are Loading...")
        }
        return NSAttributedString(string: "")
    }
}

extension AdoptableCatsCollectionViewViewController: PinterestLayoutDelegate  {
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
            return height
        } else {
            return 400
        }
    }
}
