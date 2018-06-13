//
//  ActionSheetViewController.swift
//  Emogo
//
//  Created by Northout on 13/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

class ActionSheetViewController: UIViewController {
    
    //MARK:- IBOutlet Connections
    
    @IBOutlet weak var btnCreateNewEmogo: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var tblOptions: UITableView!
    
    let fontSelected = UIFont(name: "SFProDisplay-Regular", size: 12.0)
    
    let arrImages = ["action_photo_video","action_camera_icon","action_link_icon","action_link_icon","action_giphy_icon","action_my_stuff"]
    let arrTitle  = ["Photo/Videos","Camera","Link","Note","Gif","My Stuff"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       self.tblOptions.delegate = self
       self.tblOptions.dataSource = self
        
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
        self.actionForAddStream()
    }
}
    //MARK:- tableview delegate & datasource

extension ActionSheetViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ActionSheetViewCell =  tableView.dequeueReusableCell(withIdentifier: kCell_ActionSheetCell) as! ActionSheetViewCell
        cell.lblTitle.text  = self.arrTitle[indexPath.row]
        cell.imgOption.image = UIImage(named: self.arrImages[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     let title = self.arrTitle[indexPath.row]
        if title == "Photo/Videos" {
            self.btnImportAction()
        }else if title == "Camera" {
            self.actionForCamera()
        }else if title == "Link" {
            self.btnActionForLink()
        }else if title == "Note" {
            self.btnActionForNotes()
        }else if title == "Gif" {
            self.btnActionForGiphy()
        }else if title == "My Stuff" {
            self.btnActionForMyStuff()
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        let tableHeight =  tblOptions.contentSize.height
////        let cellHeight  =  tableHeight/6
////        return cellHeight
//    }
   
}
