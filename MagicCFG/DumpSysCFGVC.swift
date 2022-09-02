//
//  DumpSysCFGVC.swift
//  MagicCFG
//
//  Created by Jan Fabel on 12.06.22.
//  Copyright © 2022 Jan Fabel. All rights reserved.
//


import Cocoa
import ORSSerial
import Menu


class DumpSysCFGVC: NSViewController, ORSSerialPortDelegate {
        
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("Port removed")
        addOutputLog(string: "Important information: Serial port was removed... You may need to reselect it...\n")
    }
    @IBOutlet var outputLog: NSTextView!

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(self)
    }
    
    func get_SN() {
    let command = "syscfg print SrNm".data(using: .utf8)! + Data([0x0A])
    port.send(command)}
    
    func get_Wifi()  {let command = "syscfg print WMac".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func get_BMac()  {let command = "syscfg print BMac".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    func get_EMac()  {let command = "syscfg print EMac".data(using: .utf8)! + Data([0x0A, 0x0D])
    port.send(command)}
    
    func readNANDcfg() {
        let descriptor = ORSSerialPacketDescriptor(prefixString: "syscfg", suffixString: "\n[", maximumPacketLength: 150, userInfo: nil)
        port.startListeningForPackets(matching: descriptor)
        self.get_SN()
        self.get_Wifi()
        self.get_BMac()
        self.get_EMac()
        
        DispatchQueue.global(qos: .background).async {
            sleep(1)
            port.stopListeningForPackets(matching: descriptor)
        }
        
    }
    @IBOutlet weak var SN_NAND: NSTextField!
    @IBOutlet weak var WMAC_NAND: NSTextField!
    @IBOutlet weak var BMAC_NAND: NSTextField!
    @IBOutlet weak var EMAC_NAND: NSTextField!
    
    @IBOutlet weak var seal_btn: NSButton!
    @IBAction func use_seal(_ sender: Any) {
        uselessValue = 0
        seal_btn.state = .on
        bbpv_btn.state = .off
        
    }
    
    @IBOutlet weak var bbpv_btn: NSButton!
    @IBAction func use_bbpv(_ sender: Any) {
        uselessValue = 1
        seal_btn.state = .off
        bbpv_btn.state = .on
    }
    
    @IBAction func refresh(_ sender: Any) {
        let ports = ORSSerialPortManager.shared().availablePorts
        myMenu.removeAllItems()
        myFlashMenu.removeAllItems()

        for port_ in ports {
            myMenu.addItem(MenuItem("\(port_)",image: NSImage(named: "vga"), action: { [self] in
                port = port_
                port.baudRate = 115200
                port.delegate = self
                print(port.path)
                port.open()
                print("Serial connection opened")
                if !port.isOpen {
                    addOutputLog(string: "Serial port could no be openened...\n")
                    return
                }
                seal_fn.removeAll()
                bbpv_fn.removeAll()
                EMAC_NAND.backgroundColor = NSColor.clear
                WMAC_NAND.backgroundColor = NSColor.clear
                BMAC_NAND.backgroundColor = NSColor.clear
                SN_NAND.backgroundColor = NSColor.clear
                

                outputLog.string.removeAll()
                    progressSpinner.isHidden = false
                    progressSpinner.startAnimation(self)
                DispatchQueue.global(qos: .background).async { [self] in
                    if uselessValue == 0 {
                        downloadSyscfg(sealPath: getSeal())
                    } else {
                        downloadSyscfg(bbpvPath: getBBPV())
                    }
                    readNANDcfg()
                    sleep(1)
                    checkDifference()
                    DispatchQueue.main.async { [self] in
                        progressSpinner.isHidden = true
                        progressSpinner.stopAnimation(self)
                    }
                    port.close()
                }
                
            }))
            myFlashMenu.addItem(MenuItem("\(port_)",image: NSImage(named: "vga"), action: { [self] in
                port = port_
                port.baudRate = 115200
                port.delegate = self
                print(port.path)
                port.open()
                print("Serial connection opened")
                if !port.isOpen {
                    addOutputLog(string: "Serial port could no be openened...\n")
                    return
                }
                seal_fn.removeAll()
                bbpv_fn.removeAll()
                WMAC_NAND.backgroundColor = NSColor.clear
                BMAC_NAND.backgroundColor = NSColor.clear
                SN_NAND.backgroundColor = NSColor.clear
                EMAC_NAND.backgroundColor = NSColor.clear
                outputLog.string.removeAll()
                progressSpinner.isHidden = false
                progressSpinner.startAnimation(self)
                writeSN()
                writeWMAC()
                writeBMAC()
                writeEMAC()
                DispatchQueue.global(qos: .background).async { [self] in
                    if uselessValue == 0 {
                        downloadSyscfg(sealPath: getSeal())
                    } else {
                        downloadSyscfg(bbpvPath: getBBPV())
                    }
                    readNANDcfg()
                    sleep(1)
                    checkDifference()
                    DispatchQueue.main.async { [self] in
                        progressSpinner.isHidden = true
                        progressSpinner.stopAnimation(self)
                    }
                    port.close()
                }
                
            }))
        }
    }
    
    
    var uselessValue = 0
    
    
    @IBAction func startExtracting(_ sender: Any) {
        progressSpinner.isHidden = false
        progressSpinner.startAnimation(self)
        seal_fn.removeAll()
        bbpv_fn.removeAll()
        WMAC_NAND.backgroundColor = NSColor.clear
        BMAC_NAND.backgroundColor = NSColor.clear
        SN_NAND.backgroundColor = NSColor.clear
        EMAC_NAND.backgroundColor = NSColor.clear
        outputLog.string.removeAll()
        DispatchQueue.global(qos: .background).async { [self] in
            if uselessValue == 0 {
                downloadSyscfg(sealPath: getSeal())
            } else {
                downloadSyscfg(bbpvPath: getBBPV())
            }
            readNANDcfg()
            sleep(1)
            checkDifference()
            DispatchQueue.main.async { [self] in
                progressSpinner.isHidden = true
                progressSpinner.stopAnimation(self)
            }
        }
    }
    @IBAction func diagBootSwitchBack(_ sender: Any) {
        performSegue(withIdentifier: "diags", sender: nil)
        view.window?.close()
    }
    
    func extractSysCFG() -> Int {
        return 0
    }
    
  private let myMenu = Menu(with: "Select a serial port:", configuration: Configuration())
  private let myFlashMenu = Menu(with: "Select a serial port:", configuration: Configuration())

    
    
    @IBOutlet weak var WMacOut: NSTextField!
    @IBOutlet weak var imeiOut: NSTextField!
    
    @IBOutlet weak var EMacOut: NSTextField!
    
    @IBOutlet weak var BMacOut: NSTextField!
    @IBOutlet weak var SrnmOut: NSTextField!
    @IBOutlet weak var meidOut: NSTextField!
    
    var seal_fn = String()
    var bbpv_fn = String()
    var end_bool = false
    var sealData = String()
    
    func serialPort(_ serialPort: ORSSerialPort, didReceivePacket packetData: Data, matching descriptor: ORSSerialPacketDescriptor) {
        let output = String(data: packetData, encoding: .ascii)
       if (output?.contains("seal"))! {
           seal_fn = output!
       }
       if (output?.contains("bbpv"))! {
            bbpv_fn = output!
        }
        if (output?.contains(" |"))! {
            var i = output
            i = i?.replacingOccurrences(of: " |", with: "")
            i = i?.replacingOccurrences(of: "|\n", with: "")
            sealData += i ?? ""
            outputLog.string += i ?? ""
            outputLog.scrollToEndOfDocument(nil)
        }
        if (output?.contains(":-)"))! {
            sleep(1)
            end_bool = true
            
        }
        if (output?.contains("SrNm"))! {
            SN_NAND.stringValue = output!
            SN_NAND.stringValue = remove_the_fucking_chars(func_key: "SrNm", key: SN_NAND.stringValue)
            SN_NAND.stringValue = SN_NAND.stringValue.replacingOccurrences(of: "Serial: ", with: "")
            SN_NAND.stringValue.removeDangerousCharsForSYSCFG()
        }
        if (output?.contains("WMac\n"))! {
                WMAC_NAND.stringValue = output!
                WMAC_NAND.stringValue = remove_the_fucking_chars(func_key: "WMac", key: WMAC_NAND.stringValue)
                WMAC_NAND.stringValue = makeHEX(input: WMAC_NAND.stringValue)
                WMAC_NAND.stringValue.removeDangerousCharsForSYSCFG()
                WMAC_NAND.stringValue = String(WMAC_NAND.stringValue.prefix(12))
                WMAC_NAND.stringValue = WMAC_NAND.stringValue.inserting(separator: ":", every: 2)
        }
        if (output?.contains("BMac\n"))! {
                BMAC_NAND.stringValue = output!
                BMAC_NAND.stringValue = remove_the_fucking_chars(func_key: "BMac", key: BMAC_NAND.stringValue)
                BMAC_NAND.stringValue = makeHEX(input: BMAC_NAND.stringValue)
                BMAC_NAND.stringValue.removeDangerousCharsForSYSCFG()
                BMAC_NAND.stringValue = String(BMAC_NAND.stringValue.prefix(12))
                BMAC_NAND.stringValue = BMAC_NAND.stringValue.inserting(separator: ":", every: 2)
            
        
        }
        if (output?.contains("EMac\n"))! {
                EMAC_NAND.stringValue = output!
                EMAC_NAND.stringValue = remove_the_fucking_chars(func_key: "EMac", key: EMAC_NAND.stringValue)
                EMAC_NAND.stringValue = makeHEX(input: EMAC_NAND.stringValue)
                EMAC_NAND.stringValue.removeDangerousCharsForSYSCFG()
                EMAC_NAND.stringValue = String(EMAC_NAND.stringValue.prefix(12))
                EMAC_NAND.stringValue = EMAC_NAND.stringValue.inserting(separator: ":", every: 2)
            
        
        }
        
    }
    @IBOutlet weak var scroll: NSScrollView!
    
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        port.delegate = self
        scroll.wantsLayer = true
        scroll.layer?.cornerRadius = 15
    }
    
    
    
    func checkDifference() {
        DispatchQueue.main.async { [self] in
            if WMacOut.stringValue == WMAC_NAND.stringValue {
                WMAC_NAND.backgroundColor = NSColor.systemGreen
            } else if WMacOut.stringValue == "Not found" {
                WMAC_NAND.backgroundColor = NSColor.systemOrange
            } else {
                WMAC_NAND.backgroundColor = NSColor.systemRed
            }
            if BMacOut.stringValue == BMAC_NAND.stringValue {
                BMAC_NAND.backgroundColor = NSColor.systemGreen
            } else if BMacOut.stringValue == "Not found" {
                BMAC_NAND.backgroundColor = NSColor.systemOrange
            } else {
                BMAC_NAND.backgroundColor = NSColor.systemRed
            }
            if EMacOut.stringValue == EMAC_NAND.stringValue {
                EMAC_NAND.backgroundColor = NSColor.systemGreen
            } else if EMacOut.stringValue == "Not found" {
                EMAC_NAND.backgroundColor = NSColor.systemOrange
            } else {
                EMAC_NAND.backgroundColor = NSColor.systemRed
            }
            if SrnmOut.stringValue == SN_NAND.stringValue {
                SN_NAND.backgroundColor = NSColor.systemGreen
            } else if SrnmOut.stringValue == "Not found" {
                SN_NAND.backgroundColor = NSColor.systemOrange
            } else {
                SN_NAND.backgroundColor = NSColor.systemRed
            }
        }
    }
    @IBAction func flash_new_syscfg(_ sender: Any) {
        seal_fn.removeAll()
        bbpv_fn.removeAll()
        WMAC_NAND.backgroundColor = NSColor.clear
        BMAC_NAND.backgroundColor = NSColor.clear
        SN_NAND.backgroundColor = NSColor.clear
        EMAC_NAND.backgroundColor = NSColor.clear
        outputLog.string.removeAll()
        progressSpinner.isHidden = false
        progressSpinner.startAnimation(self)
        writeSN()
        writeWMAC()
        writeBMAC()
        writeEMAC()
        DispatchQueue.global(qos: .background).async { [self] in
            if uselessValue == 0 {
                downloadSyscfg(sealPath: getSeal())
            } else {
                downloadSyscfg(bbpvPath: getBBPV())
            }
            readNANDcfg()
            sleep(1)
            checkDifference()
            DispatchQueue.main.async { [self] in
                progressSpinner.isHidden = true
                progressSpinner.stopAnimation(self)
            }
        }
        
    }
    
    func writeSN() {
        var value = SrnmOut.stringValue
        if value == "Not found" {return}
        value.removeDangerousCharsForSYSCFG()
        if value.count != 12 {return}
            let command = "syscfg add SrNm \(value)".data(using: .utf8)! + Data([0x0A])
            port.send(command)
    }
    
    func writeWMAC() {
        var value = WMacOut.stringValue
        if value == "Not found" {return}
        value.removeDangerousCharsForSYSCFG()
        if value.count != 17 {return}
        value = parseMactoMacHex(hex: value)
        let command = "syscfg add WMac \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
    }
    func writeBMAC() {
        var value = BMacOut.stringValue
        if value == "Not found" {return}
        value.removeDangerousCharsForSYSCFG()
        if value.count != 17 {return}
        value = parseMactoMacHex(hex: value)
        let command = "syscfg add BMac \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
    }
    func writeEMAC() {
        var value = EMacOut.stringValue
        if value == "Not found" {return}
        value.removeDangerousCharsForSYSCFG()
        if value.count != 17 {return}
        value = parseMactoMacHex(hex: value)
        let command = "syscfg add EMac \(value)".data(using: .utf8)! + Data([0x0A])
        port.send(command)
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func downloadSyscfg(sealPath:String) {
        end_bool = false
        sealData.removeAll()

        let descriptor = ORSSerialPacketDescriptor(prefixString: " |", suffixString: "|\n", maximumPacketLength: 20, userInfo: nil)
        let descriptorEnd = ORSSerialPacketDescriptor(prefixString: ":-)", suffixString: "\n", maximumPacketLength: 8, userInfo: nil)
        port.startListeningForPackets(matching: descriptor)
        port.startListeningForPackets(matching: descriptorEnd)
        port.send("cat -h \(sealPath)".data(using: .utf8)! + Data([0x0A]))
        
        while end_bool == false {}
        port.stopListeningForPackets(matching: descriptorEnd)
        port.stopListeningForPackets(matching: descriptor)
        
        let SrNm = matches(for: "SrNm..[A-Za-z0-9]{12}", in: sealData).first?.replacingOccurrences(of: "SrNm..", with: "") ?? "Not found"
        let imei = matches(for: "imei..[0-9]{15}", in: sealData).first?.replacingOccurrences(of: "imei..", with: "") ?? "Not found"
        let meid = matches(for: "meid..[0-9]{14}", in: sealData).first?.replacingOccurrences(of: "meid..", with: "") ?? "Not found"
        let WMac = matches(for: "WMac..[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}", in: sealData).first?.replacingOccurrences(of: "WMac..", with: "").uppercased() ?? "Not found"
        let BMac = matches(for: "BMac..[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}", in: sealData).first?.replacingOccurrences(of: "BMac..", with: "").uppercased() ?? "Not found"
        DispatchQueue.main.async { [self] in
            imeiOut.stringValue = imei
            meidOut.stringValue = meid
            SrnmOut.stringValue = SrNm
            WMacOut.stringValue = WMac
            BMacOut.stringValue = BMac
            EMacOut.stringValue = EMacGen(inp: BMac)
        }
        DispatchQueue.main.async { [self] in
            progressSpinner.isHidden = true
            progressSpinner.stopAnimation(self)
        }
    }
    
    func EMacGen(inp:String) -> String {
        let i = String(inp[(inp.count - 2)...])
        if let num2 = Int(i, radix: 16) {
            print(num2) // 1000
            let str = String(num2+1, radix: 16)
            let i2 = inp.dropLast(2)
            return (i2 + str).uppercased()
        } else {
            return "Generator failed"
        }
    }
    
    
    func downloadSyscfg(bbpvPath:String) {
        end_bool = false
        sealData.removeAll()

        let descriptor = ORSSerialPacketDescriptor(prefixString: " |", suffixString: "|\n", maximumPacketLength: 20, userInfo: nil)
        let descriptorEnd = ORSSerialPacketDescriptor(prefixString: ":-)", suffixString: "\n", maximumPacketLength: 8, userInfo: nil)
        port.startListeningForPackets(matching: descriptor)
        port.startListeningForPackets(matching: descriptorEnd)
        port.send("cat -h \(bbpvPath)".data(using: .utf8)! + Data([0x0A]))
        
        while end_bool == false {}
        port.stopListeningForPackets(matching: descriptorEnd)
        port.stopListeningForPackets(matching: descriptor)
        
        let SrNm = matches(for: "SrNm..[A-Za-z0-9]{12}", in: sealData).first?.replacingOccurrences(of: "SrNm..", with: "") ?? "Not found"
        let imei = matches(for: "imei..[0-9]{15}", in: sealData).first?.replacingOccurrences(of: "imei..", with: "") ?? "Not found"
        let meid = matches(for: "meid..[0-9]{14}", in: sealData).first?.replacingOccurrences(of: "meid..", with: "") ?? "Not found"
        let WMac = matches(for: "o.[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}", in: sealData).first?.replacingOccurrences(of: "o.", with: "").uppercased() ?? "Not found"
        let BMac = matches(for: "p.[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}:[A-Za-z0-9]{2}", in: sealData).first?.replacingOccurrences(of: "p.", with: "").uppercased() ?? "Not found"
        DispatchQueue.main.async { [self] in
            imeiOut.stringValue = imei
            meidOut.stringValue = meid
            SrnmOut.stringValue = SrNm
            WMacOut.stringValue = WMac
            BMacOut.stringValue = BMac
        }
        
    }
    
    func addOutputLog(string:String) {
        DispatchQueue.main.async {
            self.outputLog.string.append(string)
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
            
    func getBBPV() -> String {
        let descriptor = ORSSerialPacketDescriptor(prefixString: "bbpv", suffixString: "\n", maximumPacketLength: 250, userInfo: nil)
        port.startListeningForPackets(matching: descriptor)
        print("Checking disk 0")
        addOutputLog(string: "Checking disk 0\n")
        port.send("directory fs0:".data(using: .utf8)! +
                  // FactoryData\System\Library\Caches\com.apple.factorydata\
                  Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if bbpv_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs0:" + String(data:
                // FactoryData\System\Library\Caches\com.apple.factorydata\
                Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + bbpv_fn)}
        
        port.send("directory fs0:".data(using: .utf8)! + Data([0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if bbpv_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs0:" + String(data: Data([0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + bbpv_fn)}
        
        print("Checking disk 1")
        addOutputLog(string: "Checking disk 1\n")
        port.send("directory fs1:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if bbpv_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs1:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + bbpv_fn)}
        
        print("Checking disk 2")
        addOutputLog(string: "Checking disk 2\n")
        port.send("directory fs2:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if bbpv_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs2:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + bbpv_fn)}
        
        print("Checking disk 3")
        addOutputLog(string: "Checking disk 3\n")
        port.send("directory fs3:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if bbpv_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs3:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + bbpv_fn)}
        
        print("Checking disk 4")
        addOutputLog(string: "Checking disk 4\n")
        port.send("directory fs4:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        
        sleep(1)
        if bbpv_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs4:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + bbpv_fn)}
        port.stopListeningForPackets(matching: descriptor)
        return "ERROR"
    }
    
    func getSeal() -> String {
        let descriptor = ORSSerialPacketDescriptor(prefixString: "seal", suffixString: "\n", maximumPacketLength: 250, userInfo: nil)
        port.startListeningForPackets(matching: descriptor)
        print("Checking disk 0")
        addOutputLog(string: "Checking disk 0\n")
        port.send("directory fs0:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if seal_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs0:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + seal_fn)}
        
        port.send("directory fs0:".data(using: .utf8)! + Data([0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if seal_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs0:" + String(data: Data([0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + seal_fn)}
        
        print("Checking disk 1")
        addOutputLog(string: "Checking disk 1\n")
        port.send("directory fs1:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if seal_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs1:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + seal_fn)}
        
        print("Checking disk 2")
        addOutputLog(string: "Checking disk 2\n")
        port.send("directory fs2:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if seal_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs2:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + seal_fn)}
        
        print("Checking disk 3")
        addOutputLog(string: "Checking disk 3\n")
        port.send("directory fs3:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        sleep(1)
        if seal_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs3:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + seal_fn)}
        
        print("Checking disk 4")
        addOutputLog(string: "Checking disk 4\n")
        port.send("directory fs4:".data(using: .utf8)! + Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]) + Data([0x0A]))
        
        sleep(1)
        if seal_fn != "" {port.stopListeningForPackets(matching: descriptor)
            ;return ("fs4:" + String(data: Data([0x46,0x61,0x63,0x74,0x6F,0x72,0x79,0x44,0x61,0x74,0x61,0x5C,0x53,0x79,0x73,0x74,0x65,0x6D,0x5C,0x4C,0x69,0x62,0x72,0x61,0x72,0x79,0x5C,0x43,0x61,0x63,0x68,0x65,0x73,0x5C,0x63,0x6F,0x6D,0x2E,0x61,0x70,0x70,0x6C,0x65,0x2E,0x66,0x61,0x63,0x74,0x6F,0x72,0x79,0x64,0x61,0x74,0x61,0x5C]), encoding: .utf8)! + seal_fn)}
        port.stopListeningForPackets(matching: descriptor)
        addOutputLog(string: "Original SysCFG not found...\nDon't cry, this can have technical issues like failed to open serial port,so just try it again...\n")
        return "ERROR"
    }

    
//    @IBAction func SerialConnectBTNFUNC(_ sender: Any) {
//        port = ORSSerialPortManager.shared().availablePorts[Select_Port_ITEM.indexOfSelectedItem]
//            port.baudRate = 115200
//            print(port.baudRate)
//            port.delegate = self
//            print(port.path)
//                if (port.isOpen) {
//                    port.close()
//                    print("Serial connection closed")
//                    SerialConnectBTN.title = "Connect"
//                } else {
//                    SerialConnectBTN.title = "Disconnect"
//                    port.open()
//                    print("Serial connection opened")
//            }
//    }

    
//    @IBAction func RefreshSerialPort(_ sender: Any) {
//        port.close()
//        ports_array.removeAll()
//        let ports = ORSSerialPortManager.shared().availablePorts
//        for port in ports {
//        ports_array.append("\(port)")
//        }
//    }
}



struct Check: Codable {
    let response:String
    let uuid:String
    let license:String
    let valid:Bool
    let email:String
}




class Configuration: MenuConfiguration {
    override var cornerRadius: CGFloat {
        return 15.0
    }

    override var backgroundColor: NSColor {
        return NSColor(red: 63/255, green: 59/255, blue: 59/255, alpha: 1.0)
    }

    override var menuItemHoverBackgroundColor: NSColor {
        return NSColor(red: 86/255, green: 81/255, blue: 81/255, alpha: 1.0)
    }

    override var menuItemHoverCornerRadius: CGFloat {
        return 10.0
    }

    override var contentEdgeInsets: NSEdgeInsets {
        return NSEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }

    override var menuItemHeight: CGFloat {
        return 40.0
    }
    
    override var menuItemHoverEdgeInsets: NSEdgeInsets {
        return NSEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}


func makeHEX(input: String) -> String {
    let input = input
    var output = String()
    let parts = input.split(separator: " ")
    for hexstring in parts {
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
