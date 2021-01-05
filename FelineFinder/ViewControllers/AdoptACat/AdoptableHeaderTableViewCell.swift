//
//  AdoptHeaderTableViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/3/21.
//

import UIKit
import FaveButton
import WebKit
import SDWebImage
import MessageUI

enum detailCollectionViewTypes: Int {
    case tools = 1
    case media = 2
}

class AdoptableHeaderTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, HorizontalLayoutVaryingWidthsLayoutDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var heart: FaveButton!
    @IBOutlet weak var PetName: UILabel!
    @IBOutlet weak var breed: UILabel!
    @IBOutlet weak var stats: UILabel!
    @IBOutlet weak var location: UILabel!

    @IBOutlet weak var toolsToolBar: UICollectionView!
    @IBOutlet weak var toolbarWidth: NSLayoutConstraint!

    @IBOutlet weak var mediaToolBar: UICollectionView!
    @IBOutlet weak var mediaToolbarWidth: NSLayoutConstraint!
    
    var pet: Pet!
    var tools: Tools!
    var media: Tools!
    
    var selectedPhoto = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(pet: Pet) {
        self.pet = pet
        tools = Tools.init(pet: self.pet, shelter: globalShelterCache[self.pet.shelterID]!, sourceView: self.contentView)
        media = Tools.init(pet: self.pet, shelter: globalShelterCache[pet.shelterID]!, sourceView: self.contentView)
        
        if let imgURL = URL(string: pet.getImage(1, size: "x")) {
        self.photo.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "NoCatImage"), options: SDWebImageOptions.highPriority, completed: nil)
        } else {
            self.photo.image = UIImage(named: "NoCatImage")
        }
        
        self.PetName.text = pet.name
        
        self.breed.text = pet.breeds.first
        
        var options = [String]()
        if pet.status != "" {
            options.append(pet.status)
        }
        if pet.age != "" {
            options.append(pet.age)
        }
        if pet.sex != "" {
            options.append(pet.sex)
        }
        if pet.size != "" {
            options.append(pet.size)
        }
        stats.text = options.joined(separator: " | ") + " "
        
        var location = [String]()
        if pet.location != "" {
            location.append(pet.location)
        }
        if pet.distance != 0 {
            location.append("\(pet.distance) Miles")
        }
        self.location.text = location.joined(separator: " - ") + " "
        
        toolsToolBar.tag = detailCollectionViewTypes.tools.rawValue
        tools.mode = .tools
        toolsToolBar.dataSource = self
        toolsToolBar.delegate = self
        
        let toolslayout = toolsToolBar.collectionViewLayout as! HorizontalLayoutVaryingWidths
        toolslayout.delegate = self
        toolslayout.numberOfRows = 1
        toolslayout.cellPadding = 2.5
        toolslayout.columnHeight = 65
        
        toolbarWidth.constant = CGFloat(tools.count() * 65)
        
        mediaToolBar.tag = detailCollectionViewTypes.media.rawValue
        media.mode = .media
        mediaToolBar.dataSource = self
        mediaToolBar.delegate = self
        
        var mediaWidth: CGFloat = 0.0
        for m in media {
            if m.cellType == .image {
                let photo = m as! imageTool
                let ratio = CGFloat(100.0) / CGFloat(photo.thumbNail.height)
                mediaWidth += CGFloat(photo.thumbNail.width) * ratio
            } else if m.cellType == .video {
                mediaWidth += 133
            }
        }
        if CGFloat(mediaWidth) < self.contentView.frame.width {
             mediaToolbarWidth.constant = CGFloat(mediaWidth)
        } else {
            mediaToolbarWidth.constant = self.contentView.frame.width
        }
        
        let medialayout = mediaToolBar.collectionViewLayout as! HorizontalLayoutVaryingWidths
        medialayout.delegate = self
        medialayout.numberOfRows = 1
        medialayout.cellPadding = 2.5
        
        mediaToolBar.selectItem(at: IndexPath(item: selectedPhoto, section: 0), animated: false, scrollPosition: .left)

        heart.isSelected = Favorites.isFavorite(pet.petID, dataSource: .RescueGroup)

    }

    @IBAction func heartTapped(_ sender: Any) {
        if heart.isSelected {
            Favorites.addFavorite(pet.petID)
        } else {
            Favorites.removeFavorite(pet.petID, dataSource: .RescueGroup)
        }
    }
        
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: false, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        switch collectionView.tag {
        case detailCollectionViewTypes.tools.rawValue:
            return 65
        case detailCollectionViewTypes.media.rawValue:
            if media[indexPath.item] is imageTool {
                let h = CGFloat((media[indexPath.item] as? imageTool)?.thumbNail.height ?? 95)
                let ratio = 95.0 / h
                return CGFloat((media[indexPath.item] as? imageTool)?.thumbNail.width ?? 95) * ratio
            } else {
                return 133
            }
        default: return 0
        }
    }
    
    @IBAction func ListIconTapped(_ sender: Any) {
    }
    
    @IBAction func filterTapped(_ sender: Any) {
    }
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case detailCollectionViewTypes.tools.rawValue:
            print("tools count = \(tools.count())")
            print("tools datasource set \(String(describing: collectionView.dataSource))")
            print("tools delegate set \(String(describing: collectionView.delegate))")
            return tools.count()
        case detailCollectionViewTypes.media.rawValue:
            print("media count = \(media.count())")
            print("media datasource set \(String(describing: collectionView.dataSource))")
            print("media delegate set \(String(describing: collectionView.delegate))")
            return media.count()
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case detailCollectionViewTypes.tools.rawValue:
            let cell = toolsToolBar.dequeueReusableCell(withReuseIdentifier: "toolCell", for: indexPath) as! ToolCell
            cell.configure(tool: tools[indexPath.item])
            return cell
        case detailCollectionViewTypes.media.rawValue:
            let cell = mediaToolBar.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as! mediaCell
            cell.configure(mediaTool: media[indexPath.item], isSelected: indexPath.item == selectedPhoto)
            return cell
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case
            detailCollectionViewTypes.tools.rawValue:
            tools[indexPath.item].performAction()
        case
            detailCollectionViewTypes.media.rawValue:
            let photoURL: URL?
            if media[indexPath.item] is imageTool {
                photoURL = URL(string: (media[indexPath.item] as! imageTool).photo.URL)
            } else {
                photoURL = URL(string: (media[indexPath.item] as! youTubeTool).video.urlThumbnail)
                media[indexPath.item].performAction()
            }
            photo.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "NoCatImage"), completed: nil)
            selectedPhoto = indexPath.item
        default: break
        }
    }
}
