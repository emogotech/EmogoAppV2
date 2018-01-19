//
//  ActionSheetController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit
import XLActionController


open class PMActionCell: ActionCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    func initialize() {
        backgroundColor = .white
        actionImageView?.clipsToBounds = true
        actionImageView?.layer.cornerRadius = 5.0
            actionImageView?.contentMode = .scaleAspectFit
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        selectedBackgroundView = backgroundView
    }
}


open class ActionControllerHeader: UICollectionReusableView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .lightGray
        return bottomLine
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(label)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label]))
        addSubview(bottomLine)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(1)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["line": bottomLine]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[line]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["line": bottomLine]))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class ActionSheetController: ActionController<PMActionCell, ActionData, ActionControllerHeader, String, UICollectionReusableView, Void> {

    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        settings.animation.present.duration = 0.6
        settings.animation.dismiss.duration = 0.6
        cellSpec = CellSpec.nibFile(nibName: "PMActionCell", bundle: Bundle(for: PMActionCell.self), height: { _ in 42 })
        headerSpec = .cellClass(height: { _ -> CGFloat in return 45 })
        
        onConfigureHeader = { header, title in
            header.label.text = title
        }
        onConfigureCellForAction = { [weak self] cell, action, indexPath in
            cell.setup(action.data?.title, detail: action.data?.subtitle, image: action.data?.image)
            if (action.data?.subtitle?.isEmpty)! {
                if indexPath.item == (self?.collectionView.numberOfItems(inSection: indexPath.section))! - 2 {
                    cell.separatorView?.isHidden = false
                }
            }
            cell.alpha = action.enabled ? 1.0 : 0.5
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.clipsToBounds = false
        let hideBottomSpaceView: UIView = {
            let hideBottomSpaceView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: contentHeight + 20))
            hideBottomSpaceView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            hideBottomSpaceView.backgroundColor = .white
            return hideBottomSpaceView
        }()
        collectionView.addSubview(hideBottomSpaceView)
        collectionView.sendSubview(toBack: hideBottomSpaceView)
    }
    
    override open func dismissView(_ presentedView: UIView, presentingView: UIView, animationDuration: Double, completion: ((_ completed: Bool) -> Void)?) {
        onWillDismissView()
        let animationSettings = settings.animation.dismiss
        let upTime = 0.1
        UIView.animate(withDuration: upTime, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.collectionView.frame.origin.y -= 10
            }, completion: { [weak self] (completed) -> Void in
                UIView.animate(withDuration: animationDuration - upTime,
                               delay: 0,
                               usingSpringWithDamping: animationSettings.damping,
                               initialSpringVelocity: animationSettings.springVelocity,
                               options: UIViewAnimationOptions.curveEaseIn,
                               animations: { [weak self] in
                                presentingView.transform = CGAffineTransform.identity
                                self?.performCustomDismissingAnimation(presentedView, presentingView: presentingView)
                    },
                               completion: { [weak self] finished in
                                self?.onDidDismissView()
                                completion?(finished)
                })
        })
    }

}
