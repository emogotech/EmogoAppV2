//
//  RefreshHeaderAnimator.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import ESPullToRefresh

class RefreshHeaderAnimator: UIView,ESRefreshProtocol, ESRefreshAnimatorProtocol {
    
   
    public var insets: UIEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0)
    public var view: UIView { return self }
    public var duration: TimeInterval = 0.3
    public var trigger: CGFloat = 56.0
    public var executeIncremental: CGFloat = 56.0
    public var state: ESRefreshViewState = .pullToRefresh
    
    var loadingView : LoadingView = {
        let loading = LoadingView(frame: .zero)
        loading.load?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        loading.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        loading.load?.lineWidth = 3.0
        loading.load?.duration = 2.0
        loading.loaderImage?.isHidden = true
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
        loadingView.widthAnchor.constraint(equalToConstant: self.frame.size.width).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: self.frame.size.height).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingView.load?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        loadingView.load?.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    public func refreshAnimationBegin(view: ESRefreshComponent) {
        loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingView.startLoaderWithAnimation()
    }

    public func refreshAnimationEnd(view: ESRefreshComponent) {
        loadingView.stopLoaderWithAnimation()
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

