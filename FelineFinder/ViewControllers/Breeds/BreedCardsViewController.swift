//
//  ViewController.swift
//  CardStackView
//
//  Created by Genki Mine on 7/9/17.
//  Copyright © 2017 Genki. All rights reserved.
//

import UIKit

class BreedCardsViewController: UIViewController {

    var breeds = [Breed]()
    var currentIndex = 0
    var cardStackView: CardStackView = CardStackView()
    @IBOutlet weak var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLbl.text = "Selected \(breeds.count) Breeds"
        
        self.view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)

        var cardViews = [UIView]()

        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        let w = safeFrame.width - 160
        
        for index in 0...breeds.count - 1 {
            let view = UIView()
            view.backgroundColor = UIColor.white
            
            view.layer.cornerRadius = 10.0
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 0.5
            view.layer.shadowColor = UIColor.lightGray.cgColor
            view.layer.shadowRadius = 2.0
            view.layer.shadowOffset = CGSize(width: 4, height: 4)
            view.layer.shadowOpacity = 0.2
            view.clipsToBounds = false
            view.layer.rasterizationScale = UIScreen.main.scale
            view.layer.shouldRasterize = true

            cardViews.append(view)

            let BreedImage = UIImageView(image: UIImage(named: breeds[index].FullSizedPicture))
            view.addSubview(BreedImage)
            let ratio = w / BreedImage.image!.size.width
            let h = BreedImage.image!.size.height * ratio
            BreedImage.frame = CGRect(x: 0, y: 20, width: w, height: h)
            
            let BreedNameLabel = UILabel(frame: CGRect(x: 0, y: -10, width: w, height: 40))
            BreedNameLabel.textAlignment = .center
            BreedNameLabel.text = breeds[index].BreedName
            BreedNameLabel.backgroundColor = UIColor.clear
            view.addSubview(BreedNameLabel)
            
            let viewImg = UIImage(named: "Cat's Eye")
            
            let viewButton = UIButton()
            viewButton.frame = CGRect(x: w - viewImg!.size.width - 120, y: h + viewImg!.size.height + 10, width: 150, height: 33)
            viewButton.imageView?.contentMode = .scaleAspectFill
            viewButton.addTarget(self, action: #selector(viewTapped(_:)), for: .touchUpInside)
            viewButton.setTitle("View Details", for: .normal)
            viewButton.setTitleColor(UIColor.black, for: .normal)
            viewButton.setImage(viewImg, for: .normal)
            view.addSubview(viewButton)
            
            let description = UITextView()
            description.frame = CGRect(x: 0, y: viewButton.frame.origin.y + viewButton.frame.height, width: w, height: safeFrame.height - (viewButton.frame.origin.y + viewButton.frame.height + 220))
            description.text = breeds[index].Description
            view.addSubview(description)
            
            if index == 0 {
                let FingerPrintImage = UIImageView(image: UIImage(named: "fingerprint"))
                let ratio2 = 50 / FingerPrintImage.image!.size.height
                let w2 = FingerPrintImage.image!.size.width * ratio2
                FingerPrintImage.frame = CGRect(x: 0, y: description.frame.origin.y + description.frame.height + 10, width: w2, height: 50)
                view.addSubview(FingerPrintImage)
                FingerPrintImage.tag = 0xDEADBEEF
            }
        }

        cardViews.reverse()

        cardStackView = CardStackView(cards: cardViews, showsPagination: true, maxAngle: 10, randomAngle: true, throwDuration: 0.4)
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        cardStackView.delegate = self
        self.view.addSubview(cardStackView)
        let views = ["cardStackView": cardStackView]

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|-80-[cardStackView]-80-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[cardStackView]-100-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let fp = cardStackView.cardViews.last?.viewWithTag(0xDEADBEEF) {
            fp.dragAcross()
        }
    }
    
    @objc func viewTapped(_ sender:UIButton!) {
        let breedDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "breedDetail") as! BreedDetailViewController
        breedDetail.modalPresentationStyle = .fullScreen
        breed = breeds[currentIndex]
        self.present(breedDetail, animated: false, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CardStackViewDelegate

extension BreedCardsViewController: CardStackViewDelegate {
    
    func cardStackViewDidChangePage(_ cardStackView: CardStackView) {
        self.currentIndex = cardStackView.currentIndex
        print("Current index: \(cardStackView.currentIndex)")
    }
    
}
