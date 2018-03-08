//
//  Operation.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
/*
class NetworkOp : Operation {
    var isRunning = false
    
    override var isAsynchronous: Bool {
        get {
            return true
        }
    }
    
    override var isConcurrent: Bool {
        get {
            return true
        }
    }
    
    override var isExecuting: Bool {
        get {
            return isRunning
        }
    }
    
    override var isFinished: Bool {
        get {
            return !isRunning
        }
    }
    
    override func start() {
        if self.checkCancel() {
            return
        }
        self.willChangeValue(forKey: "isExecuting")
        self.isRunning = true
        self.didChangeValue(forKey: "isExecuting")
        main()
    }
    
    func complete() {
        self.willChangeValue(forKey: "isFinished")
        self.willChangeValue(forKey: "isExecuting")
        self.isRunning = false
        self.didChangeValue(forKey: "isFinished")
        self.didChangeValue(forKey: "isExecuting")
        print( "Completed net op: \(self.className)")
    }
    
    // Always resubmit if we get canceled before completion
    func checkCancel() -> Bool {
        if self.isCancelled {
            self.retry()
            self.complete()
        }
        return self.isCancelled
    }
    
    func retry() {
        // Create a new NetworkOp to match and resubmit since we can't reuse existing.
    }
    
    func success() {
        // Success means reset delay
        NetOpsQueueMgr.shared.resetRetryIncrement()
    }
}

class ImagesUploadOp : NetworkOp {
    var imageList : [PhotoFileListMap]
    
    init(imageList : [UIImage]) {
        self.imageList = imageList
    }
    
    override func main() {
        print( "Photos upload starting")
        if self.checkCancel() {
            return
        }
        
        // Pop image off front of array
        let image = imageList.remove(at: 0)
        
        // Now call function that uses AWS to upload image, mine does save to file first, then passes
        // an error message on completion if it failed, nil if it succceeded
        ServerMgr.shared.uploadImage(image: image, completion: {  errorMessage ) in
            if let error = errorMessage {
                print("Failed to upload file - " + error)
                self.retry()
            } else {
                print("Uploaded file")
                if !self.isCancelled {
                    if self.imageList.count == 0 {
                        // All images done, here you could call a final completion handler or somthing.
                    } else {
                        // More images left to do, let's put another Operation on the barbie:)
                        NetOpsQueueMgr.shared.submitOp(netOp: ImagesUploadOp(imageList: self.imageList))
                    }
                }
            }
            self.complete()
        })
    }
    
    override func retry() {
        NetOpsQueueMgr.shared.retryOpWithDelay(op: ImagesUploadOp(form: self.form, imageList: self.imageList))
    }
}


// MARK: NetOpsQueueMgr  -------------------------------------------------------------------------------

class NetOpsQueueMgr {
    static let shared = NetOpsQueueMgr()
    
    lazy var opsQueue :OperationQueue = {
        var queue = OperationQueue()
        queue.name = "myQueName"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func submitOp(netOp : NetworkOp) {
        opsQueue.addOperation(netOp)
    }
    
    func uploadImages(imageList : [UIImage]) {
        let imagesOp = ImagesUploadOp(form: form, imageList: imageList)
        self.submitOp(netOp: imagesOp)
    }
}

 */
