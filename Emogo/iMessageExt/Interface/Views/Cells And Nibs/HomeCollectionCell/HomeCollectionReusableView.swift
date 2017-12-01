//
//  HomeCollectionReusableView.swift
//  iMessageExt
//
//  Created by Sushobhit on 01/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class HomeCollectionReusableView: UICollectionReusableView {
    
    var loadingView : LoadingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initalizeloadingView()
    }
    
    func initalizeloadingView(){
        loadingView  = LoadingView.init(frame: frame)
        self.addSubview(loadingView)
        loadingView.load?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        loadingView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        loadingView.load?.lineWidth = 3.0
        loadingView.load?.duration = 2.0
        loadingView.loaderImage?.isHidden = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.widthAnchor.constraint(equalToConstant: self.frame.size.width).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: self.frame.size.height).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingView.load?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        loadingView.load?.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //reset the animation
    func startAnimate() {
        loadingView.startLoaderWithAnimation()
    }
    
    func stopAnimate() {
        loadingView.stopLoaderWithAnimation()
    }
    
}
