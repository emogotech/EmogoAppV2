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

enum UploadType:String {
    case image = "1"
    case video = "2"
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
    
    
    func uploadFile(_ fileURL:URL,name:String, completion:@escaping (String?,Error?)->Void) {
        let key = NSString(format: "%@", name).pathExtension
        var type:String! = "image/png"
        if let mimType = key.MIMEType() {
            type = mimType
        }else {
            if key.lowercased() == "jpg" ||  key.lowercased() == "jpeg" {
                type = "image/jpeg"
            }else if key.lowercased() == "mov"  {
                type = "movie/mov"
            }else if key.lowercased() == "mp4" {
                type = "video/mp4"
            }
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
                    Document.deleteFile(name: name)
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


class AWSRequestManager:NSObject {
    
    var arrayRequest:[String]!
    typealias isSuccess = (Bool) -> ()
     var updateSuccessHandler:isSuccess!

    
    class var sharedInstance: AWSRequestManager {
        struct Static {
            static let instance: AWSRequestManager = AWSRequestManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        arrayRequest = [String]()
    }
    
    func imageUpload(image:UIImage,name:String,completion:@escaping (String?,Error?)->Void) {
            let img = image.reduceSize()
            let imageData = UIImageJPEGRepresentation(img, 1.0)
            let url = Document.saveFile(data: imageData!, name: name)
            let fileUrl = URL(fileURLWithPath: url)
            self.arrayRequest.append(name)
            AWSManager.sharedInstance.uploadFile(fileUrl, name: name) { (imageUrl,error) in
                if let index = self.arrayRequest.index(of: name) {
                    self.arrayRequest.remove(at: index)
                }
               completion(imageUrl, error)
            }
    }
    
    func prepareVideoToUpload(name:String,videoURL:URL,completion:@escaping (String?,String?,Error?)->Void) {
            Document.compressVideoFile(name:name, inputURL: videoURL, handler: { (compressed) in
                if compressed != nil {
                    let fileUrl = URL(fileURLWithPath: compressed!)
                   
                    if let image = SharedData.sharedInstance.videoPreviewImage(moviePath:fileUrl,isSave:false) {
                        var strThumb:String!
                        var strVideo:String!
                        
                        self.uploadVideo(name: name, videoURL: fileUrl, completion: { ( video, error) in
                            if error == nil {
                                strVideo = video
                                if strThumb != nil &&  strVideo != nil {
                                    completion(strThumb,strVideo,error)
                                }
                            }
                        })
                        
                        self.imageUpload(image: image, name: NSUUID().uuidString + ".jpeg", completion: { (imageUrl,error) in
                            if error == nil {
                                strThumb = imageUrl
                                if strThumb != nil &&  strVideo != nil {
                                    completion(strThumb,strVideo,error)
                                }
                            }
                        })
                        
                    }
                }
            })
        }
    
  private func uploadVideo(name:String,videoURL:URL,completion:@escaping (String?,Error?)->Void) {
        self.arrayRequest.append(name)
        AWSManager.sharedInstance.uploadFile(videoURL, name: name) { (imageUrl,error) in
            if let index = self.arrayRequest.index(of: name) {
                self.arrayRequest.remove(at: index)
            }
            completion(imageUrl, error)
        }
        
    }
    
    private func uploading() {
        HUDManager.sharedInstance.showProgress()
    }
    
    private func completed() {
        if arrayRequest.count == 0 {
            HUDManager.sharedInstance.hideProgress()
        }
    }
    
    func startContentUpload(StreamID:[String],array:[ContentDAO]){
        if StreamID.count == 0 {
            self.showToast(strMSG: kAlert_waitProcess)
        }else {
            self.showToast(strMSG: kAlert_waitProcess)
        }
        var arrayContentToCreate = [ContentDAO]()
        let dispatchGroup = DispatchGroup()
        for obj in array {
            dispatchGroup.enter()
           if obj.isUploaded == false  {
                if obj.type == .image {
                    self.imageUpload(image: obj.imgPreview!, name: obj.fileName, completion: { (imageUrl,error) in
                        if error == nil {
                            let ext = imageUrl?.getName()
                            if let index = array.index(where: {$0.fileName == ext}) {
                                let value = array[index]
                                value.imgPreview = nil
                                value.coverImage = imageUrl
                                arrayContentToCreate.append(value)
                                print(arrayContentToCreate.count)
                            }
                        }
                        dispatchGroup.leave()
                    })
                }else if obj.type == .video {
                    self.prepareVideoToUpload(name: obj.fileName, videoURL: obj.fileUrl!, completion: { (strThumb,strVideo,error) in
                        if error == nil {
                            let ext = strVideo?.getName()
                            if let index = array.index(where: {$0.fileName == ext}) {
                                let value = array[index]
                                value.imgPreview = nil
                                value.coverImage = strVideo
                                value.coverImageVideo = strThumb
                                arrayContentToCreate.append(value)
                                print(arrayContentToCreate.count)
                            }
                        }
                        dispatchGroup.leave()
                    })
                }else {
                   arrayContentToCreate.append(obj)
                    dispatchGroup.leave()
            }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            
          print("contents Uploaded----->\(arrayContentToCreate.count)")
            if arrayContentToCreate.count == array.count {
                self.createContent(StreamID: StreamID, array: arrayContentToCreate)
            }else{
                 AppDelegate.appDelegate.window?.isUserInteractionEnabled = true
            }
        }
    }

    
    func createContent(StreamID:[String],array:[ContentDAO]){
        var arrayParams = [Any]()
        for obj in array {
            let param = ["url":obj.coverImage!,"name":obj.name!,"type":obj.type.rawValue,"description":obj.description!,"video_image":obj.coverImageVideo!,"height":obj.height!,"width":obj.width!] as [String : Any]
            arrayParams.append(param)
        }
        print(arrayParams)
        APIServiceManager.sharedInstance.apiForCreateContent(contents: arrayParams, contentName: "", contentDescription: "", coverImage: "", coverImageVideo: "", coverType: "",width:0,height:0) { (contents, errorMsg) in
            if (errorMsg?.isEmpty)! {
                SharedData.sharedInstance.contentList.arrayContent = contents
                self.completed()
                if StreamID.count != 0 {
                    self.associateContentToStream(streamID: StreamID, contents: contents!, completion: { (success, errorMsg) in
                        
                    })
                }else {
                    self.showToast(strMSG: kAlert_Content_Added)
                }
            }
            AppDelegate.appDelegate.window?.isUserInteractionEnabled = true

        }
    }
    
    func associateContentToStream(streamID:[String], contents:[ContentDAO],completion:@escaping (Bool?,String?)->Void){
        var IDs = [String]()
        var arrayWillUpload = [ContentDAO]()
        for obj in contents {
            if !obj.contentID.trim().isEmpty {
                IDs.append(obj.contentID.trim())
            }else {
                arrayWillUpload.append(obj)
            }
        }
        if arrayWillUpload.count != 0 {
            self.startContentUpload(StreamID:streamID, array: arrayWillUpload)
        }
        if IDs.count == 0 {
            return
        }
        APIServiceManager.sharedInstance.apiForContentAddOnStream(contentID: IDs, streams: streamID) { (isSuccess, errorMsg) in
            if (errorMsg?.isEmpty)! {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateStreamViewIdentifier), object: nil)
                self.showToast(strMSG: kAlert_contenAddedToStream)
                completion(true,"")
            }else {
                completion(false,errorMsg)
            }
        }
    }
    
    func showToast(strMSG:String){
        AppDelegate.appDelegate.window?.makeToast(message: strMSG,
                                                  duration: TimeInterval(3.0),
                                                  position: .top,
                                                  image: nil,
                                                  backgroundColor: UIColor.black.withAlphaComponent(0.6),
                                                  titleColor: UIColor.white,
                                                  messageColor: UIColor.white,
                                                  font: nil)
    }
 }


