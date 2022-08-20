//
//  RestoreBackupViewController.swift
//  MagicCFG
//
//  Created by Jan Fabel on 21.06.20.
//  Copyright © 2020 Jan Fabel. All rights reserved.
//

import Cocoa
import ORSSerial

class RestoreBackupViewController: NSViewController, ORSSerialPortDelegate {
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("SerialPort removed")
    }
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        guard let string = String(data: data, encoding: .utf8) else { return }
        all_log = string
        print(string)
    }
    @IBAction func CancelBTN(_ sender: Any) {
        self.dismiss(sender)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //port.delegate = self
        print(restoreBackupPath)
        ProcessView.isHidden = true
        // Do view setup here.
    }


    @IBOutlet weak var WarningView: NSView!
    @IBOutlet weak var ProcessView: NSView!
    @IBOutlet weak var StatusImg: NSImageView!
 
    @IBOutlet weak var CommandText: NSTextField!
    @IBOutlet weak var ProgressOFRestore: NSProgressIndicator!
    @IBOutlet weak var ContinueBTN_O: NSButton!
    @IBOutlet weak var DoneBTN_O: NSButton!
    @IBAction func DoneBTN(_ sender: Any) {
        self.dismiss(sender)
    }
    
    @IBOutlet weak var CancelBTN_O: NSButton!
    
  
    @IBAction func ContinueBTN(_ sender: Any) {
        all_log = ""
        CancelBTN_O.isEnabled = false
//        port.open()
        let testCommand = ("".data(using: .utf8)! + Data([0x0A]))
        port.send(testCommand)
        usleep(10000)
        port.send(testCommand)
        self.ContinueBTN_O.isEnabled = false
        self.WarningView.isHidden = true
        self.ProcessView.isHidden = false
        self.StatusImg.image = #imageLiteral(resourceName: "inProgress")
        delay(bySeconds: 1) {
            if all_log != "" {
                var progressValue = 0.0
                self.ProgressOFRestore.doubleValue = progressValue
                DispatchQueue.global(qos: .background).async {
                    do {
                        let data = try Data(contentsOf: restoreBackupPath!)
                        let str = String(data: data, encoding: .utf8)
                        var commandArray = (str?.split(separator: "\n"))!
                        
                        // Parsing if Backup by JC or WL
                        if commandArray.count == 1{
                            print("Backup by JC or WL detected")
                            let char = String(data: Data([0x0D,0x0A]), encoding: .utf8)!
                            let char1 = char.last
                            commandArray = (str?.split(separator: char1!))!
                            print(commandArray.count)
                        }
                        
                        if commandArray.count != 0 || commandArray.count != 1 {
                        DispatchQueue.main.async {
                            self.ProgressOFRestore.minValue = 0
                            self.ProgressOFRestore.maxValue = Double((commandArray.count))
                        }
                        for command in commandArray {
                                if command.contains("syscfg add") || command.contains("rtc --set") {
                                    progressValue += 1
                                        print(String(command))
                                         let com = (String(command).data(using: .utf8)! + Data([0x0A]))
                                        port.send(com)
                                    DispatchQueue.main.async {
                                        self.CommandText.stringValue = String(command)
                                        self.ProgressOFRestore.doubleValue = progressValue
                                    }
                                    usleep(100000)
                                } else {
                                    print("Command invalid")
                            }
                            }
                            DispatchQueue.main.async {
                            if progressValue == 0 {
                                self.StatusImg.image = #imageLiteral(resourceName: "error")
                                self.CommandText.stringValue = "An error occured... Backup flash failed."
                                self.ContinueBTN_O.isHidden = true
                                self.DoneBTN_O.isHidden = false
//                                port.close()

                            } else {
                                self.StatusImg.image = #imageLiteral(resourceName: "success_colored")
                                self.ContinueBTN_O.isHidden = true
                                self.DoneBTN_O.isHidden = false
//                                port.close()
                                }
                            }
                        } else {
                            print("ERROR")
                            DispatchQueue.main.async{
                            self.ContinueBTN_O.isHidden = true
                            self.DoneBTN_O.isHidden = false
                            }
//                            port.close()

                            return
                        }
                    } catch {
                        print("An error occured:\n\(error)")
//                        port.close()

                        return

                    }
                }
                
                
            } else {
                let alert = NSAlert()
                alert.messageText = "No device connected"
                alert.informativeText = "Please check your usb connection and try again. Make sure the device is in purple mode"
                alert.beginSheetModal(for: self.view.window!) { (reponse) in
                    print("Alert sent...")
                }
                print("No connected device found")
                self.ContinueBTN_O.isEnabled = true
                self.CancelBTN_O.isEnabled = true
            }
        }

        
    }
    
}
