//
//  shareExt.swift
//  ShareExt
//
//  Created by Sushobhit on 24/01/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
import SDWebImage
import Kanna

public extension URL {
    
    struct ValidationQueue {
        static var queue = OperationQueue()
    }
    
    func fetchPageInfo(_ completion: @escaping ((_ title: String?, _ description: String?, _ previewImage: String?) -> Void), failure: @escaping ((_ errorMessage: String) -> Void)) {
        
        let request = NSMutableURLRequest(url: self)
        let newUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36"
        request.setValue(newUserAgent, forHTTPHeaderField: "User-Agent")
        ValidationQueue.queue.cancelAllOperations()
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    failure("Url receive no response")
                })
                return
            }
            
            if let urlResponse = response as? HTTPURLResponse {
                if urlResponse.statusCode >= 200 && urlResponse.statusCode < 400 {
                    if let data = data {
                        
                        if let doc = Kanna.HTML(html: data, encoding: String.Encoding.utf8) {
                            let title = doc.title
                            var description: String? = nil
                            var previewImage: String? = nil
                            if let nodes = doc.head?.xpath("//meta").enumerated() {
                                for node in nodes {
                                    if node.element["property"]?.contains("description") == true ||
                                        node.element["name"] == "description" {
                                        description = node.element["content"]
                                    }
                                    if node.element["property"]?.contains("image") == true &&
                                        node.element["content"]?.contains("http") == true {
                                        previewImage = node.element["content"]
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async(execute: {
                                completion(title, description, previewImage)
                            })
                        }
                        
                    }
                } else {
                    DispatchQueue.main.async(execute: {
                        failure("Url received \(urlResponse.statusCode) response")
                    })
                    return
                }
            }
        }).resume()
    }
}

extension UIImageView {
    
    func setImageWithURL(strImage:String, placeholder:String){
        if strImage.isEmpty{
            return
        }
        let imgURL = URL(string: strImage.stringByAddingPercentEncodingForURLQueryParameter()!)!
        //self.sd_setImage(with: url)
        self.sd_setImage(with: imgURL, placeholderImage: UIImage(named: placeholder))
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setIndicatorStyle(.gray)
    }

}

extension String {
    
    func stringByAddingPercentEncodingForURLQueryParameter() -> String? {
        let allowedCharacters = NSCharacterSet.urlQueryAllowed
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    func trimStr() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}


extension UIViewController {
    func showToastIMsg(strMSG:String) {
        self.view.makeToast(message: strMSG,
                            duration: TimeInterval(3.0),
                            position: .top,
                            image: nil,
                            backgroundColor: UIColor.black.withAlphaComponent(0.6),
                            titleColor: UIColor.yellow,
                            messageColor: UIColor.white,
                            font: nil)
    }
}

