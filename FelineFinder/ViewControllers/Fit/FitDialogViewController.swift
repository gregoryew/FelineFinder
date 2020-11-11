//
//  FitDialogViewController.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/19/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit
import SDWebImage

class FitDialogViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    @IBOutlet weak var GIFImage: SDAnimatedImageView!
    
    var image: String = ""
    var titleString: String = ""
    var message: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = titleString
        
        MessageLabel.text = message
        
        let animatedImage = SDAnimatedImage(named: image + ".gif")
        GIFImage.image = animatedImage
    }
    
    @IBAction func ContinueTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
