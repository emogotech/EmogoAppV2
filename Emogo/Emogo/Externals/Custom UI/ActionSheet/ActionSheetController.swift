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
        //actionImageView?.contentMode = .scaleAspectFit
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        selectedBackgroundView = backgroundView
    }
}


open class ActionControllerHeader: UICollectionReusableView {
    
    let btnHeader   :   UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints   =   false
        return btn
    }()
    
    let topView :   UIView  =   {
        let tView        =       UIView()
        tView.translatesAutoresizingMaskIntoConstraints     =       false
        return tView
    }()
    
    var imgIcon :UIImageView = {
        let icon     =       UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints  =   false
        return icon
    }()
    
    let lblTopViewTitle     :   UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let lblBottomViewTitle     :   UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    var btnCross: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let bottomView  :   UIView  =   {
        let bottomView       =       UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints    =   false
        return bottomView
    }()
    
    
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
    
    lazy var topViewBottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .lightGray
        return bottomLine
    }()
    
    lazy var bottomViewBottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .lightGray
        return bottomLine
    }()
    
    var shouldShowAddStreamButton : Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        //TopView
        let currentHeight       =       self.frame.size.height
        
        if currentHeight == 100 {
            self.addSubview(topView)
            self.topView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive  =   true
            self.topView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0 ).isActive   =   true
            self.topView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive    =   true
            self.topView.heightAnchor.constraint(equalToConstant: currentHeight / 2 + 10).isActive = true
            
            self.topView.addSubview(self.imgIcon)
            self.imgIcon.leftAnchor.constraint(equalTo: self.topView.leftAnchor, constant: 5).isActive  =   true
            self.imgIcon.heightAnchor.constraint(equalToConstant: (currentHeight/2 - 10)).isActive      =   true
            self.imgIcon.widthAnchor.constraint(equalToConstant: (currentHeight/2 - 10)).isActive      =   true
            self.imgIcon.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor).isActive =   true
            self.imgIcon.image  =  #imageLiteral(resourceName: "action_stream_add_icon")
            
            self.topView.addSubview(self.lblTopViewTitle)
            self.lblTopViewTitle.leftAnchor.constraint(equalTo: self.imgIcon.rightAnchor, constant: 10).isActive    =   true
            self.lblTopViewTitle.centerYAnchor.constraint(equalTo: self.imgIcon.centerYAnchor).isActive     =       true
            
            self.topView.addSubview(self.btnCross)
            self.btnCross.rightAnchor.constraint(equalTo: self.topView.rightAnchor, constant: -5).isActive    =   true
            self.btnCross.leftAnchor.constraint(equalTo: self.lblTopViewTitle.rightAnchor, constant: 5).isActive    =   true
            self.btnCross.heightAnchor.constraint(equalToConstant: (currentHeight/2 - 10)).isActive      =   true
            self.btnCross.widthAnchor.constraint(equalToConstant: (currentHeight/2 - 10)).isActive      =   true
            self.btnCross.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor).isActive =   true
            
            self.topView.addSubview(self.topViewBottomLine)
            self.topViewBottomLine.heightAnchor.constraint(equalToConstant: 1).isActive    =   true
            self.topViewBottomLine.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor).isActive    =   true
            self.topViewBottomLine.rightAnchor.constraint(equalTo: self.topView.rightAnchor).isActive  =   true
            self.topViewBottomLine.leftAnchor.constraint(equalTo: self.topView.leftAnchor).isActive  =   true
            
            self.topView.addSubview(btnHeader)
            btnHeader.leftAnchor.constraint(equalTo: self.topView.leftAnchor).isActive = true
            btnHeader.topAnchor.constraint(equalTo: self.topView.topAnchor).isActive = true
            btnHeader.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor).isActive = true
            btnHeader.rightAnchor.constraint(equalTo: self.btnCross.leftAnchor, constant: 10).isActive = true
            
        }else{
            self.topView.heightAnchor.constraint(equalToConstant: 0).isActive =   true
        }
        
        //BottomView
        
        self.addSubview(bottomView)
        self.bottomView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive  =   true
        if currentHeight == 100 {
            self.bottomView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 0 ).isActive   =   true
        }else{
            self.bottomView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0 ).isActive   =   true
        }
        self.bottomView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive    =   true
        self.bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive   =   true
        
        self.bottomView.addSubview(self.lblBottomViewTitle)
        self.lblBottomViewTitle.text    =   "ADD FROM"
        self.lblBottomViewTitle.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor).isActive   =   true
        self.lblBottomViewTitle.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor).isActive   =   true
        
        self.bottomView.addSubview(self.bottomViewBottomLine)
        self.bottomViewBottomLine.heightAnchor.constraint(equalToConstant: 1).isActive    =   true
        self.bottomViewBottomLine.bottomAnchor.constraint(equalTo: self.bottomView.bottomAnchor).isActive    =   true
        self.bottomViewBottomLine.rightAnchor.constraint(equalTo: self.bottomView.rightAnchor).isActive  =   true
        self.bottomViewBottomLine.leftAnchor.constraint(equalTo: self.bottomView.leftAnchor).isActive  =   true
        
        //        addSubview(label)
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label]))
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label]))
        //
        //        addSubview(btnCross)
        //        btnCross.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        //        btnCross.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        //        let height : CGFloat = self.frame.size.height - 10
        //        btnCross.heightAnchor.constraint(lessThanOrEqualToConstant: height).isActive = true
        //        btnCross.widthAnchor.constraint(lessThanOrEqualToConstant: height).isActive = true
        //        btnCross.backgroundColor = .clear
        //
        //        addSubview(bottomLine)
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(1)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["line": bottomLine]))
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[line]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["line": bottomLine]))
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol ActionSheetControllerHeaderActionDelegate {
    func actionSheetControllerHeaderButtonAction()
}

class ActionSheetController: ActionController<PMActionCell, ActionData, ActionControllerHeader, String, UICollectionReusableView, Void> {
    
    var delegate : ActionSheetControllerHeaderActionDelegate!
    
    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        settings.behavior.hideOnScrollDown = false
        settings.animation.scale = nil
        settings.animation.present.duration = 0.6
        settings.animation.dismiss.duration = 0.6
        settings.animation.dismiss.offset = 30
        settings.animation.dismiss.options = .curveLinear
        
        cellSpec = CellSpec.nibFile(nibName: "PMActionCell", bundle: Bundle(for: PMActionCell.self), height: { _ in 52 })//42
        headerSpec = .cellClass(height: { _ -> CGFloat in
            return (self.shouldShowAddButton ? 100 : 45 )  })
        
        onConfigureHeader = { header, title in
            header.label.text = title
            header.btnCross.setImage(#imageLiteral(resourceName: "action_cross_image"), for: .normal)
            header.btnCross.addTarget(self, action: #selector(self.hideView), for: .touchUpInside)
            header.btnHeader.addTarget(self, action: #selector(self.headerViewTapped), for: .touchUpInside)
            header.lblTopViewTitle.text =   "Create New Emogo"
        }
        onConfigureCellForAction = { [weak self] cell, action, indexPath in
            cell.setup(action.data?.title, detail: action.data?.subtitle, image: action.data?.image)
            //            if (action.data?.subtitle?.isEmpty)! {
            //                if indexPath.item == (self?.collectionView.numberOfItems(inSection: indexPath.section))! - 2 {
            //                    cell.separatorView?.isHidden = false
            //                }
            //                if indexPath.item == (self?.collectionView.numberOfItems(inSection: indexPath.section))! - 1{
            //                    cell.actionTitleLabel?.font = UIFont.init(name: kFontMedium, size: 16)
            //                    cell.actionTitleLabel?.textColor = UIColor.init(r: 65, g: 64, b: 64)
            //                }
            //            }
            cell.alpha = action.enabled ? 1.0 : 0.5
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var shouldShowAddButton =   true
    
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
    
    @objc func hideView(){
        self.dismiss()
    }
    
    @objc func headerViewTapped(){
        print("Header Tapped")
        self.dismiss()
        self.delegate.actionSheetControllerHeaderButtonAction()
    }
    
}

