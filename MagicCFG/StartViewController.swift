//
//  StartViewController.swift
//  MagicCFG
//
//  Created by Jan Fabel on 20.06.20.
//  Copyright © 2020 Jan Fabel. All rights reserved.
//

import Cocoa

class StartViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ContinueBtn_O.becomeFirstResponder()
        // Do view setup here.
    }
    
    @IBOutlet weak var ContinueBtn_O: NSButton!
    
    @IBAction func ContinueBTN(_ sender: Any) {
        performSegue(withIdentifier: "start", sender: sender)
        self.view.window?.windowController?.close()
    }
}
