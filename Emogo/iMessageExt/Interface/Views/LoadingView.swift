//
//  LoadingView.swift
//  iMessageExt
//
//  Created by Sushobhit on 11/18/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    // MARK: - Variables
    var load : KDLoadingView?
    var loaderImage : UIImageView?
    
    // MARK: - Override methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpLoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Loader Setup
    func setUpLoder() {
        self.isHidden  = true
        self.backgroundColor = UIColor.black
        self.alpha = iMsg_hudAlphaConstant

        load = KDLoadingView.init()
        load?.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        load?.backgroundColor = UIColor.clear
        load?.duration = 2.5
        load?.lineWidth = 5.0
        load?.firstColor = #colorLiteral(red: 0, green: 0.6745098039, blue: 0.9307156205, alpha: 1)
        load?.secondColor = #colorLiteral(red: 0.001609396073, green: 0.6759747267, blue: 0.9307156205, alpha: 1)
        load?.thirdColor = #colorLiteral(red: 0.001609396073, green: 0.6759747267, blue: 0.9307156205, alpha: 1)
        
        self.addSubview(load!)
        
        load?.translatesAutoresizingMaskIntoConstraints = false
        load?.widthAnchor.constraint(equalToConstant: 60).isActive = true
        load?.heightAnchor.constraint(equalToConstant: 60).isActive = true
        load?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        load?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
        
        loaderImage = UIImageView(frame:  CGRect(x: 0, y: 0, width: 50, height: 50))
        loaderImage?.image = #imageLiteral(resourceName: "loader")
        self.addSubview(loaderImage!)
        loaderImage?.translatesAutoresizingMaskIntoConstraints = false
        loaderImage?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        loaderImage?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loaderImage?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loaderImage?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
    }
    
    // MARK: - Start Loader
    func startLoaderWithAnimation()  {
        self.isHidden  = false
        self.load?.startAnimating()
    }
    
    // MARK: - Stop Loader
    @objc func stopLoaderWithAnimation()  {
         self.isHidden  = true
        self.load?.stopAnimating()
    }
}
