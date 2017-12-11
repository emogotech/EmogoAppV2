//
//  Document.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class Document: NSObject {

  static func saveImage(image:UIImage,name:String) -> String{
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        print(paths)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        return paths
    }
    
   static func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func checkImage(name:String) -> Bool{
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(name)
        if fileManager.fileExists(atPath: imagePAth){
            return true
        }else{
            print("No Image")
            return false
        }
    }
    
  static  func createDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }else{
            print("Already dictionary created.")
        }
    }
    
  static func deleteImage(name:String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
            print("File Removed.")

        }else{
            print("Something wrong.")
        }
    }
    
    
    
  static func compressVideoFile(inputURL: URL, handler:@escaping (_ url: URL?)-> Void){
        guard let data = NSData(contentsOf: inputURL as URL) else {
            return
        }
        
        print("File size before compression: \(Double(data.length / 1048576)) mb")
            
      let urlAsset = AVURLAsset(url: inputURL, options: nil)
       guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName:  AVAssetExportPresetMediumQuality) else {
        handler(nil)
        
        return
      }
    
      exportSession.outputURL = inputURL
      exportSession.outputFileType = AVFileType.mov
      exportSession.shouldOptimizeForNetworkUse = true
      exportSession.exportAsynchronously { () -> Void in
        
        switch exportSession.status {
        case .unknown:
            break
        case .waiting:
            break
        case .exporting:
            break
        case .completed:
            guard let compressedData = NSData(contentsOf: inputURL) else {
                return
            }
            print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
            handler(inputURL)
        case .failed:
            break
        case .cancelled:
            break
        }
        }
    }
    
}
