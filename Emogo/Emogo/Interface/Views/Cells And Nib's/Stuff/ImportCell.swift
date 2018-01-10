//
//  ImportCell.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Photos
import FLAnimatedImage
import SDWebImage.SDWebImageGIFCoder
class ImportCell: UICollectionViewCell {
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgSelect: UIImageView!

    
    func prepareLayout(content:ContentDAO?){
        guard let content = content  else {
            return
        }
        if content.isSelected {
            imgSelect.image = #imageLiteral(resourceName: "select_active_icon")
        }else {
            imgSelect.image = #imageLiteral(resourceName: "select_unactive_icon")
        }
        if content.imgPreview !=  nil {
            imgCover.image = content.imgPreview
        }
        if content.type == .image {
            self.btnPlay.isHidden = true
        }else {
            self.btnPlay.isHidden = false
        }
    }
    
}


class GridViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgSelect: UIImageView!
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
   
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}


class GiphyCell: UICollectionViewCell {
    
    @IBOutlet var imageView: FLAnimatedImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewContent: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.animatedImage = nil
    }
   
    
    func prepareLayout(content:GiphyDAO) {
    self.viewContent.layer.contents = UIImage(named: "gradient")?.cgImage
     lblName.text = content.name
   // imageView.sd_setShowActivityIndicatorView(true)
//    imageView.sd_setIndicatorStyle(.gray)
        self.imageView.loadImageUsingCacheWithUrlString(content.url) { (isSuccess, image) in
            if isSuccess == true {
            self.imageView.animatedImage = image
            }
        }
//        let url = URL(string:content.url)
//        let queue = DispatchQueue.global(qos: .default)
//        queue.async(execute: {() -> Void in
//            let imgData = try? Data(contentsOf: url!)
//            DispatchQueue.main.sync(execute: {() -> Void in
//                self.imageView.animatedImage = FLAnimatedImage(animatedGIFData: imgData)
//                self.setNeedsLayout()
//            })
//        })
    //imageView.sd_setImage(with: url)
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()
typealias CompletionHandler = (_ success:Bool, _ image:FLAnimatedImage?) -> Void


extension FLAnimatedImageView {
    func loadImageUsingCacheWithUrlString(_ urlString: String,completionHandler: @escaping CompletionHandler) {
        
        self.animatedImage = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? FLAnimatedImage {
            self.animatedImage = cachedImage
            completionHandler(true, self.animatedImage!)
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                completionHandler(false,nil)
                return
            }
            
            DispatchQueue.main.async(execute: {
                if let downloadedImage = FLAnimatedImage(animatedGIFData: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.animatedImage = downloadedImage
                    completionHandler(true,self.animatedImage!)
                }
            })
            
        }).resume()
        
    }
}


