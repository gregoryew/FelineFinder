//
//  BreedInfoViewController.swift
//  FelineFinder
//
//  Created by Gregory Williams on 11/25/20.
//

import UIKit
import WebKit

class BreedInfoViewController: UIViewController {

    var breed: Breed?
    
    @IBOutlet weak var wv: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: breed!.BreedHTMLURL) {
            let request = URLRequest(url: url)
            wv.load(request)
        }
    }
}
