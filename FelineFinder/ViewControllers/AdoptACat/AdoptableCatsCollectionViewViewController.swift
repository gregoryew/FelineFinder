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
import SwiftLocation

var selectedImages: [Int] = []

var selectedImage: UIImageView!

var loadingFavorites = false

protocol AdoptionDelegate {
    func Dismiss(vc: UIViewController)
    func Download(reset: Bool)
    func GetTitle(totalRows: Int) -> String
}

class AdoptableCatsCollectionViewViewController: ZoomAnimationViewController, UICollectionViewDelegate, UICollectionViewDataSource, AlertDisplayer, adoptableCatsViewControllerDelegate,
    FilterDismiss
{

    @IBOutlet weak var SortMenu: UIButton!
    @IBOutlet weak var FilterButton: UIButton!
    @IBOutlet weak var AdoptableCatCollectionView: UICollectionView!
    @IBOutlet weak var CloseButton: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
    var pets: RescuePetsAPI5?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    
    var tempBreedName = ""
    var tempTitleLabel = ""
    
    var titles:[String] = []
    var totalRow = 0
    var times = 0
    var observer : Any!
    var observer2: Any!
    var observer3: Any!
    
    var totalRows = 0
    
    var delegate: AdoptionDelegate?
    
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
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshPetData(_:)), for: .valueChanged)
        
        let nc = NotificationCenter.default
        
        if loadingFavorites {
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
        
        getZipCode()
        
        pets = RescuePetsAPI5()
        
        if delegate != nil {
            self.CloseButton.isHidden = false
        } else {
            self.CloseButton.isHidden = true
            self.SortMenu.setTitle("", for: .normal)
        }
    }
    
    func downloadData(reset: Bool) {
        if delegate != nil {
            delegate?.Download(reset: reset)
        } else {
            DownloadManager.loadPetList(reset: reset)
        }
    }
    
    @objc private func refreshPetData(_ sender: Any) {
        PetFinderBreeds.removeValue(forKey: globalBreed!.BreedName)
        downloadData(reset: true)
    }
    
    deinit {
        print("Deinit Collection")
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.Dismiss(vc: self)
    }
    
    func getZipCode() {
        let keyStore = NSUbiquitousKeyValueStore()
        zipCode = keyStore.string(forKey: "zipCode") ?? ""
        if zipCode != "" {
            self.pets?.loading = true
            let breed: Breed = Breed(id: 0, name: ALL_BREEDS, url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
            globalBreed = breed
            downloadData(reset: true)
            return
        }
        if Reachability.isLocationServiceEnabled() == true {
        SwiftLocation.gpsLocationWith {
            // configure everything about your request
            $0.subscription = .single // continous updated until you stop it
            $0.accuracy = .house
            $0.activityType = .otherNavigation
            $0.timeout = .delayed(5) // 5 seconds of timeout after auth granted
        }.then { result in // you can attach one or more subscriptions via `then`.
            switch result {
            case .success(let newData):
                let service = Geocoder.Apple(lat: newData.coordinate.latitude, lng: newData.coordinate.longitude)
                SwiftLocation.geocodeWith(service).then { result in
                    zipCode = result.data?.first?.clPlacemark?.postalCode ?? "66952"
                    let keyStore = NSUbiquitousKeyValueStore()
                    keyStore.set(zipCode, forKey: "zipCode")
                    keyStore.synchronize()
                    self.pets?.loading = true
                    let breed: Breed = Breed(id: 0, name: ALL_BREEDS, url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
                    globalBreed = breed
                    self.downloadData(reset: true)
                }
            case .failure(_):
                self.askForZipCode()
            }
        }
        } else {
            let alertController = UIAlertController(title: "Location Serives Disabled", message: "Please enable location services for this app.", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in

                 guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                     return
                 }

                 if UIApplication.shared.canOpenURL(settingsUrl) {
                     UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                         print("Settings opened: \(success)") // Prints true
                     })
                 }
             }
             
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
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
            if validateZipCode(localZipCode: (textField.text)!) {
                zipCode = (textField.text)!
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
            //self.AdoptableCatCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            if delegate != nil {
                self.SortMenu.setTitle(delegate?.GetTitle(totalRows: totalRows), for: .normal)
            } else {
                self.SortMenu.setTitle("\(totalRows) Cats. Zip: \(zipCode)", for: .normal)
            }
            
            isFetchInProgress = false
            self.AdoptableCatCollectionView.reloadData()
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
            if totalRows > 0 {self.AdoptableCatCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)}
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
        
        if #available(iOS 13.0, *) {
            details.modalPresentationStyle = .automatic
        }
        
        details.delegate = self
        
        present(details, animated: false, completion: nil)

    }
    
    func closeAdoptDetailVC(_ adoptVC: AdoptableCatsDetailViewController) {
        adoptVC.dismiss(animated: true)
        if delegate != nil {
            delegate?.Download(reset: true)
        } else {
            DispatchQueue.main.async {
                self.AdoptableCatCollectionView.reloadData()
            }
        }
    }
    
    //When tapped will bring up the filter search
    //Pass query to search screen
    //Next set search daily to yes
    //Finally present dialog asking user to modify filter
    //And save and the system will search daily
    //Until the user sets the offline search to no and saves
    @IBAction func OfflineSearchTapped(_ sender: Any) {
        OfflineSearch = true
        let FilterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Filter") as! FilterViewController
        FilterViewController.modalPresentationStyle = .formSheet
        FilterViewController.delegate = self
        self.present(FilterViewController, animated: true, completion: nil)
    }
    
    @IBAction func FilterButtonTapped(_ sender: Any) {
        let FilterViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Filter") as! FilterViewController
        FilterViewController.modalPresentationStyle = .formSheet
        FilterViewController.delegate = self
        self.present(FilterViewController, animated: true, completion: nil)
    }
    
    func FilterDismiss(vc: UIViewController) {
        DispatchQueue.main.async(execute: {
            let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
            globalBreed = breed
            PetFinderBreeds[(globalBreed?.BreedName)! + "_ADOPT"] = nil
            vc.dismiss(animated: false, completion: nil)
            self.AdoptableCatCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            DownloadManager.loadPetList(reset: true)
        })
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
