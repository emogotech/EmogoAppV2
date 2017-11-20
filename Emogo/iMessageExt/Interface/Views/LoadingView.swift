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
        load?.duration = 4.0
        load?.lineWidth = 6
        load?.firstColor = UIColor.red
        load?.secondColor = UIColor.red
        load?.thirdColor = UIColor.red
        
        self.addSubview(load!)
        
        load?.translatesAutoresizingMaskIntoConstraints = false
        load?.widthAnchor.constraint(equalToConstant: 60).isActive = true
        load?.heightAnchor.constraint(equalToConstant: 60).isActive = true
        load?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        load?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
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
