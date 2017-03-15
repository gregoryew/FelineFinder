//
//  InstructionsViewController.swift
//  Cat Appz
//
//  Created by Gregory Williams on 8/15/16.
//  Copyright © 2016 Gregory Williams. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class InstructionsViewController: UIViewController, NavgationTransitionable {
    
    @IBOutlet weak var InstructionTextView: UITextView!
    weak var tr_pushTransition: TRNavgationTransitionDelegate?
    
    deinit {
        print ("InstructionsViewController deinit")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        InstructionTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated:false);
    }
    
    @IBAction func goBackTapped(_ sender: Any) {
        _ = navigationController?.tr_popViewController()
    }
    
}
