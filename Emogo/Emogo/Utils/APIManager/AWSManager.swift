//
//  AWSManager.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore

enum AWSResult<T, Error> {
    case success(T)
    case error(Error)
}


class AWSManager: NSObject {
    

    //  Handler Closure
    
    typealias ResquestProgress = (Int64) -> ()
    typealias Progress = (CGFloat) -> ()
    typealias CompletionClosure = (AWSResult<Any,Error>) -> ()
    
    // Varibale Declaration
    
    fileprivate var progressHandler:ResquestProgress!
    fileprivate var completionHandler:CompletionClosure!
    fileprivate var arrayTotalBytesExpectedToSend = [Int64]()
    fileprivate var arrayRequest = [AWSS3TransferManagerUploadRequest]()
    fileprivate var arrayTotalSent = [Int64]()

    var TotalProgress:Progress!

    class var sharedInstance: AWSManager {
        struct Static {
            static let instance: AWSManager = AWSManager()
        }
        return Static.instance
    }
 
    // MARK: -  INIT

    
    override init() {
        super.init()
        self.initAWS()
    }
    
    // MARK: -  Init AWS

    private func initAWS(){
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: kAWS_AccessKey, secretKey: kAWS_SecretKey)
        let configuration = AWSServiceConfiguration(region:kRegion, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadMedia(_ uRequest:AWSS3TransferManagerUploadRequest, completion:@escaping (AWSResult<Any, Error>)->Void, progressHandler:@escaping (_ percentage:Int64?)->Void){
        
        self.completionHandler = completion
        self.progressHandler = progressHandler
        self.arrayRequest.removeAll()
        if !self.arrayRequest.contains(uRequest) {
            self.arrayRequest.append(uRequest)
        }
        // Track the Progress Of Upload Request
        uRequest.uploadProgress = {(bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                // Calculation To Get The Total Progress Of requests
                if !self.arrayTotalBytesExpectedToSend.contains(totalBytesExpectedToSend) {
                    self.arrayTotalBytesExpectedToSend.append(totalBytesExpectedToSend)
                }
                
                let  percentage = totalBytesSent*100/totalBytesExpectedToSend
                progressHandler(percentage)
            })
        }
        // Upload Request
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                completion(.error(error))
            }
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uRequest.bucket!).appendingPathComponent(uRequest.key!)
                if let absoluteString = publicURL?.absoluteString {
                    completion(.success(absoluteString))
                }
            }
            return nil
        }
        
    }
    
    func totalBytesExpectedToSend() -> Int64 {
        let total:Int64 = arrayTotalBytesExpectedToSend.reduce(0, +)
        return total
    }
    
    func showTotalProgress (index:Int, value:Int64) {
        arrayTotalSent[index] = value
        let total:Int64 = arrayTotalSent.reduce(0, +)
        let  percentageInt = total*100/self.totalBytesExpectedToSend()
        let percentage = CGFloat(percentageInt)
        let value = percentage/100.0
        self.TotalProgress(value)
    }
    
    
    func uploadImage(_ fileURL:URL,name:String, completion:@escaping (String?,Error?)->Void) {
        let key = NSString(format: "%@", name).pathExtension
        var type:String! = "image/png"
        if key.lowercased() == "jpg" ||  key.lowercased() == "jpeg" {
            type = "image/jpeg"
        }
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = name
        uploadRequest.bucket = kBucketStreamMedia
        uploadRequest.contentType = type
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                completion(nil, error)
            }
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                if let absoluteString = publicURL?.absoluteString {
                    Document.deleteImage(name: name)
                    completion(absoluteString, nil)
                }
            }
            return nil
        }
    }
    
    func removeFile(name:String, completion:@escaping (Bool?,Error?)->Void){
        let s3 = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()
        deleteObjectRequest?.bucket = kBucketStreamMedia
        deleteObjectRequest?.key = name
        s3.deleteObject(deleteObjectRequest!).continueWith { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                completion(false, error)
                return nil
            }
            completion(true, nil)
            print("Deleted successfully.")
            return nil
        }
    }
}



