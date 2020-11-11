//
//  AdoptableCats3.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation
import SDWebImage
import MessageUI
import FaveButton
import YouTubePlayer

class TableViewWorkAround: UITableView {
    override func layoutSubviews() {
        if self.window == nil {
            return
        }
        super.layoutSubviews()
    }
}

var selectedImages: [Int] = []

class MainTabAdoptableCats: ZoomAnimationViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, AlertDisplayer, MFMailComposeViewControllerDelegate {
    
    private let refreshControl = UIRefreshControl()
    
    var viewDidLayoutSubviewsForTheFirstTime = true
    
    var currentlyPlayingYouTubeVideoView: YouTubePlayerView?
    
    //var delegate: scrolledView!
    
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
    var observer4: Any!
    var observer5: Any!

    @IBOutlet weak var ZipCode: UILabel!
    @IBOutlet weak var MainTV: TableViewWorkAround! //UITableView!
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBAction func SearchButtonTapped(_ sender: Any) {
        let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        PetFinderFind.breed = globalBreed
        self.present(PetFinderFind, animated: true, completion: nil)
    }

    @IBOutlet weak var FavoriteBtn: FaveButton!
    
    @IBAction func FavoriteBtnTapped(_ sender: Any) {
        Favorites.storeIDs()
        Favorites.loadIDs()
        if FavoriteBtn.isSelected {
            UIView.transition(with: self.view, duration: 0.5, options: .transitionFlipFromLeft , animations: {
                self.tempBreedName = globalBreed?.BreedName ?? ALL_BREEDS
                globalBreed?.BreedName = FAVORITES
                self.tempTitleLabel = self.TitleLabel.text ?? "Cats for Adoption"
                self.TitleLabel.text = "Favorites"
                DownloadManager.loadFavorites(reset: true)
                self.SearchButton.isHidden = true
            }, completion: nil)
        } else {
            UIView.transition(with: self.view, duration: 0.5, options: .transitionFlipFromRight , animations: {
                globalBreed?.BreedName = self.tempBreedName
                self.TitleLabel.text = self.tempTitleLabel
                DownloadManager.loadPetList(reset: true)
                self.SearchButton.isHidden = false
            }, completion: nil)
        }
        if self.MainTV.numberOfRows(inSection: 0) > 0 {self.MainTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            MainTV.refreshControl = refreshControl
        } else {
            MainTV.addSubview(refreshControl)
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
        
        MainTV.dataSource = self
        MainTV.delegate = self
        MainTV.prefetchDataSource = self
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
 
        TitleLabel.text = "Cats for Adoption"
        
        pets = RescuePetsAPI5()
        
        MainTV.backgroundView = UIImageView(image: UIImage(named: "greenBackground"))
        MainTV.backgroundColor = UIColor.clear
        
        MainTV.separatorStyle = .none
        self.MainTV.rowHeight = UITableView.automaticDimension
        MainTV.estimatedRowHeight = 560
        
        SearchButton.setAttributedTitle(setEmojicaLabel(text: "🔎", size: SearchButton.titleLabel!.font.pointSize), for: .normal)

    }
    
    @objc private func refreshPetData(_ sender: Any) {
        PetFinderBreeds.removeValue(forKey: globalBreed!.BreedName)
        FavoriteBtn.isSelected = false
        DownloadManager.loadPetList(reset: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func getZipCode() {
        let keyStore = NSUbiquitousKeyValueStore()
        zipCode = keyStore.string(forKey: "zipCode") ?? ""
        if zipCode != "" {
            self.setFilterDisplay()
            self.pets?.loading = true
            DownloadManager.loadPetList(reset: true)
            return
        }
        
        LocationManager2.sharedInstance.getCurrentReverseGeoCodedLocation { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
            if error != nil {
                self.askForZipCode()
                return
            }
            guard let l = location else {
                return
            }
            
            zipCode = placemark?.postalCode ?? "19106"
            self.setFilterDisplay()
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
                self.setFilterDisplay()
                DispatchQueue.main.async {
                    self.MainTV.reloadData()
                }
                DownloadManager.loadPetList(reset: true)
                //self.setupReloadAndScroll()
            } else {
                let alert3 = UIAlertController(title: "Error", message: "You have not allowed Feline Finder to know where you are located so it cannot find cats which are closest to you.  The zip code has been set to the middle of the US population.  Zip code 66952.  You can change it from the find screen.  You can allow the app to use location services again by fliping the switch for Feline Finder in the iOS app system preferences.", preferredStyle: .alert)
                alert3.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert3, animated: true, completion: nil)
                zipCode = "66952"
                self.pets?.loading = true
                self.setFilterDisplay()
                DispatchQueue.main.async {
                    self.MainTV.reloadData()
                }
                DownloadManager.loadPetList(reset: true)
                //self.setupReloadAndScroll()
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
    
    var totalRows = 0
    
    func petsLoaded(notification:Notification) -> Void {
        print("petLoaded notification")
        
        guard let userInfo = notification.userInfo,
              let p = userInfo["petList"] as? RescuePetsAPI5
        else {
                print("No userInfo found in notification")
                return
        }
        
        pets = p
        
        //DownloadManager.sizeImages(pets: p)

        self.pets?.loading = false
        
        guard let newIndexPathsToReload = userInfo["newIndexPathsToReload"] as? [IndexPath] else {
          DispatchQueue.main.async { [unowned self] in
            totalRows = pets?.foundRows ?? 0
            self.MainTV.reloadData()
            selectedImages = [Int](repeating: 0, count: totalRows)
            isFetchInProgress = false
            self.refreshControl.endRefreshing()
          }
          return
        }
        
        DispatchQueue.main.async { [unowned self] in
            let indexPathsForVisibleRows = MainTV.indexPathsForVisibleRows ?? []
            let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(newIndexPathsToReload)
            let indexPathsToReload = Array(indexPathsIntersection)
            self.MainTV.reloadRows(at: indexPathsToReload, with: .automatic)
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
            setFilterDisplay()
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
        setFilterDisplay()
        if viewPopped {
            self.pets?.dateCreated = INITIAL_DATE
            DownloadManager.loadPetList(reset: true)
            viewPopped = false
        }
        DispatchQueue.main.async { [unowned self] in
            self.MainTV.reloadData()
            if totalRows > 0 {self.MainTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)}
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFilterDisplay() {
        let filter = "Zip:\(zipCode)"
        ZipCode.text = filter
        TitleLabel.text = globalBreed?.BreedName
        
        if currentFilterSave != "Touch Here To Load/Save..." {
             TitleLabel.text = currentFilterSave
        } else {
            let breeds = filterOptions.breedOption?.getDisplayValues() ?? ""
            if ((breeds.contains(",")) || breeds == "" || breeds=="Any") {
                TitleLabel.text = "Cats for Adoption"
            } else {
                 TitleLabel.text = breeds
            }
        }

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
}

extension MainTabAdoptableCats: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if isFetchInProgress {return}
        if indexPaths.contains(where: isLoadingCell) {
            DownloadManager.loadPetList(reset: false)
        }
    }
  
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        DispatchQueue.main.async { [unowned self] in
 
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            MainTV.isHidden = false
            MainTV.reloadData()
            return
        }

        let indexPathsForVisibleRows = MainTV.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(newIndexPathsToReload)
        let indexPathsToReload = Array(indexPathsIntersection)
        MainTV.reloadRows(at: indexPathsToReload, with: .automatic)
        }
    }
}

private extension MainTabAdoptableCats {
  func isLoadingCell(for indexPath: IndexPath) -> Bool {
    if indexPath.row > pets!.Pets.count {
        print ("isLoadingCell row = \(indexPath.row) count = \(pets!.Pets.count)")
    } else {
        print ("NOT isLoadingCell row = \(indexPath.row) count = \(pets!.Pets.count)")
    }
    return indexPath.row > pets!.Pets.count
  }
}

private extension UIView {
    convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }

    func addSeparator() {
        let separatorHeight: CGFloat = 6
        let frame = CGRect(x: 0, y: bounds.height - separatorHeight, width: bounds.width, height: separatorHeight)
        let separator = CustomView(frame: frame)
        //separator.backgroundColor = UIColor(displayP3Red: 254/255, green: 211/255, blue: 35/255, alpha: 1)
        //separator.backgroundColor = UIColor.gray
        //separator.backgroundColor = UIColor(displayP3Red: 28/255, green: 69/255, blue: 38/255, alpha: 1)
        separator.backgroundColor = UIColor.systemGreen
        separator.alpha = 0.5
        separator.draw(separator.bounds)
        separator.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]

        addSubview(separator)
    }
}

class CustomView: UIView
{
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext()
        {
            context.setStrokeColor(UIColor.lightGray.cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: 0, y: 1))
            context.addLine(to: CGPoint(x: bounds.width, y: 1))
            context.setStrokeColor(UIColor.darkGray.cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: 0, y: bounds.height))
            context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
            context.strokePath()
        }
    }
}

extension MainTabAdoptableCats {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FavoriteBtn.isSelected && totalRows > 0 {
            return totalRows
        } else {
            return totalRows + 1
        }
    }
}

extension MainTabAdoptableCats {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let ytv = currentlyPlayingYouTubeVideoView {
            if !(MainTV.indexPathsForVisibleRows?.contains(IndexPath(row: ytv.tag, section: 0)))! {
                ytv.stop()
                ytv.isHidden = true
                currentlyPlayingYouTubeVideoView = nil
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isFavorite = FavoriteBtn.isSelected
        var numberOfRows = 0
        if isFavorite == true && totalRows > 0 {
            numberOfRows = totalRows
        } else {
            numberOfRows = totalRows + 1
        }
        if (numberOfRows == indexPath.row + 1 && isFavorite == false) || (isFavorite == true && totalRows == 0) {
            let cell = MainTV.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyTableViewCell
            if (isFetchInProgress == false || isFavorite == true) {
                if totalRows == 0 {
                    if isFavorite == true {
                        cell.MessageLabel.text = "Add Some Favorites"
                    } else {
                        cell.MessageLabel.text = "Sorry nothing found.  I can search once a day for it if you tap here."
                    }
                } else if numberOfRows == indexPath.row + 1 {
                    cell.MessageLabel.text = "End of Results.  If you didn't find what you want tap here."
                }
            } else if (isFetchInProgress == true && isFavorite == false) {
                cell.MessageLabel.text = "Please Wait While Cats Are Loading..."
            }

            //cell.configure(fetching: isFetchInProgress, numberOfRows: numberOfRows, currentRow: indexPath.row, IsFavoriteMode: FavoriteBtn.isSelected)
            return cell
        } else {
            let cell = MainTV.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainTabAdoptableCatsMainTVCell
            
            cell.backgroundView = UIView(backgroundColor: .clear)
            cell.backgroundView?.addSeparator()

            cell.selectedBackgroundView = UIView(backgroundColor: .blue)
            cell.selectedBackgroundView?.addSeparator()
            
            if isLoadingCell(for: indexPath) {
                cell.configure(pd: .none, sh: .none, sourceView: self.view)
            } else {
                cell.configure(pd: self.pets![indexPath.row], sh: globalShelterCache[self.pets![indexPath.row].shelterID], sourceView: self.view)
            }
            cell.tag = indexPath.row
            return cell
        }
    }

    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        if self.pets!.foundRows < indexPath.row {return}
        let petData = self.pets![indexPath.row]
        let FelineDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdoptableCatsDetail") as! MainTabAdoptableCats
        FelineDetail.pet = petData
        FelineDetail.petID = petData.petID
        FelineDetail.petName = petData.name
        FelineDetail.breedName = globalBreed!.BreedName
        FelineDetail.modalPresentationStyle = .custom
        FelineDetail.transitioningDelegate = self
        scrollPos = indexPath
        whichTab = 2
        //present(FelineDetail, animated: true, completion: nil)
    }
    */
    
}
