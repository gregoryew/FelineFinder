//
//  AdoptableCats3.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

class TableViewWorkAround: UITableView {
    override func layoutSubviews() {
        if self.window == nil {
            return
        }
        super.layoutSubviews()
    }
}

class MainTabAdoptableCats: ZoomAnimationViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, AlertDisplayer {
    
    var viewDidLayoutSubviewsForTheFirstTime = true
    
    var pets: RescuePetsAPI3?
    var zipCodes: Dictionary<String, zipCoordinates> = [:]
    var currentLocation : CLLocation!
    
    var titles:[String] = []
    var totalRow = 0
    var times = 0
    var observer : Any!
    var observer2: Any!
    var obeserver3: Any!
    
    @IBOutlet weak var ZipCode: UILabel!
    @IBOutlet weak var MainTV: TableViewWorkAround! //UITableView!
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBAction func SearchButtonTapped(_ sender: Any) {
        let PetFinderFind = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PetFinderFind") as! PetFinderFindViewController
        PetFinderFind.breed = globalBreed
        present(PetFinderFind, animated: false, completion: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        
        observer = nc.addObserver(forName:petsLoadedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.petsLoaded(notification: notification)
        }
        
        observer3 = nc.addObserver(forName:petsFailedMessage, object:nil, queue:nil) { [weak self] notification in
            self?.petsFailed(notification: notification)
        }
        
        observer2 = nc.addObserver(forName:filterReturned, object:nil, queue:nil) { [weak self] notification in
            self?.retrieveData()
        }

        MainTV.dataSource = self
        MainTV.delegate = self
        MainTV.prefetchDataSource = self
        
        TitleLabel.text = "Cats for Adoption"
        
        if (!Favorites.loaded) {Favorites.LoadFavorites(tv: nil)}

        pets = RescuePetsAPI3()

    }
    
    func getZipCode() {
        let keyStore = NSUbiquitousKeyValueStore()
        zipCode = keyStore.string(forKey: "zipCode") ?? ""
        if zipCode != "" {
            self.setFilterDisplay()
            self.pets?.loading = true
            //DownloadManager.loadPetList()
            //self.setupReloadAndScroll()
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
            //self.setupReloadAndScroll()
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
                DownloadManager.loadPetList()
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
                DownloadManager.loadPetList()
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
            let title = "Warning"
            let action = UIAlertAction(title: "OK", style: .default)
            displayAlert(with: title , message: reason, actions: [action])
            isFetchInProgress = false
        }
    }
    
    func petsLoaded(notification:Notification) -> Void {
        print("petLoaded notification")
        
        guard let userInfo = notification.userInfo,
              let p = userInfo["petList"] as? RescuePetsAPI3
        else {
                print("No userInfo found in notification")
                return
        }

        pets = p
        
        self.pets?.loading = false
        
        guard let newIndexPathsToReload = userInfo["newIndexPathsToReload"] as? [IndexPath] else {
          DispatchQueue.main.async { [unowned self] in
            self.MainTV.reloadData()
            isFetchInProgress = false
          }
          return
        }
        
        DispatchQueue.main.async { [unowned self] in
            let indexPathsForVisibleRows = MainTV.indexPathsForVisibleRows ?? []
            let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(newIndexPathsToReload)
            let indexPathsToReload = Array(indexPathsIntersection)
            self.MainTV.reloadRows(at: indexPathsToReload, with: .automatic)
            isFetchInProgress = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveData()
        let breed: Breed = Breed(id: 0, name: "All Breeds", url: "", picture: "", percentMatch: 0, desc: "", fullPict: "", rbID: "", youTubeURL: "", cats101: "", playListID: "");
        globalBreed = breed
        if zipCode == "" {
            getZipCode()
        } else {
            setFilterDisplay()
            self.pets?.loading = true
            //DownloadManager.loadPetList()
            //setupReloadAndScroll()
        }
        DownloadManager.loadPetList()
    }
    
    @objc func retrieveData() {
        setFilterDisplay()
        if viewPopped {
            PetFinderBreeds[(globalBreed?.BreedName)!] = nil
            zipCodeGlobal = ""
            self.pets?.loading = true
            DownloadManager.loadPetList()
            viewPopped = false
        }
        DispatchQueue.main.async { [unowned self] in
            self.MainTV.reloadData()
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
        zipCodeGlobal = ""
        PetFinderBreeds[(globalBreed?.BreedName)!] = nil
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        /*
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
        */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pets?.foundRows ?? 0
        
        /*
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
        */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MainTV.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainTabAdoptableCatsMainTVCell
        
        /*
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
        */
        
        if isLoadingCell(for: indexPath) {
            cell.configure(pd: .none)
        } else {
            cell.configure(pd: self.pets![indexPath.row])
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let petData = self.pets!.distances[titles[indexPath.section]]![indexPath.row]
        let petData = self.pets![indexPath.row]
        let FelineDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdoptableCatsDetail") as! CatDetailViewController
        FelineDetail.pet = petData
        FelineDetail.petID = petData.petID
        FelineDetail.petName = petData.name
        FelineDetail.breedName = globalBreed!.BreedName
        FelineDetail.modalPresentationStyle = .custom
        FelineDetail.transitioningDelegate = self
        scrollPos = indexPath
        whichTab = 2
        present(FelineDetail, animated: true, completion: nil)
    }

}

extension MainTabAdoptableCats: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if isFetchInProgress {return}
        if indexPaths.contains(where: isLoadingCell) {
            self.pets?.loading = true
            DownloadManager.loadPetList(more: true)
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
    if indexPath.row >= pets!.Pets.count {
        print ("isLoadingCell row = \(indexPath.row) count = \(pets!.Pets.count)")
    } else {
        print ("NOT isLoadingCell row = \(indexPath.row) count = \(pets!.Pets.count)")
    }
    return indexPath.row >= pets!.Pets.count
  }
/*
  func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
    let indexPathsForVisibleRows = MainTV.indexPathsForVisibleRows ?? []
    let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
    return Array(indexPathsIntersection)
  }
*/
}
