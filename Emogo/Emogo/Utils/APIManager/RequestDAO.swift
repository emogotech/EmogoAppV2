//
//  RequestDAO.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import Foundation
import UIKit
import AWSS3

class RequestDAO {
    var request : AWSS3TransferManagerUploadRequest!
    var isCompleted:Bool! = false
    init(request:AWSS3TransferManagerUploadRequest, isCompleted:Bool) {
        self.request = request
        self.isCompleted = isCompleted
    }
    
}
