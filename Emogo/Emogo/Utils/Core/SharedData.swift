//
//  SharedData.swift
//  Emogo
//
//  Created by Vikas Goyal on 31/10/17.
//  Copyright © 2017 NorhtOut. All rights reserved.
//

import UIKit
import CoreTelephony
import Photos
import Messages
import SDWebImage

class SharedData: NSObject {
    //MARK:- Variables
    
    
    var countryCode:String!
    var nextStreamString:String! = ""
    var isMoreContentAvailable : Bool = false
    var deepLinkType : String = ""
    var savedConversation: MSConversation?
    var streamID:String = ""
    
    // MARK: - INIT Singleton Method
    class var sharedInstance: SharedData {
        struct Static {
            static let instance: SharedData = SharedData()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        self.countryCode = ""
    }
    
    
    // MARK: - Country Code
    
    func getCountryCallingCode(countryRegionCode:String)->String{
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        let countryDialingCode = prefixCodes[countryRegionCode]
        return countryDialingCode!
    }
    
    // MARK: - show alert with block
    func showAlertWithHandler(VC:UIViewController, title:String, message:String,  completion: @escaping (_ results: UIAlertAction) -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {
            })
            completion(action)
        }
        alert.addAction(action)
        VC.present(alert, animated: true) {
        }
    }
    
    
    // MARK: - Retrive error messages from JSON
    
    func getErrorMessages(dict:[String:Any]) -> String {
        var errors = [String]()
        var errorMessage:String! = ""
        if let value = dict["exception"] {
            if value is [String:Any] {
                let obj:[String:Any] = value as! [String : Any]
                print(obj)
                for (key, value) in obj {
                    print("key is - \(key) and value is - \(value)")
                    if value is [Any] {
                        let error:String = (value as! [Any])[0] as! String
                        errors.append(error.trim())
                    }else if value is String {
                        errors.append(value as! String)
                    }
                }
                errorMessage = errors.joined(separator: "\n")
            }else {
                errorMessage = "\(value)"
            }
        }
        return errorMessage.replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: "")
    }
    
    
    func saveVideo(fileUrl:URL){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
        }) { saved, error in
            if saved {
                print("Saved")
            }
        }
    }
    
    func videoPreviewImage(moviePath: URL) -> UIImage? {
        self.saveVideo(fileUrl: moviePath)
        do {
            
            let asset = AVURLAsset(url: moviePath , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
            
        }
    }
    
    func getThumbnailImage(url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
  
    
    //iMessage spectific func and variables
    //MARK :- Variables
    var isMessageWindowExpand : Bool = false
    
    //MARK :- FSPagerView
    
    func preparePagerFrame(frame : CGRect, controller : MSMessagesAppViewController) {
        for subV in controller.view.subviews {
            if(subV.isKind(of: FSPagerView.self)){
                return
            }
        }
        let pagerView  = FSPagerView(frame: frame)
        controller.view.addSubview(pagerView)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 0)
        pagerView.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 0)
        pagerView.currentIndex = 2
        pagerView.itemSize = CGSize(width: 130, height: 130)
        pagerView.transformer = FSPagerViewTransformer(type:.ferrisWheel)
        pagerView.delegate = controller as? FSPagerViewDelegate
        pagerView.dataSource = controller as? FSPagerViewDataSource
        pagerView.isHidden = true
        pagerView.isAddBackground = false
        pagerView.isAddTitle = false
        pagerView.layer.contents = UIImage(named: "bottomPager")?.cgImage
    }
    
    func placeHolderText(text : String, colorName : UIColor) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
    }
    
    func showPager(controller : MSMessagesAppViewController)  {
        for subV in controller.view.subviews {
            if(subV.isKind(of: FSPagerView.self)){
                subV.isHidden = false
            }
        }
    }
    
    func hidePager(controller : MSMessagesAppViewController)  {
        for subV in controller.view.subviews {
            if(subV.isKind(of: FSPagerView.self)){
                subV.isHidden = true
            }
        }
    }
    
    //MARK:- User Data Local Detailed set and reset all User Data
    func setUserInfo(dictObject:NSDictionary)  {
        let defaultUser = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")
        let encodedData : Data = NSKeyedArchiver.archivedData(withRootObject: dictObject)
        defaultUser?.set(encodedData, forKey: "USER_DATA")
        defaultUser?.synchronize()
    }
    
    func dictUserInfo() -> NSDictionary  {
        let defaultUser = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")
        
        
        if(defaultUser?.object(forKey: "USER_DATA") == nil){
            let dict : NSDictionary = NSDictionary()
            print(dict.allKeys.count)
            return dict
        }else{
            let encodedData : Data = defaultUser!.object(forKey: "USER_DATA") as! Data
            guard  let tempDict : NSDictionary = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? NSDictionary else {
                let dict : NSDictionary = NSDictionary()
                print(dict.allKeys.count)
                return dict
            }
            return tempDict
        }
    }
    
    func  resetAllData()  {
        let defaultUser = UserDefaults(suiteName: "group.com.emogotechnologiesinc.thoughtstream")
        defaultUser?.set(nil, forKey: "USER_DATA")
        defaultUser?.synchronize()
    }
    
    func checkUserExsting() -> Bool{
        if (SharedData.sharedInstance.dictUserInfo().count>0){
            return true
        }
        return false
    }
   
    func presentAppViewWithDeepLink(strURL : String) {
        guard let url = URL(string: strURL) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
//             UIApplication.shared.openURL(url)
        }
    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    
    
    func downloadFile(strURl: String,handler:@escaping (_ image: UIImage?, _ type:String)-> Void){
         let imageURL = URL(string: strURl.stringByAddingPercentEncodingForURLQueryParameter()!)!
        print("Download Started")
        getDataFromUrl(url: imageURL) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? imageURL.lastPathComponent)
            print(response?.mimeType)
            print("Download Finished")
            DispatchQueue.main.async() {
                print(data.count)
                
            }
        }
    }
    
    
    func downloadImage(url:String,handler:@escaping (_ image: UIImage?)-> Void){
        let imageURL = URL(string: url.stringByAddingPercentEncodingForURLQueryParameter()!)!
          let manager = SDWebImageManager.shared()
        manager.imageDownloader?.downloadImage(with: imageURL, options: .continueInBackground, progress: nil, completed: { (image, data, error, finished) in
            handler(image)
        })
    }
    
   
    
 }

