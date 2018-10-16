//
//  ActionSheetViewController.swift
//  Emogo
//
//  Created by Northout on 13/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

//MARK: ⬇︎⬇︎⬇︎ PROTOCOLS ⬇︎⬇︎⬇︎


protocol ActionSheetViewControllerDelegate {
   
    func didSelectAction(type:String)
}


class ActionSheetViewController: UIViewController {
    
    //MARK: ⬇︎⬇︎⬇︎ UI Elements ⬇︎⬇︎⬇︎
    
    @IBOutlet weak var btnCreateNewEmogo: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var tblOptions: UITableView!
    @IBOutlet weak var kCreateEmogoConstraints: NSLayoutConstraint!
 
    @IBOutlet weak var lblOr: UILabel!
    
    var delegate : ActionSheetViewControllerDelegate!
    var collectionLayout = CHTCollectionViewWaterfallLayout()
    let fontSelected = UIFont(name: "SFProDisplay-Regular", size: 12.0)
    var fromViewStream =  false
    var menuItems = ActionSheetModel()
    
    
    //MARK: ⬇︎⬇︎⬇︎ Override Functions ⬇︎⬇︎⬇︎

    override func viewDidLoad() {
        super.viewDidLoad()
      
        if fromViewStream == true {
   
          self.btnCreateNewEmogo.isHidden = true
          self.lblOr.isHidden = true
        }else{
    
          self.lblOr.isHidden = false
        }
     
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: ⬇︎⬇︎⬇︎ Action Methods And Selector ⬇︎⬇︎⬇︎

    @IBAction func btnClose(_ sender: Any) {
        self.dismissWithAnimation {
            
        }
    }
    
    @IBAction func actionForCreateEmogo(_ sender: Any) {
    
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


