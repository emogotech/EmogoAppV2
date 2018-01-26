//
//  Validator.swift
//  Emogo
//
//  Created by Vikas Goyal on 15/11/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit


class Validator {
    
    // MARK: - Email Id Validation
    static func isInValidEmail(text:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
    static func isInValidUsername(text:String) -> Bool {
        let RegEx = "\\A\\w{4,18}\\z"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: text)
    }
    
    static func isValidUserName(text:String)-> Bool{
        let emailRegEx = "^(?=\\S{2})[a-zA-Z]\\w*(?:\\.\\w+)*(?:@\\w+\\.\\w{2,})?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
    
    static func isValidName(text : String)-> Bool{
        let RegEx = "^[a-z A-Z]{2,}+$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: text)
    }
    
    static func isNameIsValidForString(string : String,numberOfCharacters : Int) -> Bool{
        if(string.contains("\\") == true || string.contains("'") == true || string.contains("@") == true || string.contains("\"") == true || string.contains(".") == true){
            return false
        }else if(string.trim().count < numberOfCharacters){
            return false
        }
        return true
    }
    
    static func isUserNameIsValidForString(string : String, numberOfCharacters : Int) -> Bool{
        if(string.contains("\\") == true || string.contains("'") == true || string.contains("\"") == true || string.contains(".") == true){
            return false
        }else if(string.trim().count < numberOfCharacters){
            return false
        }
        return true
    }
    
    static func isValidPasswordForString(string : String) -> Bool{
        if(string.contains(" ") == true ){
            return false
        }else if(string.trim().count < 1){
            return false
        }
        return true
    }
    
    static func isValidMobileNumber(string : String, numberOfCharacters : Int) -> Bool{
        if(string.trim().count < numberOfCharacters){
            return false
        }
        return true
    }
    
    static func isValidDigitCode(string : String, numberOfCharacters : Int) -> Bool{
        if(string.trim().count < numberOfCharacters){
            return false
        }
        return true
    }
    
    static func isInValidPassword(text : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: text)
    }
    
    static func isInValidPhoneNumber(text: String) -> Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "0123456789").inverted
        let inputString = text.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  text == filtered
    }
    
    static func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_")
        return String(text.filter {okayChars.contains($0) })
    }
    
    //iMessage
    static func isEmpty(text: String) -> Bool {
        if text.trim().count == 0 {
            return false
        }
        return  true
    }
    
    static func isMobileLength(text: String, lenght : Int) -> Bool {
        if text.trim().count < lenght {
            return false
        }
        return  true
    }
    
    static func isNameLengthMin(text: String, lenghtMin : Int) -> Bool {
        if (text.trim().count) < lenghtMin {
            return false
        }
        return  true
    }
    
    static func isNameLengthMax(text: String, lenghtMax : Int) -> Bool {
        if (text.trim().count) > lenghtMax {
            return false
        }
        return  true
    }
    
    static func isNameContainSpace(text: String) -> Bool {
        if(text.contains(" ") == true ){
            return false
        }
        return  true
    }
    
    static func isNameLength(text: String, lenghtMin : Int, lengthMax : Int) -> Bool {
        if (text.trim().count) < lenghtMin || (text.trim().count) > lengthMax {
            return false
        }
        return  true
    }
    
  static func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    //
}


extension String {
    var length: Int {
        return self.count
    }
    
    func trim() -> String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    }
    
    func toBool() -> Bool{
        if self == "false" || self == "0" {
            return false
        }else{
            return true
        }
    }
    func getName() -> String{
        let array = self.components(separatedBy: "/")
        return array.last!
    }
    
    func getType() -> String{
        let key = NSString(format: "%@", self).pathExtension
        var type:String! = ""
        if key.lowercased() == "jpg" ||  key.lowercased() == "jpeg" {
            type = "Picture"
        }else if key.lowercased() == "mov"  ||  key.lowercased() == "mp4"{
            type = "Video"
        }
        return type
    }
    
    func trim(count:Int) -> String {
        let shortString = String(self.prefix(count))
        return shortString
    }
    
    func smartURL() -> URL {
        let str = self
        var result : URL!
        var trimmedStr : NSString
        var schemeMarkerRange : NSRange
        var scheme  :   NSString
     
        trimmedStr = "\(str)" as NSString
        
        if  trimmedStr.length != 0 {
            schemeMarkerRange = trimmedStr.rangeOfCharacter(from: CharacterSet.init(charactersIn: "://"))
            
            if schemeMarkerRange.location == NSNotFound {
                trimmedStr = trimmedStr.contains("www") ? trimmedStr : trimmedStr.appending("www.") as NSString
                result = URL(string: "http://\(trimmedStr)")!
            }else{
                scheme  =  trimmedStr.substring(with: NSMakeRange(0, schemeMarkerRange.location)) as NSString
                if scheme.compare("http", options: .caseInsensitive) == .orderedSame || scheme.compare("https", options: .caseInsensitive) == .orderedSame{
                    result = URL(string: trimmedStr as String)
                }else{
                    print("failed url")
                }
            }
        }
        return result
    }
    
    func findUrl() -> String {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        var url:String! = ""
        for match in matches {
            guard let range = Range(match.range, in: self) else { continue }
            let myNSString = self.nsRange(from: range)
            url =  (self as NSString).substring(with: myNSString)
            print(url)
        }
        return self.replacingOccurrences(of: url, with: "")
    }
    
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
}


