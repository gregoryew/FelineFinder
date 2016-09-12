//
//  InstructionsViewController.swift
//  Cat Appz
//
//  Created by Gregory Williams on 8/15/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {
    
    @IBOutlet weak var InstructionTextView: UITextView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        InstructionTextView.setContentOffset(CGPointZero, animated: false)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:true);
    }
}
