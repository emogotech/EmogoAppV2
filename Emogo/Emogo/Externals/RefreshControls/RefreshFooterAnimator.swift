//
//  RefreshFooterAnimator.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import BPCircleActivityIndicator

class RefreshFooterAnimator: UIView ,ESRefreshProtocol, ESRefreshAnimatorProtocol{
    
    public var view: UIView {
        return self
    }
    public var insets: UIEdgeInsets = UIEdgeInsets.zero
    public var trigger: CGFloat = 48.0
    public var executeIncremental: CGFloat = 48.0
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
        loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    public func refreshAnimationBegin(view: ESRefreshComponent) {
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
        switch state {
        case .refreshing :
            break
        case .autoRefreshing :
            break
        case .noMoreData:
            break
        default:
            break
        }
    }
}
