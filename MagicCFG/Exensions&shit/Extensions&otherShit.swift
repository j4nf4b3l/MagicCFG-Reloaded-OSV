//
//  Extensions&otherShit.swift
//  MagicCFG
//
//  Created by Jan Fabel on 16.06.20.
//  Copyright © 2020 Jan Fabel. All rights reserved.
//

import Cocoa


extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    
}


extension StringProtocol {
    subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension Collection {
    var pairs: [SubSequence] {
        var startIndex = self.startIndex
        let count = self.count
        let n = count/2 + count % 2
        return (0..<n).map { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return self[startIndex..<endIndex]
        }
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.dropFirst().reversed()
            where distance(to: index).isMultiple(of: n) {
            insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}



let region_select: [String:String] = [
    "A":"Canada",
    "AB":"Saudi Arabia, UAE, Qatar, Jordan, Egypt",
    "AD":"Andorra",
    "AE":"United Arab Emirates",
    "AF":"Afghanistan",
    "AG":"Antigua and Barbuda",
    "AI":"Anguilla",
    "AL":"Albania",
    "AM":"Armenia",
    "AN":"Netherlands Antilles",
    "AO":"Angola",
    "AQ":"Antarctica",
    "AR":"Argentina",
    "AS":"American Samoa",
    "AT":"Austria",
    "AU":"Australia",
    "AW":"Aruba",
    "AX":"Åland Islands",
    "AZ":"Azerbaijan",
    "B":"UK & Ireland",
    "BA":"Bosnia and Herzegovina",
    "BB":"Barbados",
    "BD":"Bangladesh",
    "BE":"Belgium",
    "BF":"Burkina Faso",
    "BG":"Bulgaria",
    "BH":"Bahrain",
    "BI":"Burundi",
    "BJ":"Benin",
    "BL":"Saint Barthélemy",
    "BM":"Bermuda",
    "BN":"Brunei",
    "BO":"Bolivia",
    "BR":"Brazil",
    "BS":"Bahamas",
    "BT":"Bhutan",
    "BV":"Bouvet Island",
    "BW":"Botswana",
    "BY":"Belarus",
    "BZ":"Belize",
    "C":"Canada",
    "CA":"Canada",
    "CC":"Cocos [Keeling] Islands",
    "CD":"Congo - Kinshasa",
    "CF":"Central African Republic",
    "CG":"Congo - Brazzaville",
    "CH":"Switzerland",
    "CI":"Côte d’Ivoire",
    "CK":"Cook Islands",
    "CL":"Chile",
    "CM":"Cameroon",
    "CN":"China",
    "CO":"Colombia",
    "CR":"Costa Rica",
    "CS":"Slovakia & Czech Republic",
    "CU":"Cuba",
    "CV":"Cape Verde",
    "CX":"Christmas Island",
    "CY":"Cyprus",
    "CZ":"Czech Republic",
    "D":"Germany",
    "DE":"Germany",
    "DJ":"Djibouti",
    "DK":"Denmark",
    "DM":"Dominica",
    "DN":"Austria, Germany, Netherlands",
    "DO":"Dominican Republic",
    "DZ":"Algeria",
    "E":"Mexico",
    "EC":"Ecuador",
    "EE":"Estonia",
    "EG":"Egypt",
    "EH":"Western Sahara",
    "EL":"Estonia, Latvia",
    "ER":"Eritrea",
    "ES":"Spain",
    "ET":"Ethiopia",
     "F":"France",
    "FB":"France, Luxembourg",
    "FD":"Austria, Liechtenstein, Switzerland",
    "FI":"Finland",
    "FJ":"Fiji",
    "FK":"Falkland Islands",
    "FM":"Micronesia",
    "FO":"Faroe Islands",
    "FR":"France",
    "GA":"Gabon",
    "GB":"United Kingdom",
    "GD":"Grenada",
    "GE":"Georgia",
    "GF":"French Guiana",
    "GG":"Guernsey",
    "GH":"Ghana",
    "GI":"Gibraltar",
    "GL":"Greenland",
    "GM":"Gambia",
    "GN":"Guinea",
    "GP":"Guadeloupe",
    "GQ":"Equatorial Guinea",
    "GR":"Greece",
    "GS":"South Georgia and the South Sandwich Islands",
    "GT":"Guatemala",
    "GU":"Guam",
    "GW":"Guinea-Bissau",
    "GY":"Guyana",
    "HK":"Hong Kong SAR China",
    "HM":"Heard Island and McDonald Islands",
    "HN":"Honduras",
    "HR":"Croatia",
    "HT":"Haiti",
    "HU":"Hungary",
    "ID":"Indonesia",
    "IE":"Ireland",
    "IL":"Israel",
    "IM":"Isle of Man",
    "IN":"India",
    "IO":"British Indian Ocean Territory",
    "IP":"Portugal, Italy",
    "IQ":"Iraq",
    "IR":"Iran",
    "IS":"Iceland",
    "IT":"Italy",
    "J":"Japan",
    "JE":"Jersey",
    "JM":"Jamaica",
    "JO":"Jordan",
    "JP":"Japan",
    "K":"Sweden",
    "KE":"Kenya",
    "KG":"Kyrgyzstan",
    "KH":"Cambodia",
    "KI":"Kiribati",
    "KM":"Comoros",
    "KN":"Saint Kitts and Nevis",
    "KP":"North Korea",
    "KR":"South Korea",
    "KS":"Finland and Sweden",
    "KW":"Kuwait",
    "KY":"Cayman Islands",
    "KZ":"Kazakhstan",
    "LA":"Laos",
    "LB":"Lebanon",
    "LC":"Saint Lucia",
    "LE":"Argentina",
    "LI":"Liechtenstein",
    "LK":"Sri Lanka",
    "LL":"US",
    "LR":"Liberia",
    "LS":"Lesotho",
    "LT":"Lithuania",
    "LU":"Luxembourg",
    "LV":"Latvia",
    "LY":"Libya",
    "MA":"Morocco",
    "MC":"Monaco",
    "MD":"Moldova",
    "ME":"Montenegro",
    "MF":"Saint Martin",
    "MG":"Madagascar",
    "MH":"Marshall Islands",
    "MK":"Macedonia",
    "ML":"Mali",
    "MM":"Myanmar [Burma]",
    "MN":"Mongolia",
    "MO":"Macau SAR China",
    "MP":"Northern Mariana Islands",
    "MQ":"Martinique",
    "MR":"Mauritania",
    "MS":"Montserrat",
    "MT":"Malta",
    "MU":"Mauritius",
    "MV":"Maldives",
    "MW":"Malawi",
    "MX":"Mexico",
    "MY":"Malaysia",
    "MZ":"Mozambique",
    "NA":"Namibia",
    "NC":"New Caledonia",
    "NE":"Niger",
    "NF":"Norfolk Island",
    "NG":"Nigeria",
    "NI":"Nicaragua",
    "NL":"Netherlands",
    "NO":"Norway",
    "NP":"Nepal",
    "NR":"Nauru",
    "NU":"Niue",
    "NZ":"New Zealand",
    "OM":"Oman",
    "PA":"Panama",
    "PE":"Peru",
    "PF":"French Polynesia",
    "PG":"Papua New Guinea",
    "PH":"Philippines",
    "PK":"Pakistan",
    "PL":"Poland",
    "PM":"Saint Pierre and Miquelon",
    "PN":"Pitcairn Islands",
    "PR":"Puerto Rico",
    "PS":"Palestinian Territories",
    "PT":"Portugal",
    "PW":"Palau",
    "PY":"Paraguay",
    "QA":"Qatar",
    "QN":"Sweden, Denmark, Iceland, Norway",
    "QL":"Spain, Italy, Portugal",
    "RE":"Réunion",
    "RM":"Russia, Kazakhstan",
    "RK":"Kazakhstan",
    "RO":"Romania",
    "RS":"Serbia",
    "RU":"Russia",
    "RW":"Rwanda",
    "SA":"Saudi Arabia",
    "SB":"Solomon Islands",
    "SC":"Seychelles",
    "SD":"Sudan",
    "SE":"Sweden",
    "SG":"Singapore",
    "SH":"Saint Helena",
    "SI":"Slovenia",
    "SJ":"Svalbard and Jan Mayen",
    "SK":"Slovakia",
    "SL":"Sierra Leone",
    "SM":"San Marino",
    "SN":"Senegal",
    "SO":"Somalia",
    "SR":"Suriname",
    "ST":"São Tomé and Príncipe",
    "SV":"El Salvador",
    "SY":"Syria",
    "SZ":"Swaziland",
    "TC":"Turks and Caicos Islands",
    "TD":"Chad",
    "TF":"French Southern Territories",
    "TG":"Togo",
    "TH":"Thailand",
    "TJ":"Tajikistan",
    "TK":"Tokelau",
    "TL":"Timor-Leste",
    "TM":"Turkmenistan",
    "TN":"Tunisia",
    "TO":"Tonga",
    "TR":"Turkey",
    "TT":"Trinidad and Tobago",
    "TV":"Tuvalu",
    "TW":"Taiwan",
    "TZ":"Tanzania",
    "UA":"Ukraine",
    "UG":"Uganda",
    "UM":"U.S. Minor Outlying Islands",
    "US":"United States",
    "UY":"Uruguay",
    "UZ":"Uzbekistan",
    "VA":"Vatican City",
    "VC":"Saint Vincent and the Grenadines",
    "VE":"Venezuela",
    "VG":"British Virgin Islands",
    "VI":"U.S. Virgin Islands",
    "VN":"Vietnam",
    "VU":"Vanuatu",
    "WF":"Wallis and Futuna",
    "WS":"Samoa",
    "X":"Australia, New Zealand",
    "Y":"Spain",
    "YE":"Yemen",
    "YT":"Mayotte",
    "ZA":"South Africa",
    "ZP":"Singapore",
    "ZD":"Luxembourg, Austria, Belgium, Monaco, Germany, France, Netherlands, Switzerland",
    "ZG":"Denmark",
    "ZO":"United Kingdom",
    "ZM":"Zambia",
    "ZW":"Zimbabwe",
    "ZQ":"Jamaica"]

var iPhone6_color : [String:String] = ["Gold (iPh6)":"0x00000200 0x00E1CCB5 0x00E1E4E3 0x00000000","Silver (iPh6)":"0x00000200 0x00D7D9D8 0x00E1E4E3 0x00000000","SpaceGrey (iPh6)":"0x00000200 0x00B4B5B9 0x003B3B3C 0x00000000"]

var iPhone6plus_color : [String:String] = ["Gold (iPh6+)":"0x00000200 0x00E1CCB5 0x00E1E4E3 0x00000000","Silver (iPh6+)":"0x00000200 0x00D7D9D8 0x00E1E4E3 0x00000000","SpaceGrey (iPh6+)":"0x00000200 0x00B9B7BA 0x00272728 0x00000000","Roségold (iPh6+)":"0x00000200 0x00E4C1B9 0x00E4E7E8 0x00000000"]

var iPhone6S_color : [String:String] = ["Gold (iPh6S)":"0x00000200 0x00E1CCB7 0x00E4E7E8 0x00000000","Silver (iPh6S)":"0x00000200 0x00DADCDB 0x00E4E7E8 0x00000000","SpaceGrey (iPh6S)":"0x00000200 0x00B9B7BA 0x00272728 0x00000000","Roségold (iPh6S)":"0x00000200 0x00E4C1B9 0x00E4E7E8 0x00000000"]

var iPhone6Splus_color : [String:String] = ["Gold (iPh6S+)":"0x00000200 0x00E1CCB7 0x00E4E7E8 0x00000000","Silver (iPh6S+)":"0x00000200 0x00DADCDB 0x00E4E7E8 0x00000000","SpaceGrey (iPh6S+)":"0x00000200 0x00B9B7BA 0x00272728 0x00000000","Roségold (iPh6S+)":"0x00000200 0x00E4C1B9 0x00E4E7E8 0x00000000"]

var iPhone7_color : [String:String] = ["Gold (iPh7)":"0x00000001 0x00000000 0x00000000 0x00000003","Silver (iPh7)":"0x00000001 0x00000000 0x00000000 0x00000002","Black (iPh7)":"0x00000001 0x00000000 0x00000000 0x00000001","DiamondBlack(iPh7)":"0x00000001 0x00000000 0x00000000 0x00000005","Roségold (iPh7)":"0x00000001 0x00000000 0x00000000 0x00000004","Red (iPh7)":"0x00000001 0x00000000 0x00000000 0x00000006"]

var iPhone8_color : [String:String] = ["Black (iPh8)":"0x00000001 0x00000000 0x00000000 0x00000008","Silver (iPh8)":"0x00000001 0x00000000 0x00000000 0x00000002","Red (iPh8)":"0x00000001 0x00000000 0x00000000 0x00000006","Gold (iPh8)":"0x00000001 0x00000000 0x00000000 0x00000007"]

var iPhone8plus_color : [String:String] = ["Black (iPh8+)":"0x00000001 0x00000000 0x00000000 0x00000001","Silver (iPh8+)":"0x00000001 0x00000000 0x00000000 0x00000002","Red (iPh8+)":"0x00000001 0x00000000 0x00000000 0x00000006","Gold (iPh8+)":"0x00000001 0x00000000 0x00000000 0x00000003"]

var iPhoneX_color : [String:String] = ["Black (iPhX)":"0x00000001 0x00000000 0x00000000 0x00000001","White (iPhX)":"0x00000001 0x00000000 0x00000000 0x00000002"]


struct deviceModels: Codable {
    let name: String
    let model: String
    let ANumber: [String]

}



extension String {

    mutating func removeDangerousCharsForSYSCFG() {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-_:+").inverted as NSCharacterSet
        self = (self.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
    let dispatchTime = DispatchTime.now() + seconds
    dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
}

public enum DispatchLevel {
    case main, userInteractive, userInitiated, utility, background
    var dispatchQueue: DispatchQueue {
        switch self {
        case .main:                 return DispatchQueue.main
        case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
        case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
        case .utility:              return DispatchQueue.global(qos: .utility)
        case .background:           return DispatchQueue.global(qos: .background)
        }
    }
}

func parseMacHextoMac(hex: String) -> String {
        var hex = hex
        hex = hex.replacingOccurrences(of: "0x", with: "")
        hex = hex.replacingOccurrences(of: " ", with: "")
    let v1 = hex[6...7]
    let v2 = hex[4...5]
    let v3 = hex[2...3]
    let v4 = hex[0...1]
    let v5 = hex[14...15]
    let v6 = hex[12...13]
    let mac = "\(v1):\(v2):\(v3):\(v4):\(v5):\(v6)"
    return mac
    }

func parseMactoMacHex(hex: String) -> String {
    var hex = hex
    hex = hex.replacingOccurrences(of: ":", with: "")
    let v1 = hex[0...1]
    let v2 = hex[2...3]
    let v3 = hex[4...5]
    let v4 = hex[6...7]
    let v5 = hex[8...9]
    let v6 = hex[10...11]    
let mac = "0x\(v4)\(v3)\(v2)\(v1) 0x0000\(v6)\(v5) 0x00000000 0x00000000"
return mac
}



   func remove_the_fucking_chars(func_key: String, key: String) -> String {
       var str = key
       if let index = str.endIndex(of: "\(func_key)\n") {
           let substring = str[index...]
           var restring = String(substring)
           restring.removeFirst()
        if restring.count >= 2 {
            restring.removeLast(2)
        }
           return restring
       } else {return "error"}
   }
   
