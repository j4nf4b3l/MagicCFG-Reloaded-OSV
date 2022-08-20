//
//  InfoViewController.swift
//  MagicCFG
//
//  Created by Jan Fabel on 26.06.20.
//  Copyright © 2020 Jan Fabel. All rights reserved.
//

import Cocoa

class InfoViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?


        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        VersionLabel.stringValue = version
        // Do view setup here.
    }
    @IBOutlet weak var VersionLabel: NSTextField!
    
    
}
