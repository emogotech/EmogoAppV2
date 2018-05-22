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

    static func saveFile(data:Data,name:String) -> String{
        let size =  data.count/1024/1024
        print(size)
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        print(paths)
     //   let imageData = UIImageJPEGRepresentation(image, 1.0)
        fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
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
    

    static func checkFile(name:String) -> URL?{
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(name)
        let fileURL = URL(fileURLWithPath: imagePAth)
        if fileManager.fileExists(atPath: imagePAth){
            return fileURL
        }else{
            return nil
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
    
  static func deleteFile(name:String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
            print("File Removed.")

        }else{
            print("Something wrong.")
        }
    }
    
    
    
    static func compressVideoFile(name:String,inputURL: URL, handler:@escaping (_ url: String?)-> Void){
        
        
        guard let data = NSData(contentsOf: inputURL as URL) else {
        
            return
        }
        let value = Int(data.length / 1048576)
        if value < 5 {
           let file =   self.saveFile(data: data as Data, name: name)
            handler(file)
            return
        }
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        print(name)
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
        print(paths)
        let compressedURL = NSURL.fileURL(withPath: paths)
       print(compressedURL)
      let urlAsset = AVURLAsset(url: inputURL, options: nil)
       guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName:  AVAssetExportPresetMediumQuality) else {
        handler(inputURL.absoluteString)
            return
      }
    
      exportSession.outputURL = compressedURL
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
            guard let compressedData = NSData(contentsOf: compressedURL) else {
                return
            }
            print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
             Document.deleteFile(name: name)
            let filePath = Document.saveFile(data: compressedData as Data, name: name)
            handler(filePath)
        case .failed:
            guard let compressedData = NSData(contentsOf: inputURL) else {
                return
            }
            print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
            Document.deleteFile(name: name)
            let filePath = Document.saveFile(data: compressedData as Data, name: name)
            handler(filePath)
            break
        case .cancelled:
            break
        }
        }
    }
}
   
    

