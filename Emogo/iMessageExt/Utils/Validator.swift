//
//  Validator.swift
//  tap.az
//
//  Created by Ozal Suleyman on 7/11/17.
//  Copyright © 2017 OzalSuleyman. All rights reserved.
//

import Foundation

class Validator {

    static func isInValidUsername(text:String) -> Bool {
        let RegEx = "\\A\\w{4,18}\\z"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: text)
    }
    
    static func isInValidEmail(text:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
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
        }else if(string.trim().characters.count < numberOfCharacters){
            return false
        }
        return true
    }
    
    static func isUserNameIsValidForString(string : String, numberOfCharacters : Int) -> Bool{
        if(string.contains("\\") == true || string.contains("'") == true || string.contains("\"") == true || string.contains(".") == true){
            return false
        }else if(string.trim().characters.count < numberOfCharacters){
            return false
        }
        return true
    }
    
    static func isValidPasswordForString(string : String) -> Bool{
        if(string.contains(" ") == true ){
            return false
        }else if(string.trim().characters.count < 1){
            return false
        }
        return true
    }
    
    static func isValidMobileNumber(string : String, numberOfCharacters : Int) -> Bool{
        if(string.trim().characters.count < numberOfCharacters){
            return false
        }
        return true
    }
    
    static func isValidDigitCode(string : String, numberOfCharacters : Int) -> Bool{
        if(string.trim().characters.count < numberOfCharacters){
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
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
}

extension String {
    var length: Int {
        return self.characters.count
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
    
}
