//
//  MainTabAdoptableCatsDetailViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/11/20.
//

import UIKit
import FaveButton
import MessageUI

protocol ToolbarDelegate {
    func createEmail(pet: Pet, shelter: shelter)
}

class AdoptableCatsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, descriptionChanged, ToolbarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heart: FaveButton!
    
    var pet: Pet!
    
    var rowHeight = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        heart.isSelected = Favorites.isFavorite(pet.petID, dataSource: .RescueGroup)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Favorites.storeIDs()
    }
    
    @IBAction func backButtonTapped(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "header") as? AdoptableHeaderTableViewCell {
                cell.setup(pet: self.pet, self)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "description") as? AdoptableDescriptionTableViewCell {
                cell.delegate = self
                cell.setup(pet: self.pet, shelter: globalShelterCache[pet.shelterID]!)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return CGFloat(max(100, rowHeight) + 40)
        } else {
            return 596
        }
    }
    
    func heightChanged(heigth: Int) {
        if rowHeight != heigth {
            rowHeight = heigth
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.view.layoutSubviews()
            })
        }
    }
    
    @IBAction func heartTapped(_ sender: Any) {
        if heart.isSelected {
            Favorites.addFavorite(pet.petID)
        } else {
            Favorites.removeFavorite(pet.petID, dataSource: .RescueGroup)
        }
    }
}

extension AdoptableCatsDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    func createEmail(pet: Pet, shelter: shelter) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = configuredMailComposeViewController()
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let shelter = globalShelterCache[pet.shelterID]!
        var email = shelter.email
        if (email.lowercased().hasPrefix("emailto")) {
            email = (shelter.email.chopPrefix(7))
        }
        var emailAddress = [String]()
        emailAddress.append(email)
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(emailAddress)
        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        Utilities.displayAlert("Could Not Send Email", errorMessage: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
    }
}

