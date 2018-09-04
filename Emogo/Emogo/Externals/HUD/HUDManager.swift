//
//  HUDManager.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import BPCircleActivityIndicator

class HUDManager: NSObject {
    
    var overlayView         : UIView = UIView()

    class var sharedInstance: HUDManager {
        struct Static {
            static let instance: HUDManager = HUDManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        setupView()
    }
    
    var loadingView : BPCircleActivityIndicator = {
        
        let loading = BPCircleActivityIndicator()
        loading.isHidden = false
        loading.translatesAutoresizingMaskIntoConstraints = false
        return loading
    }()
    
    
    
    private func setupView(){
     
        overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.tag = 7832
        overlayView.backgroundColor = .clear
        
        if let view = AppDelegate.appDelegate.window?.viewWithTag(7832) {
            view.removeFromSuperview()
        }
        
        AppDelegate.appDelegate.window?.addSubview(overlayView)
        overlayView.addSubview(loadingView)
        // loadingView.widthAnchor.constraint(equalToConstant: self.frame.size.width).isActive = true
        //loadingView.heightAnchor.constraint(equalToConstant: self.frame.size.height).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.overlayView.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.overlayView.centerYAnchor).isActive = true

       // loadingView.topAnchor.constraint(equalTo: self.overlayView.topAnchor, constant: 15.0).isActive = true
         loadingView.widthAnchor.constraint(equalToConstant: 25).isActive = true
         loadingView.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    
    let activityIndicator : PMProgressHUD = {
        let view = PMProgressHUD(frame: CGRect.zero)
        view.imgLogo = UIImage(named:"loader")!
         view.tintColor = UIColor.black
        view.firstColor = UIColor(r: 186.0, g: 186.0, b: 189.0)
        view.secondColor = UIColor(r: 0, g: 122.0, b: 255.0)
        view.thirdColor = UIColor(r: 186.0, g: 186.0, b: 189.0)
        view.duration = 2.5
        view.lineWidth = 5.0
        view.bgColor =  UIColor.white.withAlphaComponent(0.7)
      //   view.bgColor =  UIColor.white
        return view
    }()
    
    func showHUD(){
        UIApplication.shared.beginIgnoringInteractionEvents()
      //  self.activityIndicator.show()
        overlayView.isHidden = false
        
        loadingView.rotateSpeed(0.2).interval(0.1).animate()
    }
    func hideHUD(){
        UIApplication.shared.endIgnoringInteractionEvents()
       // self.activityIndicator.hide()
        loadingView.stop()
        overlayView.isHidden = true
    }
    func showProgress(){
        print("Gradient bar shwoing")
        GradientLoadingBar.shared.show()
    }
    
    func hideProgress(){
        GradientLoadingBar.shared.hide()
    }
    
}
