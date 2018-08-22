//
//  ActionSheetViewController.swift
//  Emogo
//
//  Created by Northout on 13/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

protocol ActionSheetViewControllerDelegate {
   
    func didSelectAction(type:String)
}
class ActionSheetViewController: UIViewController {
    
    //MARK:- IBOutlet Connections
    
    @IBOutlet weak var btnCreateNewEmogo: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var tblOptions: UITableView!
    @IBOutlet weak var kCreateEmogoConstraints: NSLayoutConstraint!
  //  @IBOutlet weak var collectionOption: UICollectionView!
    @IBOutlet weak var lblOr: UILabel!
    
    var delegate : ActionSheetViewControllerDelegate!
    var collectionLayout = CHTCollectionViewWaterfallLayout()
    let fontSelected = UIFont(name: "SFProDisplay-Regular", size: 12.0)
    var fromViewStream =  false
    var menuItems = ActionSheetModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//       self.tblOptions.delegate = self
//       self.tblOptions.dataSource = self
        
      //  self.collectionOption.delegate = self
        //self.collectionOption.dataSource = self
        
        if fromViewStream == true {
        // self.kCreateEmogoConstraints.constant = 0
          self.btnCreateNewEmogo.isHidden = true
          self.lblOr.isHidden = true
        }else{
        //  self.kCreateEmogoConstraints.constant = 80
          self.lblOr.isHidden = false
        }
     //   self.prepareLayout()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // self.collectionOption.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func prepareLayout() {
        
        collectionLayout.minimumColumnSpacing = 0.0
        collectionLayout.minimumInteritemSpacing = 0.0
        collectionLayout.columnCount = 3
        // Collection view attributes
        self.collectionOption.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.collectionOption.alwaysBounceVertical = true
        
        // Add the waterfall layout to your collection view
        self.collectionOption.collectionViewLayout = collectionLayout
        
    }*/
 
    //MARK:- Button Action
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismissWithAnimation {
            
        }
    }
    @IBAction func actionForCreateEmogo(_ sender: Any) {
      // self.actionForAddStream()
        self.dismissWithAnimation {
            if self.delegate != nil {
                self.delegate.didSelectAction(type: "7")
            }
        }
    }
    //MARK:-  Action for buttons
    
    @IBAction func actionForContentOptions(_ sender: UIButton) {
        var strType:String! = ""
        if sender.tag == 1 {
            strType = "2"
        }else if sender.tag == 0 {
            strType = "1"
        }else if sender.tag == 2 {
            strType = "3"
        }else if sender.tag == 3 {
            strType = "4"
        }else if sender.tag == 5 {
            strType = "6"
        }else if sender.tag == 4 {
            strType = "5"
        }
        self.dismissWithAnimation {
            if self.delegate != nil {
                self.delegate.didSelectAction(type: strType)
            }
        }
    }
}





/*
    //MARK:- tableview delegate & datasource

extension ActionSheetViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.arrayActions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ActionSheetViewCell =  tableView.dequeueReusableCell(withIdentifier: kCell_ActionSheetCell) as! ActionSheetViewCell
        cell.lblTitle.text  = self.menuItems.arrayActions[indexPath.row].iconName
        cell.imgOption.image = self.menuItems.arrayActions[indexPath.row].icon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let title = self.menuItems.arrayActions[indexPath.row].iconName
        var strType:String! = ""
        if title == "Photos/Videos" {
            strType = "1"
        }else if title == "Camera" {
            strType = "2"
        }else if title == "Link" {
            strType = "3"
        }else if title == "Note" {
            strType = "4"
        }else if title == "Gif" {
            strType = "5"
        }else if title == "My Stuff" {
            strType = "6"
        }
        self.dismissWithAnimation {
            if self.delegate != nil {
                self.delegate.didSelectAction(type: strType)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableHeight =  tblOptions.bounds.size.height
        let cellHeight  =  tableHeight/6
        return cellHeight
    }
    
    
}*/

/*
//MARK:- collectionView delegate and datasource

extension ActionSheetViewController:UICollectionViewDelegate, UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout {
   

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         print(self.menuItems.arrayActions.count)
         return self.menuItems.arrayActions.count
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ActionSheetCollectionCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ActionSheetCollectionCell", for: indexPath) as! ActionSheetCollectionCell
//        cell.lblNameOption.text  = self.menuItems.arrayActions[indexPath.row].iconName
//        cell.imgOption.image = self.menuItems.arrayActions[indexPath.row].icon
         let image = self.menuItems.arrayActions[indexPath.row].icon
        cell.btnOptionMenu.setImage(image, for: .normal)
        cell.lblNameOption.text =  self.menuItems.arrayActions[indexPath.row].iconName
        switch indexPath.row {
        case 0:
            cell.imgRight.isHidden = false
            cell.imgBottom.isHidden = false
            cell.imgTop.isHidden = true
            cell.imgLeft.isHidden = true

            break
        case 1:
             cell.imgRight.isHidden = false
            cell.imgBottom.isHidden = false
            cell.imgTop.isHidden = true
            cell.imgLeft.isHidden = true
            break
        case 2:
            cell.imgRight.isHidden = true
            cell.imgBottom.isHidden = false
            cell.imgTop.isHidden = true
            cell.imgLeft.isHidden = true
            
            break
        case 3:
            cell.imgRight.isHidden = false
            cell.imgBottom.isHidden = true
            cell.imgTop.isHidden = true
            cell.imgLeft.isHidden = true
            
            break
        case 4:
          
            cell.imgRight.isHidden = false
            cell.imgBottom.isHidden = true
            cell.imgTop.isHidden = true
            cell.imgLeft.isHidden = true
            
            break
        case 5:

            cell.imgRight.isHidden = true
            cell.imgBottom.isHidden = true
            cell.imgTop.isHidden = true
            cell.imgLeft.isHidden = true
            
            break
        default:
            break
        }
       
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        var strType:String! = ""
        if indexPath.row == 0 {
            strType = "2"
        }else if indexPath.row == 1 {
            strType = "1"
        }else if indexPath.row == 2 {
            strType = "3"
        }else if indexPath.row == 3 {
            strType = "4"
        }else if indexPath.row == 4 {
            strType = "6"
        }else if indexPath.row == 5 {
            strType = "5"
        }
        self.dismissWithAnimation {
            if self.delegate != nil {
                self.delegate.didSelectAction(type: strType)
            }
        }
    }
    
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    let itemHeight = collectionView.bounds.size.height/2.0

    if indexPath.row == 1 && indexPath.row == 4{
        let itemWidth = collectionView.bounds.size.width/3 + 20
          return CGSize(width: itemWidth,height: itemHeight)
     }else{
        let itemWidth = collectionView.bounds.size.width/3 - 20
        return CGSize(width: itemWidth, height: itemHeight)
        }
    }
}*/
