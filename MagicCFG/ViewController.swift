//
//  ViewController.swift
//  MagicCFG
//
//  Created by Jan Fabel on 11.06.20.
//  Copyright © 2020 Jan Fabel. All rights reserved.
//

import Cocoa
import ORSSerial
import os


var restoreBackupPath: URL?
var port = ORSSerialPortManager.shared().availablePorts[0]

var all_log = String()
var global_output = String()

var dataStat = false

var usbDelegate = true



class ViewController: NSViewController, ORSSerialPortDelegate,NSTextFieldDelegate {

    
    @IBAction func DebugNow(_ sender: Any) {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().path + "/Contents/MacOS/MagicCFG"
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["/System/Applications/Utilities/Terminal.app",path]
        task.launch()
        exit(0)
    }
    
    @IBOutlet weak var datasup: NSTextField!
    
    @IBAction func WRITENEWREGN(_ sender: Any) {
        let command = "syscfg add Regn CH/A".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        ReadSysCFGBTNFUNC(self)
    }
    
    @IBAction func WRITENEWREGNOFF(_ sender: Any) {
        let command = "syscfg add Regn LL/A".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        ReadSysCFGBTNFUNC(self)
    }
    

    
    /// Manual Port Selection
    var ports_array = [String]()
    

    
    
    @IBOutlet weak var CameraFixBTN: NSButton!
    @IBOutlet weak var UnbindWifiBTN: NSButton!
    @IBOutlet weak var OldCameraFixBTN: NSButton!
    @IBOutlet weak var NANDSizeLabel: NSTextField!
    @IBOutlet weak var WriteSN_BTN: NSButton!
    @IBOutlet weak var WriteModeBTN: NSButton!
    @IBOutlet weak var WriteRegionBTN: NSButton!
    @IBOutlet weak var WriteColorBTN: NSButton!
    @IBOutlet weak var WriteWifiBTN: NSButton!
    @IBOutlet weak var WriteBMacBTN: NSButton!
    @IBOutlet weak var WriteEMacBTN: NSButton!
    @IBOutlet weak var WriteMLBBTN: NSButton!
    @IBOutlet weak var WriteModelBTN: NSButton!
    @IBOutlet weak var WriteNVSNBTN: NSButton!
    @IBOutlet weak var WriteLCMBTN: NSButton!
    @IBOutlet weak var WriteBatteryBTN: NSButton!
    @IBOutlet weak var WriteMtSNBTN: NSButton!
    
    @IBOutlet weak var RegionField: NSTextField!
    @IBOutlet weak var SN_Field: NSTextField!
    @IBOutlet weak var ModeField: NSTextField!
    @IBOutlet weak var WifiField: NSTextField!
    @IBOutlet weak var BMacField: NSTextField!
    @IBOutlet weak var EMacField: NSTextField!
    @IBOutlet weak var MLBField: NSTextField!
    @IBOutlet weak var ModelField: NSTextField!
    @IBOutlet weak var NVSNField: NSTextField!
    @IBOutlet weak var ColorSelect: NSPopUpButton!
    @IBOutlet weak var LCMField: NSTextField!
    @IBOutlet weak var BatteryField: NSTextField!
    @IBOutlet weak var MtSNField: NSTextField!
    @IBOutlet weak var SerialConnectBTN: NSButton!
    @IBOutlet weak var OutputTextView: NSScrollView!
    @IBOutlet weak var ReadBTN: NSButton!
    @IBOutlet weak var Languages_to_select: NSPopUpButton!
    @IBOutlet weak var OutputView: NSScrollView!
    @IBOutlet var TextView_: NSTextView!
    @IBOutlet weak var RestoreBTN: NSButton!
    @IBOutlet weak var BasicFlashBTN: NSButton!
    @IBOutlet weak var BackupBTN: NSButton!
    @IBOutlet weak var DeviceSelection: NSPopUpButton!
    @IBOutlet weak var SNTick: NSButton!
    @IBOutlet weak var ModeTick: NSButton!
    @IBOutlet weak var AreaTick: NSButton!
    @IBOutlet weak var ColorTick: NSButton!
    @IBOutlet weak var WifiTick: NSButton!
    @IBOutlet weak var BMacTick: NSButton!
    @IBOutlet weak var EMacTick: NSButton!
    @IBOutlet weak var MLBTick: NSButton!
    @IBOutlet weak var ModelTick: NSButton!
    @IBOutlet weak var NVSNTick: NSButton!
    @IBOutlet weak var LCMTick: NSButton!
    @IBOutlet weak var BatteryTick: NSButton!
    @IBOutlet weak var MtSNTick: NSButton!
    @IBOutlet weak var BackupLoadingIndicator: NSProgressIndicator!
    @IBOutlet weak var DeviceAgeSet: NSButton!
    
    @IBAction func SwitchDeviceAge(_ sender: Any) {
        if DeviceAgeSet.state == .off {
            deviceAge = 1
            print("Device Age set to .normal")
        } else if DeviceAgeSet.state == .on {
            deviceAge = 2
            print("Device Age set to .legacy")
        }
    }
    
    
    @IBAction func DeselectAllBTN(_ sender: Any) {
        deselectWritingOptions()
    }
    @IBAction func WriteSelectedOptions(_ sender: Any) {
        if SNTick.state == .on {WriteSN_BTN.performClick(sender)}
        if ModeTick.state == .on {WriteModeBTN.performClick(sender)}
        if AreaTick.state == .on {WriteRegionBTN.performClick(sender)}
        if ColorTick.state == .on {WriteColorBTN.performClick(sender)}
        if WifiTick.state == .on {WriteWifiBTN.performClick(sender)}
        if BMacTick.state == .on {WriteBMacBTN.performClick(sender)}
        if EMacTick.state == .on {WriteEMacBTN.performClick(sender)}
        if MLBTick.state == .on {WriteMLBBTN.performClick(sender)}
        if ModelTick.state == .on {WriteModelBTN.performClick(sender)}
        if NVSNTick.state == .on {WriteNVSNBTN.performClick(sender)}
        if LCMTick.state == .on {WriteLCMBTN.performClick(sender)}
        if BatteryTick.state == .on {WriteBatteryBTN.performClick(sender)}
        if MtSNTick.state == .on {WriteMtSNBTN.performClick(sender)}
    }
    func deselectWritingOptions() {
        SNTick.state = .off
        ModeTick.state = .off
        AreaTick.state = .off
        ColorTick.state = .off
        WifiTick.state = .off
        BMacTick.state = .off
        EMacTick.state = .off
        MLBTick.state = .off
        ModelTick.state = .off
        NVSNTick.state = .off
        LCMTick.state = .off
        BatteryTick.state = .off
        MtSNTick.state = .off
    }
    func selectWritingOptions() {
        SNTick.state = .on
        ModeTick.state = .on
        AreaTick.state = .on
        ColorTick.state = .on
        WifiTick.state = .on
        BMacTick.state = .on
        EMacTick.state = .on
        MLBTick.state = .on
        ModelTick.state = .on
        NVSNTick.state = .on
        LCMTick.state = .on
        BatteryTick.state = .on
        MtSNTick.state = .on
    }
    @IBAction func SelectAll(_ sender: Any) {
        selectWritingOptions()
    }
    var nandSize = String()
    var log = String()
    var iPhoneColorArray_values = [String]()
    var iPhoneColorArray_keys = [String]()
    var iPhoneRegionArray_values = [String]()
    var iPhoneRegionArray_keys = [String]()
    var SN = String()
    var Mode = String()
    var Area = String()
    var Color = String()
    var ColorHousing = String()
    var Wifi = String()
    var BMac = String()
    var EMac = String()
    var MLB = String()
    var NVSN = String()
    var NSrN = String()
    var LCMHash = String()
    var Battery = String()
    var BCMS = String()
    var FCMS = String()
    var MtSN = String()
    var Model = String()
    var SysCFGBackup = String()
    let ports = ORSSerialPortManager.shared().availablePorts
    
    
    @IBAction func HomepageLinker(_ sender: Any) {
        if let url = URL(string: "https://magiccfg.com") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func RefreshSerialPort(_ sender: Any) {
        port.close()
        ports_array.removeAll()
        let ports = ORSSerialPortManager.shared().availablePorts
        for port in ports {
        ports_array.append("\(port)")
        }
        Select_Port_ITEM.removeAllItems()
        Select_Port_ITEM.addItems(withTitles: ports_array)
        Select_Port_ITEM.autoenablesItems = true
        print(ports_array)
    }
    
    
    @IBOutlet weak var Select_Port_ITEM: NSPopUpButton!
    override func viewDidAppear() {
        port = ORSSerialPortManager.shared().availablePorts[Select_Port_ITEM.indexOfSelectedItem]
        let ports = ORSSerialPortManager.shared().availablePorts
        for port in ports {
        ports_array.append("\(port)")
        }
        Select_Port_ITEM.removeAllItems()
        Select_Port_ITEM.addItems(withTitles: ports_array)
        Select_Port_ITEM.autoenablesItems = true
        print(ports_array)

    }
    
    override func viewDidDisappear() {
        exit(0)
    }
    
    /// Write buttons
    @IBAction func WriteSN(_ sender: Any) {
        var value = SN_Field.stringValue

            value.removeDangerousCharsForSYSCFG()
            let command = "syscfg add SrNm \(value)".data(using: .utf8)! + Data([0x0A])
            port.send(command)
            SN_Field.window?.makeFirstResponder(nil)

        
    }
    @IBAction func WriteMode(_ sender: Any) {
        var value = ModeField.stringValue
        value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add Mod# \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        ModeField.window?.makeFirstResponder(nil)
        
    }
    
    @IBAction func WriteRegion(_ sender: Any) {
        // Under development
        var value = RegionField.stringValue
        //value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add Regn \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        RegionField.window?.makeFirstResponder(nil)
        
    }
    @IBAction func WriteColor(_ sender: Any) {
        // needs hex, under development
        let selectedColor = ColorSelect.indexOfSelectedItem
        print(iPhoneColorArray_keys[selectedColor])
        print(iPhoneColorArray_values[selectedColor])
        let value = iPhoneColorArray_values[selectedColor]
        if Model == "A1586" || Model == "A1549" || Model == "A1589" || Model == "A1522" || Model == "A1524" || Model == "A1593" || Model == "A1633" || Model == "A1688" || Model == "A1691" || Model == "A1700" || Model == "A1634" || Model == "A1687" || Model == "A1690" || Model == "A1699" {
            let command = "syscfg add DClr \(value)".data(using: .utf8)! + Data([0x0A])
            port.send(command)
        }
        if Model == "A1660" || Model == "A1779" || Model == "A1780" || Model == "A1778" || Model == "A1661" || Model == "A1785" || Model == "A1786" || Model == "A1784" || Model == "A1863" || Model == "A1906" || Model == "A1907" || Model == "A1905" || Model == "A1864" || Model == "A1898" || Model == "A1899" || Model == "A1897" || Model == "A1865" || Model == "A1902" || Model == "A1901" {
            let command = "syscfg add CLHS \(value)".data(using: .utf8)! + Data([0x0A])
            print(command)
            port.send(command)
        }

        
        
    }
    @IBAction func WriteWifi(_ sender: Any) {
        // needs hex, under development
        var value = WifiField.stringValue
        value.removeDangerousCharsForSYSCFG()
        value = parseMactoMacHex(hex: value)
        let command = "syscfg add WMac \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        WifiField.window?.makeFirstResponder(nil)
    }
    @IBAction func WriteBMac(_ sender: Any) {
        // needs hex, under development
        var value = BMacField.stringValue
        value.removeDangerousCharsForSYSCFG()
        value = parseMactoMacHex(hex: value)
        let command = "syscfg add BMac \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        BMacField.window?.makeFirstResponder(nil)
        
    }
    @IBAction func WriteEMac(_ sender: Any) {
        // needs hex, under development
        var value = EMacField.stringValue
        value.removeDangerousCharsForSYSCFG()
        value = parseMactoMacHex(hex: value)
        let command = "syscfg add EMac \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        EMacField.window?.makeFirstResponder(nil)
        

    }
    @IBAction func WriteMLB(_ sender: Any) {
        var value = MLBField.stringValue
        value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add MLB# \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        MLBField.window?.makeFirstResponder(nil)
        
    }
    @IBAction func WriteModel(_ sender: Any) {
        var value = ModelField.stringValue
        value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add RMd# \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        ModelField.window?.makeFirstResponder(nil)
        
    }
    @IBAction func WriteNVSN(_ sender: Any) {
        var value = NVSNField.stringValue
        value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add NvSn \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        NVSNField.window?.makeFirstResponder(nil)
        
    }

    @IBAction func WriteLCMHash(_ sender: Any) {
        var value = LCMField.stringValue
        value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add LCM# \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        LCMField.window?.makeFirstResponder(nil)
        
    }
    @IBAction func WriteBattery(_ sender: Any) {
        var value = BatteryField.stringValue
        value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add Batt \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        BatteryField.window?.makeFirstResponder(nil)
        
    }

    @IBAction func WriteMtSN(_ sender: Any) {
        var value = MtSNField.stringValue
        value.removeDangerousCharsForSYSCFG()
        let command = "syscfg add MtSN \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        MtSNField.window?.makeFirstResponder(nil)
        
    }
    
    @IBAction func UnlockWifi(_ sender: Any) {
        let command = "syscfg delete WCAL".data(using: .utf8)! + Data([0x0A])
        port.send(command)
        sleep(1)
    }
    
    
/// Write buttons end

    
    @IBAction func SerialPortSelect(_ sender: Any) {
        port.close()
        print("Port Closed", logLevel:.INFO)
        SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
        
    }
    
 ///Manual command execution
    @IBOutlet weak var ManualCommandField: NSTextField!
    @IBAction func ManualCommanderPressedEnter(_ sender: Any) {
        let command = ManualCommandField.stringValue.data(using: .utf8)! + Data([0x0A])
        if log.count > 500 {
        log = ""
        }
        ManualCommandField.stringValue = ""
        port.send(command)
    }
    
   
    @IBOutlet weak var RebootBTN: NSButton!
    

    @IBAction func GoManualCommander(_ sender: Any) {
        let command = ManualCommandField.stringValue.data(using: .utf8)! + Data([0x0A])
        if log.count > 500 {
        log = ""
        }
        if ManualCommandField.stringValue.data(using: .utf8)! == Data([0x4D,0x61,0x67,0x69,0x63,0x43,0x46,0x47,0x50,0x72,0x6F]) {
            performSegue(withIdentifier: "pro", sender: nil)
            return
        }
        ManualCommandField.stringValue = ""
        port.send(command)
    }
    
    @IBAction func FixCameraSoundOld(_ sender: Any) {
        let command = "syscfg add Regn MY/A".data(using: .utf8)! + Data([0x0A])
               port.send(command)
               
               ReadBTN.performClick(sender)
               delay(bySeconds: 0.5) {
                   if self.Area == "MY/A" {
                       let alert = NSAlert()
                       alert.messageText = "Patch successful written to iDevice"
                       alert.informativeText = "For the changes to take effect, you must restore your iDevice over iTunes"
                       alert.beginSheetModal(for: self.view.window!) { (reponse) in
                           print("Camera fix successful", logLevel:.INFO)
                       }
                   } else {
                   let alert = NSAlert()
                   alert.messageText = "Patch failed"
                   alert.informativeText = "Make sure your device is connected and in Purple mode. If so, try again..."
                   alert.beginSheetModal(for: self.view.window!) { (reponse) in
                       print("Camera fix failed", logLevel:.ERROR)
                       }
                   }
               }
    }
    
    @IBAction func FixCameraSound(_ sender: Any) {
    let command = "syscfg add SwBh 0x00000011 0x00000000 0x00000000 0x00000000".data(using: .utf8)! + Data([0x0A])
            port.send(command)
            delay(bySeconds: 0.5) {
                let alert = NSAlert()
                alert.messageText = "Patch successful written to iDevice"

                alert.beginSheetModal(for: self.view.window!) { (reponse) in
                    print("Camera fix successful", logLevel:.INFO)
                }

        }
    }
    @IBAction func iCloudUnlock(_ sender: Any) {
        //SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
        
        self.performSegue(withIdentifier: "iCloud", sender: sender)
    }
    
    
    

    @IBAction func RebootiDevice(_ sender: Any) {
        let command = "reset".data(using: .utf8)! + Data([0x0A])
        port.send(command)
    }
    
    @IBAction func SysCFG_create_backup(_ sender: Any) {
        self.BackupLoadingIndicator.isHidden = false
        self.BackupLoadingIndicator.startAnimation(sender)
        
        
        
        all_log = ""
        ReadBTN.performClick(sender)
        delay(bySeconds: 2.0, dispatchLevel: .background) {
            if all_log == "" {print("Request expired.\n Failed...", logLevel:.ERROR);        DispatchQueue.main.async {
                self.BackupLoadingIndicator.isHidden = true
                self.BackupLoadingIndicator.stopAnimation(sender)
            };return}
        }
        delay(bySeconds: 2.0) {
            all_log = ""

                   let command = "syscfg list".data(using: .utf8)! + Data([0x0A])
            port.send(command)
                   
                   if port.isOpen == false {        DispatchQueue.main.async {
//                           self.BackupLoadingIndicator.isHidden = true
//                    self.BackupLoadingIndicator.stopAnimation(sender)
                    };return}
                   DispatchQueue.global(qos: .background).async {
                           var count = Int()
                           while all_log.suffix(4) != ":-) " {
                           count += 1
                           print("Waiting now for \(count) second(s)...")
                           sleep(1)
                            if count == 2 && all_log == "" {print("Request expired.\n Failed...", logLevel:.ERROR);DispatchQueue.main.async {
                                self.BackupLoadingIndicator.isHidden = true
                                self.BackupLoadingIndicator.stopAnimation(sender)
                            }; return}
                            if count > 20 {print("Request expired.\n Failed...", logLevel:.ERROR);DispatchQueue.main.async {
                                self.BackupLoadingIndicator.isHidden = true
                                self.BackupLoadingIndicator.stopAnimation(sender)
                            }; return}
                           }
                       if port.isOpen == false {DispatchQueue.main.async {
                               self.BackupLoadingIndicator.isHidden = true
                               self.BackupLoadingIndicator.stopAnimation(sender)
                           };return}
                      
                           if all_log.suffix(4) == ":-) "{
                               let str = all_log
                            var raw1 = String()

                            if self.deviceAge == 1 {
                                guard let first_index = str.endIndex(of: "list\n") else {print("ERROR");DispatchQueue.main.async {
                                    self.BackupLoadingIndicator.isHidden = true
                                    self.BackupLoadingIndicator.stopAnimation(sender)
                                }; return}
                                guard let second_index = str.index(of: "\n[") else {print("ERROR");DispatchQueue.main.async {
                                    self.BackupLoadingIndicator.isHidden = true
                                    self.BackupLoadingIndicator.stopAnimation(sender)
                                }; return}
                                raw1 = String(str[first_index...second_index])
                            }
                            if self.deviceAge == 2 {
                                guard let first_index = str.endIndex(of: "list\n") else {print("ERROR");DispatchQueue.main.async {
                                    self.BackupLoadingIndicator.isHidden = true
                                    self.BackupLoadingIndicator.stopAnimation(sender)
                                }; return}
                                guard let second_index = str.index(of: "\n:-)") else {print("ERROR");DispatchQueue.main.async {
                                    self.BackupLoadingIndicator.isHidden = true
                                    self.BackupLoadingIndicator.stopAnimation(sender)
                                }; return}
                                raw1 = String(str[first_index...second_index])
                            }
                               raw1 = raw1.replacingOccurrences(of: "Key:", with: "syscfg add")
                               raw1 = raw1.replacingOccurrences(of: "Value: ", with: "")
                               //print(raw1)
                               var backupArray = [String]()
                               let lines = raw1.split(separator: "\n")
                               for line in lines {
                                 // do stuff with each line
                                   if !line.contains("Not Found") {
                                       backupArray.append(String(line))
                                   }
                               }
                               var backupSTR = String()
                               for line in backupArray {
                                   backupSTR += (line + "\n")
                               }
                               print(backupSTR)
                               DispatchQueue.main.async {
                                   if backupSTR != "" {
                                       let SaveToFile = NSSavePanel()
                                       SaveToFile.allowedFileTypes = ["txt"]
                                    SaveToFile.nameFieldStringValue = "\(self.DetectedDevice.stringValue)_\(self.Model)_\(self.SN)"
                                       SaveToFile.begin { (result) -> Void in

                                           if result.rawValue == NSFileHandlingPanelOKButton {
                                               let filename = SaveToFile.url

                                               do {
                                                   try backupSTR.write(to: filename!, atomically: true, encoding: String.Encoding.utf8)
                                                   print("Successfully written to \(filename!)", logLevel:.INFO)
                                                DispatchQueue.main.async {
                                                    self.BackupLoadingIndicator.isHidden = true
                                                    self.BackupLoadingIndicator.stopAnimation(sender)
                                                };
                                               } catch {
                                                DispatchQueue.main.async {
                                                    self.BackupLoadingIndicator.isHidden = true
                                                    self.BackupLoadingIndicator.stopAnimation(sender)
                                                };
                                                   // failed to write file (bad permissions, bad filename etc.)
                                                   print("Failed to write to \(filename!)...\n Please check your write permissions or contact the developer!", logLevel:.ERROR)
                                               }

                                           } else {
                                               print("Canceled", logLevel:.INFO)
                                            DispatchQueue.main.async {
                                                           self.BackupLoadingIndicator.isHidden = true
                                                           self.BackupLoadingIndicator.stopAnimation(sender)
                                                       };
                                           }
                                        DispatchQueue.main.async {
                                                       self.BackupLoadingIndicator.isHidden = true
                                                       self.BackupLoadingIndicator.stopAnimation(sender)
                                                   };
                                       }
                                    DispatchQueue.main.async {
                                                   self.BackupLoadingIndicator.isHidden = true
                                                   self.BackupLoadingIndicator.stopAnimation(sender)
                                               };
                                   }
                                DispatchQueue.main.async {
                                               self.BackupLoadingIndicator.isHidden = true
                                               self.BackupLoadingIndicator.stopAnimation(sender)
                                           };
                               }
                            DispatchQueue.main.async {
                                           self.BackupLoadingIndicator.isHidden = true
                                           self.BackupLoadingIndicator.stopAnimation(sender)
                                       };
                           }
                       }
                       
                   
        }
         
    }
    
    @IBAction func SysCFG_Restore_Backup(_ sender: Any) {

        restoreBackupPath = URL(string: "")
        let openFile = NSOpenPanel()
        openFile.allowsMultipleSelection = false
        openFile.canChooseDirectories = false
        openFile.canCreateDirectories = false
        openFile.canChooseFiles = true
        openFile.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                //Do what you will
                restoreBackupPath = openFile.url
                self.performSegue(withIdentifier: "restoreBackup", sender: sender)
            }
        }
    }
    
    @IBAction func BasicFlashTemplate(_ sender: Any) {
        let selectedItem = DeviceSelection.titleOfSelectedItem
        let path = Bundle.main.resourcePath
        let template_path = path! + "/SYSCFG_TEMPLATES/"
        let path_ = template_path + selectedItem!
        print(path_)
        do {
            let file = try NSData(contentsOfFile: path_)
            let str = String(data: file as! Data, encoding: .utf8)
                var commandArray = (str?.split(separator: "\n"))!
                
                // Parsing if Backup by JC or WL
                if commandArray.count == 1{
                    print("Backup by JC or WL detected")
                    let char = String(data: Data([0x0D,0x0A]), encoding: .utf8)!
                    let char1 = char.last
                    commandArray = (str?.split(separator: char1!))!
                    print(commandArray.count)
                }
                for command in commandArray {
                    if command.contains("syscfg") || command.contains("rtc --set") {
                            print(String(command))
                             let com = (String(command).data(using: .utf8)! + Data([0x0A]))
                            port.send(com)
                    } else {
                        print("Command invalid")
                }
            }
            parseColor()
            
        } catch {
            print(error)
        }
    
    }
    
    /// SYSCFG GET FUNCTIONS READ
    var deviceAge = Int()
    
    @IBAction func ReadSysCFGBTNFUNC(_ sender: Any) {
        SN_Field.stringValue = ""
        ModeField.stringValue = ""
        WifiField.stringValue = ""
        BMacField.stringValue = ""
        RegionField.stringValue = ""
        EMacField.stringValue = ""
        MLBField.stringValue = ""
        ModelField.stringValue = ""
        NVSNField.stringValue = ""
        LCMField.stringValue = ""
        BatteryField.stringValue = ""
        MtSNField.stringValue = ""
        all_log = ""
       let descriptor = ORSSerialPacketDescriptor(prefixString: "syscfg", suffixString: "\n[", maximumPacketLength: 150, userInfo: nil)
        let nandsizedescriptor = ORSSerialPacketDescriptor(prefixString: "NAND SIZE :", suffixString: "\n[", maximumPacketLength: 150, userInfo: nil)
        let Alt_descriptor = ORSSerialPacketDescriptor(prefixString: "syscfg", suffixString: ":-)", maximumPacketLength: 150, userInfo: nil)
        let Alt_nandsizedescriptor = ORSSerialPacketDescriptor(prefixString: "NAND SIZE :", suffixString: ":-)", maximumPacketLength: 150, userInfo: nil)

        if deviceAge == 1 {
            port.startListeningForPackets(matching: descriptor)
            port.startListeningForPackets(matching: nandsizedescriptor)
            
        }
        if deviceAge == 2 {
            port.startListeningForPackets(matching: Alt_descriptor)
            port.startListeningForPackets(matching: Alt_nandsizedescriptor)
        }
        if deviceAge == 3 {
        }
        self.get_SN()
        self.get_MLB()
        self.get_Area()
        self.get_BCMS()
        self.get_BMac()
        self.get_EMac()
        self.get_FCMS()
        self.get_Mode()
        self.get_MtSN()
        self.get_NSrN()
        self.get_NVSN()
        self.get_Wifi()
        self.get_Color()
        self.get_ColorHousing()
        self.get_Model()
        self.get_Battery()
        self.get_LCMHash()
        self.get_nandSize()

        delay(bySeconds: 0.5, dispatchLevel: .background) { [self] in
            
            DispatchQueue.main.async {
                let Temp_back =  "\nSerial: \(SN_Field.stringValue)\nMode: \(ModeField.stringValue)\nWMAC: \(WifiField.stringValue)\nBMac: \(BMacField.stringValue)\nEMac: \(EMacField.stringValue)\nMLB: \(MLBField.stringValue)\nRegion: \(RegionField.stringValue)\nModel: \(ModelField.stringValue)\nNVSN: \(NVSNField.stringValue) \nLCM#: \(LCMField.stringValue)\nBattery: \(BatteryField.stringValue)\nMtSN: \(MtSNField.stringValue)"
                
                
                print("[SYSCFG LOG]:\(Temp_back)", logLevel:.INFO)
            }
            port.stopListeningForPackets(matching: descriptor)
            port.stopListeningForPackets(matching: nandsizedescriptor)
            port.stopListeningForPackets(matching: Alt_nandsizedescriptor)
            port.stopListeningForPackets(matching: Alt_descriptor)
        }
    }
    private func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
    @IBAction func ClearBTN(_ sender: Any) {
        cleanAll()
    }
    func cleanAll() {
        SN_Field.stringValue = ""
        ModeField.stringValue = ""
        WifiField.stringValue = ""
        BMacField.stringValue = ""
        EMacField.stringValue = ""
        MLBField.stringValue = ""
        RegionField.stringValue = ""
        ModelField.stringValue = ""
        NVSNField.stringValue = ""
        LCMField.stringValue = ""
        BatteryField.stringValue = ""
        MtSNField.stringValue = ""
    }
    
    
    func get_SN() {
    let command = "syscfg print SrNm".data(using: .utf8)! + Data([0x0A])
    port.send(command)}
    
    func get_Mode()  {let command = "syscfg print Mod#".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_Area()  {let command = "syscfg print Regn".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_Color()  {let command = "syscfg print DClr".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_ColorHousing()  {let command = "syscfg print CLHS".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_Wifi()  {let command = "syscfg print WMac".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_BMac()  {let command = "syscfg print BMac".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_EMac()  {let command = "syscfg print EMac".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_MLB()  {let command = "syscfg print MLB#".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_Model()  {let command = "syscfg print RMd#".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_NVSN()  {let command = "syscfg print NvSn".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_NSrN()  {let command = "syscfg print NSrN".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_LCMHash()  {let command = "syscfg print LCM#".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_Battery()  {let command = "syscfg print Batt".data(using: .utf8)! + Data([0x0A])
    port.send(command)}
    
    func get_BCMS()  {let command = "syscfg print BCMS".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_FCMS()  {let command = "syscfg print FCMS".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_MtSN()  {let command = "syscfg print MtSN".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_nandSize()  {let command = "nandsize".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
        
    @IBOutlet weak var DetectModelView: NSView!
    @IBOutlet weak var DetectNandSizeView: NSView!
    func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
         let output = String(data: packetData, encoding: .utf8)
        global_output = output!
        //print(output!)
        if (output?.contains("list"))! {
            SysCFGBackup = output!
            print(output)
        }
        if (output?.contains("NAND"))! {
            switch deviceAge {
            case 1:
            nandSize = output!
            nandSize = nandSize.replacingOccurrences(of: "NAND SIZE :0x", with: "")
            nandSize.removeLast(2)
            let result = UInt64(nandSize, radix:16)
            let actualNANDSize = (result! * 1024) / 1000000000
            nandSize = "\(actualNANDSize)GB"
            print(nandSize)
            NANDSizeLabel.stringValue = nandSize
            
            case 2:
                nandSize = output!
                nandSize = nandSize.replacingOccurrences(of: "NAND SIZE :0x", with: "")
                print("Start " + nandSize + " End")
                nandSize.removeLast(4)
                print("Start " + nandSize + " End")
                let result = UInt64(nandSize, radix:16)
                let actualNANDSize = (result! * 1024) / 1000000000
                nandSize = "\(actualNANDSize)GB"
                print(nandSize)
                NANDSizeLabel.stringValue = nandSize
                
            
            default: NANDSizeLabel.stringValue = "ERROR"
            }

        }
        if (output?.contains("SrNm"))! {
            SN = output!
            SN = remove_the_fucking_chars(func_key: "SrNm", key: SN)
            SN = SN.replacingOccurrences(of: "Serial: ", with: "")
            SN.removeDangerousCharsForSYSCFG()
            if deviceAge == 2 {
                SN.removeLast()
            }
            SN_Field.stringValue = SN
        }
        if (output?.contains("Mod#"))! {
            Mode = output!
            Mode = remove_the_fucking_chars(func_key: "Mod#", key: Mode)
            Mode.removeDangerousCharsForSYSCFG()
            if deviceAge == 2 {
                Mode.removeLast()
            }
            if !Mode.contains("NotFound") {
                ModeField.stringValue = Mode
            }
        }
        if (output?.contains("Regn"))! {
            Area = output!
            Area = remove_the_fucking_chars(func_key: "Regn", key: Area)
            Area = Area.replacingOccurrences(of: " ", with: "")
            RegionField.stringValue = Area
            if RegionField.stringValue == "CH/A" {
                datasup.stringValue = "ON"
            } else {
                datasup.stringValue = "OFF"
            }
        }
        if (output?.contains("DClr"))! {
            Color = output!
            Color = remove_the_fucking_chars(func_key: "DClr", key: Color)
            Color.removeLast()
           
        }
        if (output?.contains("CLHS"))! {
            ColorHousing = output!
            ColorHousing = remove_the_fucking_chars(func_key: "CLHS", key: ColorHousing)
            print(ColorHousing)
            ColorHousing.removeLast()
        }
        if (output?.contains("WMac"))! {
            Wifi = output!
            Wifi = remove_the_fucking_chars(func_key: "WMac", key: Wifi)
            Wifi = makeHEX(input: Wifi)
            Wifi.removeDangerousCharsForSYSCFG()
            Wifi = String(Wifi.prefix(12))
            Wifi = Wifi.inserting(separator: ":", every: 2)
            WifiField.stringValue = Wifi
        }
        if (output?.contains("BMac"))! {
            BMac = output!
            BMac = remove_the_fucking_chars(func_key: "BMac", key: BMac)
            BMac = makeHEX(input: BMac)
            BMac.removeDangerousCharsForSYSCFG()
            BMac = String(BMac.prefix(12))
            BMac = BMac.inserting(separator: ":", every: 2)
            BMacField.stringValue = BMac
        }
        if (output?.contains("EMac"))! {
            EMac = output!
            EMac = remove_the_fucking_chars(func_key: "EMac", key: EMac)
            EMac = makeHEX(input: EMac)
            EMac.removeDangerousCharsForSYSCFG()
            print(EMac)
            EMac = String(EMac.prefix(12))
            EMac = EMac.inserting(separator: ":", every: 2)
            EMacField.stringValue = EMac
        }
        if (output?.contains("MLB#"))! {
            MLB = output!
            MLB = remove_the_fucking_chars(func_key: "MLB#", key: MLB)
            MLB.removeDangerousCharsForSYSCFG()
            if deviceAge == 2 {
                MLB.removeLast()
            }
            MLBField.stringValue = MLB
        }
        if (output?.contains("RMd#"))! {
            Model = output!
            Model = remove_the_fucking_chars(func_key: "RMd#", key: Model)
            Model.removeDangerousCharsForSYSCFG()
            if deviceAge == 2 {
                Model.removeLast()
            }
            ModelField.stringValue = Model
            getModelInfo(model: Model)
            parseColor()
        }
        if (output?.contains("NvSn"))! {
            NVSN = output!
            NVSN = remove_the_fucking_chars(func_key: "NvSn", key: NVSN)
            NVSN.removeDangerousCharsForSYSCFG()
            NVSNField.stringValue = NVSN
        }

        if (output?.contains("LCM#"))! {
            LCMHash = output!
            LCMHash = remove_the_fucking_chars(func_key: "LCM#", key: LCMHash)
            LCMHash.removeDangerousCharsForSYSCFG()
            LCMField.stringValue = LCMHash
        }
        if (output?.contains("Batt"))! {
            Battery = output!
            Battery = remove_the_fucking_chars(func_key: "Batt", key: Battery)
            Battery.removeDangerousCharsForSYSCFG()
            BatteryField.stringValue = Battery
        }

        if (output?.contains("MtSN"))! {
            MtSN = output!
            MtSN = remove_the_fucking_chars(func_key: "MtSN", key: MtSN)
            MtSN.removeDangerousCharsForSYSCFG()
            if deviceAge == 2 {
                MtSN.removeLast()
            }
            MtSNField.stringValue = MtSN
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-_:").inverted as NSCharacterSet
        let wifiSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefABCDEF0123456789").inverted as NSCharacterSet
        self.SN_Field.stringValue =  (self.SN_Field.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "").uppercased()
        
        self.WifiField.stringValue = String((self.WifiField.stringValue.components(separatedBy: wifiSet as CharacterSet) as NSArray).componentsJoined(by: "").uppercased().pairs.joined(separator: ":")[...16])
        
        self.BMacField.stringValue = String((self.BMacField.stringValue.components(separatedBy: wifiSet as CharacterSet) as NSArray).componentsJoined(by: "").uppercased().pairs.joined(separator: ":")[...16])
        
        self.EMacField.stringValue = String((self.EMacField.stringValue.components(separatedBy: wifiSet as CharacterSet) as NSArray).componentsJoined(by: "").uppercased().pairs.joined(separator: ":")[...16])
    }
    

    /// Button to Connect/Disconnect from serial shell
    @IBAction func SerialConnectBTNFUNC(_ sender: Any) {
        port = ORSSerialPortManager.shared().availablePorts[Select_Port_ITEM.indexOfSelectedItem]
            port.baudRate = 115200
            print(port.baudRate)
            port.delegate = self
            print(port.path)
                if (port.isOpen) {
                    port.close()
                    portisClosed()
                    print("Serial connection closed")
                    SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
                } else {
                    SerialConnectBTN.title = NSLocalizedString("Disconnect", comment: "")
                    port.open()
                    portisOpened()
                    print("Serial connection opened")
            }
    }
    
    
    
    @IBAction func SetLanguage(_ sender: Any) {
        switch Languages_to_select.indexOfSelectedItem {
            case 0: UserDefaults.standard.set( ["en"], forKey: "AppleLanguages" )
            case 1: UserDefaults.standard.set( ["zh-HK"], forKey: "AppleLanguages" )
        default: break
        }
    
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
        
    
    func scrollTextViewToBottom(textView: NSTextView) {
        if textView.string.count > 0 {
            let location = textView.string.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
   
    func portisClosed() {
        ReadBTN.isEnabled = false
        BackupBTN.isEnabled = false
        RestoreBTN.isEnabled = false
        BasicFlashBTN.isEnabled = false
        CameraFixBTN.isEnabled = false
        OldCameraFixBTN.isEnabled = false
        UnbindWifiBTN.isEnabled = false
        RebootBTN.isEnabled = false
    }
    func portisOpened() {
        ReadBTN.isEnabled = true
        BackupBTN.isEnabled = true
        RestoreBTN.isEnabled = true
        BasicFlashBTN.isEnabled = true
        CameraFixBTN.isEnabled = true
        OldCameraFixBTN.isEnabled = true
        UnbindWifiBTN.isEnabled = true
        RebootBTN.isEnabled = true
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("Serial closed")
        SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
    }
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("SerialPort \(serialPort) encountered an error: \(error)", logLevel:.ERROR)
        SerialConnectBTN.title = NSLocalizedString("Connect", comment: "")
            DispatchQueue.main.async {
                self.portisClosed()
            }
        
    }
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
            guard let string = String(data: data, encoding: .utf8) else { return }
        if unsupportedCable.state == .off {
            all_log += string
            if log.count > 2000 {
            log = ""
            }
            self.log += string + String(data: Data([0x0A]), encoding: .utf8)!
            DispatchQueue.main.async {
                self.TextView_.string = self.log
                self.scrollTextViewToBottom(textView: self.TextView_)
            }
        } else
            {
                all_log += string
            }

    }

    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        print("Command timed out!", logLevel:.ERROR)
    }

    
    @IBOutlet weak var MagicCFG_Version_LBL: NSTextField!
    
    @IBOutlet weak var unsupportedCable: NSButton!
    override func viewDidLoad() {
        setLanguage()
        deviceAge = 1
        self.BackupLoadingIndicator.isHidden = true
        portisClosed()
        super.viewDidLoad()
        let fm = FileManager.default
        let path = Bundle.main.resourcePath
        let template_path = path! + "/SYSCFG_TEMPLATES/"
        let files = try! fm.contentsOfDirectory(atPath: template_path)
        DeviceSelection.addItems(withTitles: files.sorted())
        print(files)
        port.delegate = self
        self.SN_Field.delegate = self
        self.ModeField.delegate = self
        self.WifiField.delegate = self
        self.BMacField.delegate = self
        self.EMacField.delegate = self
        self.MLBField.delegate = self
        self.ModelField.delegate = self
        self.NVSNField.delegate = self
        self.LCMField.delegate = self
        self.BatteryField.delegate = self
        self.MtSNField.delegate = self
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as! String
        MagicCFG_Version_LBL.stringValue = version


        ManualCommandField.delegate = self
        // Do any additional setup after loading the view.
        let ports = ORSSerialPortManager.shared().availablePorts
        for port in ports {
        ports_array.append("\(port)")
        }
        Select_Port_ITEM.removeAllItems()
        
        if ports_array.count <= 0 {return}
        Select_Port_ITEM.addItems(withTitles: ports_array)
        Select_Port_ITEM.autoenablesItems = true
        print(ports_array)
        
    }

    
    
    func setLanguage() {
        if (UserDefaults.standard.stringArray(forKey: "AppleLanguages") == ["en"]) {
            Languages_to_select.selectItem(at: 0)
        }
        if (UserDefaults.standard.stringArray(forKey: "AppleLanguages") == ["zh-HK"]) {
           Languages_to_select.selectItem(at: 1)
            }
    }
    
    @IBOutlet weak var DetectedDevice: NSTextField!
    func getModelInfo(model: String) {
        let searchedModel = model
        guard let path = Bundle.main.url(forResource: "devices", withExtension: "json") else {return}
        do {
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            let json = try decoder.decode([deviceModels].self, from: data)
            for device in json {
                for model in device.ANumber {
                    if searchedModel == model{
                        print("SUCCESS")
                        print(model)
                        DispatchQueue.main.async {
                            self.DetectedDevice.stringValue = device.name
                        }
                        break
                        
                    }
                }
            }
            return
        } catch {
            print(error)
            return
        }
    }
    
    func makeHEX(input: String) -> String {
        let input = input
        var output = String()
        let parts = input.split(separator: " ")
        for hexstring in parts {
            print(hexstring)
            var fixedhexstring = hexstring.replacingOccurrences(of: "0x", with: "")
            while fixedhexstring.count != 0 {
                let hexpair = String(fixedhexstring.suffix(2))
                if !(fixedhexstring.count < 2) {
                    fixedhexstring.removeLast(2)
                } else {
                    break
                }
                
                output.append(hexpair)
            }
        }
        //print(output)
        return output
    }
    
    @IBAction func factReset(_ sender: Any) {
        factoryResetDevice()
    }
    func factoryResetDevice() {
    }
    
    
    func parseColor() {
        ColorSelect.isEnabled = false
        WriteColorBTN.isEnabled = false
        iPhoneColorArray_keys = ["LOL"]
        iPhoneColorArray_values = ["LOL"]
        iPhoneColorArray_keys.removeAll()
        iPhoneColorArray_values.removeAll()
        
        /// iPhone 6
        if Model == "A1586" || Model == "A1549" || Model == "A1589" {
            print("Found iPhone 6")
            ColorSelect.removeAllItems()
            iPhoneColorArray_values = Array(iPhone6_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhone6_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print(Color)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                if color == Color {
                    print(index)
                    ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                    if ColorSelect.itemTitles.contains("Unknown") {
                        ColorSelect.removeItem(withTitle: "Unknown")
                    }
                    break
                } else {
                    ColorSelect.setTitle("Unknown")
                }
            
            }
            ColorSelect.isEnabled = true
            WriteColorBTN.isEnabled = true
        }

        /// iPhone 6plus
        if Model == "A1522" || Model == "A1524" || Model == "A1593" {
            print("Found iPhone 6+")
            ColorSelect.removeAllItems()
            iPhoneColorArray_values = Array(iPhone6plus_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhone6plus_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print(Color)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                if color == Color {
                    print(index)
                    ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                    if ColorSelect.itemTitles.contains("Unknown") {
                        ColorSelect.removeItem(withTitle: "Unknown")
                    }
                    break
                }else {
                    ColorSelect.setTitle("Unknown")
                }
            }
            ColorSelect.isEnabled = true
            WriteColorBTN.isEnabled = true
        }
        
        /// iPhone 6S
        if Model == "A1633" || Model == "A1688" || Model == "A1691" || Model == "A1700" {
            print("Found iPhone 6s")
            ColorSelect.removeAllItems()
            print("Cleaned menu list")
            iPhoneColorArray_values = Array(iPhone6S_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhone6S_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print("added to menu list")
            print(Color)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                if color == Color {
                    print(index)
                    ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                    if ColorSelect.itemTitles.contains("Unknown") {
                        ColorSelect.removeItem(withTitle: "Unknown")
                    }
                    break
                }else {
                    ColorSelect.setTitle("Unknown")
                }
            }
            ColorSelect.isEnabled = true
            WriteColorBTN.isEnabled = true
        }
        
        /// iPhone 6Splus
        if Model == "A1634" || Model == "A1687" || Model == "A1690" || Model == "A1699" {
            print("Found iPhone 6s+")
            ColorSelect.removeAllItems()
            iPhoneColorArray_values = Array(iPhone6Splus_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhone6Splus_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print(Color)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                    if color == Color {
                        print(index)
                        ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                        if ColorSelect.itemTitles.contains("Unknown") {
                            ColorSelect.removeItem(withTitle: "Unknown")
                        }
                        break
                    }else {
                        ColorSelect.setTitle("Unknown")
                    }
                }
                ColorSelect.isEnabled = true
                WriteColorBTN.isEnabled = true
        }
        /// iPhone 7
        if Model == "A1660" || Model == "A1779" || Model == "A1780" || Model == "A1778" {
            print("Found iPhone 7")
            ColorSelect.removeAllItems()
            iPhoneColorArray_values = Array(iPhone7_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhone7_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print(Color)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                    if color == ColorHousing {
                        print(index)
                        ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                        if ColorSelect.itemTitles.contains("Unknown") {
                            ColorSelect.removeItem(withTitle: "Unknown")
                        }
                        break
                    }else {
                        ColorSelect.setTitle("Unknown")
                    }
                }
                ColorSelect.isEnabled = true
                WriteColorBTN.isEnabled = true
        }
        
        /// iPhone 7plus
        if Model == "A1661" || Model == "A1785" || Model == "A1786" || Model == "A1784" {
            print("Found iPhone 7+")
            ColorSelect.removeAllItems()
            iPhoneColorArray_values = Array(iPhone7_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhone7_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print(Color)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                    if color == ColorHousing {
                        print(index)
                        ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                        if ColorSelect.itemTitles.contains("Unknown") {
                            ColorSelect.removeItem(withTitle: "Unknown")
                        }
                        break
                    }else {
                        ColorSelect.setTitle("Unknown")
                    }
                }
                ColorSelect.isEnabled = true
                WriteColorBTN.isEnabled = true
        }

        /// iPhone 8
        if Model == "A1863" || Model == "A1906" || Model == "A1907" || Model == "A1905" {
            print("Found iPhone 8")
            ColorSelect.removeAllItems()
            iPhoneColorArray_values = Array(iPhone8_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhone8_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print(Color)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                    if color == ColorHousing {
                        print(index)
                        ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                        if ColorSelect.itemTitles.contains("Unknown") {
                            ColorSelect.removeItem(withTitle: "Unknown")
                        }
                        break
                    }else {
                        ColorSelect.setTitle("Unknown")
                    }
                }
                ColorSelect.isEnabled = true
                WriteColorBTN.isEnabled = true
        }

        /// iPhone 8plus
        if Model == "A1864" || Model == "A1898" || Model == "A1899" || Model == "A1897" {
            print("Found iPhone 8+")
            ColorSelect.removeAllItems()
            iPhoneColorArray_values = Array(iPhone8plus_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhone8plus_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print(Color)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                    if color == ColorHousing {
                        print(index)
                        ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                        if ColorSelect.itemTitles.contains("Unknown") {
                            ColorSelect.removeItem(withTitle: "Unknown")
                        }
                        break
                    }else {
                        ColorSelect.setTitle("Unknown")
                    }
                }
                ColorSelect.isEnabled = true
                WriteColorBTN.isEnabled = true
        }
        /// iPhone X
        if Model == "A1865" || Model == "A1902" || Model == "A1901" {
            print("Found iPhone X")
            ColorSelect.removeAllItems()
            iPhoneColorArray_values = Array(iPhoneX_color.values)
            print(iPhoneColorArray_values)
            iPhoneColorArray_keys = Array(iPhoneX_color.keys)
            print(iPhoneColorArray_keys)
            ColorSelect.addItems(withTitles: iPhoneColorArray_keys)
            print(ColorHousing)
            for (index, color) in iPhoneColorArray_values.enumerated(){
                    if color == ColorHousing {
                        print(index)
                        ColorSelect.selectItem(withTitle: iPhoneColorArray_keys[index])
                        if ColorSelect.itemTitles.contains("Unknown") {
                            ColorSelect.removeItem(withTitle: "Unknown")
                        }
                        break
                    }else {
                        ColorSelect.setTitle("Unknown")
                    }
                }
                ColorSelect.isEnabled = true
                WriteColorBTN.isEnabled = true
        }
    }
    

}


