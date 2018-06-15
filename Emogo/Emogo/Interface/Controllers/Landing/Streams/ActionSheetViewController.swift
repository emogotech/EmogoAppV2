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

    var delegate : ActionSheetViewControllerDelegate!
    
    let fontSelected = UIFont(name: "SFProDisplay-Regular", size: 12.0)
    var fromViewStream =  false
    var menuItems = ActionSheetModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       self.tblOptions.delegate = self
       self.tblOptions.dataSource = self
        
        if fromViewStream == true {
            self.kCreateEmogoConstraints.constant = 0
        }else{
            self.kCreateEmogoConstraints.constant = 60
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tblOptions.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //MARK:- Button Action
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionForCreateEmogo(_ sender: Any) {
      // self.actionForAddStream()
        self.dismiss(animated: true) {
            if self.delegate != nil {
                self.delegate.didSelectAction(type: "7")
            }
        }
    }
}
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
        if title == "Photo/Videos" {
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
        self.dismiss(animated: true) {
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
   
}
