//
//  AdoptableCats3.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/3/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation
import SDWebImage
import YouTubePlayer

class MainTabBreedViewController: ZoomAnimationViewController, UITableViewDelegate, UITableViewDataSource {
    var currentlyPlayingYouTubeVideoView: YouTubePlayerView?
    
    @IBOutlet weak var BreedTV: TableViewWorkAround!
    
    var breeds = [Breed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BreedTV.dataSource = self
        BreedTV.delegate = self
        BreedTV.backgroundView = UIImageView(image: UIImage(named: "greenBackground"))
        BreedTV.backgroundColor = UIColor.clear
        BreedTV.separatorStyle = .none
        self.BreedTV.rowHeight = UITableView.automaticDimension
        BreedTV.estimatedRowHeight = 560
        
        retrieveData()
    }
    
    func retrieveData() {
        DatabaseManager.sharedInstance.fetchBreedsFit { (breeds) -> Void in
            self.breeds = breeds
            DispatchQueue.main.async {
                self.BreedTV.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breeds.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BreedTV.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainTabBreedTableViewCell
        
        cell.backgroundView = UIView(backgroundColor: .clear)
        cell.backgroundView?.addSeparator()

        cell.configure(breed: self.breeds[indexPath.row], sourceView: self.view)

        cell.tag = indexPath.row
        return cell
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
        separator.backgroundColor = UIColor.systemGreen
        separator.alpha = 0.5
        separator.draw(separator.bounds)
        separator.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]

        addSubview(separator)
    }
}
