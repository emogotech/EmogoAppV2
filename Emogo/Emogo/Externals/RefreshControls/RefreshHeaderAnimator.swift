//
//  RefreshHeaderAnimator.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import BPCircleActivityIndicator

class RefreshHeaderAnimator: UIView,ESRefreshProtocol, ESRefreshAnimatorProtocol {
    
   
    public var insets: UIEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0)
    public var view: UIView { return self }
    public var duration: TimeInterval = 0.3
    public var trigger: CGFloat = 56.0
    public var executeIncremental: CGFloat = 56.0
    public var state: ESRefreshViewState = .pullToRefresh
    
    var loadingView : BPCircleActivityIndicator = {
        
        let loading = BPCircleActivityIndicator()
        loading.isHidden = true
        loading.translatesAutoresizingMaskIntoConstraints = false
        return loading
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView(){
        self.addSubview(loadingView)
       // loadingView.widthAnchor.constraint(equalToConstant: self.frame.size.width).isActive = true
        //loadingView.heightAnchor.constraint(equalToConstant: self.frame.size.height).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    public func refreshAnimationBegin(view: ESRefreshComponent) {
      //  loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
       // loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingView.isHidden = false
        loadingView.rotateSpeed(0.2).interval(0.1).animate()
    }

    public func refreshAnimationEnd(view: ESRefreshComponent) {
        loadingView.stop()
        loadingView.isHidden = true

    }
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
    }
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        
        switch state {
        case .refreshing:
            print("refreshing")
            break
        case .pullToRefresh:
            print("pull")
          //  loadingView.startLoaderWithAnimation()
            break
        case .releaseToRefresh:
            print("release")
           // loadingView.startLoaderWithAnimation()
            break
        default:
            break
        }
    }
    
}

