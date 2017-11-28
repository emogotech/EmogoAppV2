//
//  AddStreamViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import DKImagePickerController

class AddStreamViewController: UITableViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var txtStreamName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtStreamCaption: UITextView!
    @IBOutlet weak var switchMakePrivate: PMSwitch!
    @IBOutlet weak var switchAddCollaborators: PMSwitch!
    @IBOutlet weak var switchAnyOneCanEdit: PMSwitch!
    @IBOutlet weak var switchAddContent: PMSwitch!
    @IBOutlet weak var switchAddPeople: PMSwitch!
    @IBOutlet weak var lblAnyOneCanEdit: UILabel!
    @IBOutlet weak var rowHieght: NSLayoutConstraint!
    @IBOutlet weak var imgCover: UIImageView!

    // Varibales

    var isExpandRow: Bool = false {
        didSet {
            self.configureCollaboatorsRowExpandCollapse()
        }
    }
    
    
    // MARK: - Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareLayouts()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareLayoutForApper()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

    // MARK: - Prepare Layouts
    
    private func prepareLayouts(){
        self.title = "Create a Stream"
        self.configureNavigationWithTitle()
        txtStreamName.title = "Stream Name"
      //  let tap = UITapGestureRecognizer(target: self, action: #selector(self.disMissKeyboard))
       // self.view.addGestureRecognizer(tap)

    }
    
    func prepareLayoutForApper(){
        self.viewGradient.layer.contents = UIImage(named: "strems_name_gradient")?.cgImage
    }

    @IBAction func addContentAction(_ sender: PMSwitch) {
    }
    @IBAction func addPeopleAction(_ sender: PMSwitch) {
    }
    @IBAction func anyOneCanEditAction(_ sender: PMSwitch) {
    }
    @IBAction func makePrivateAction(_ sender: PMSwitch) {
    }
    @IBAction func addCollaboatorsAction(_ sender: PMSwitch) {
        if sender.isOn {
            self.rowHieght.constant = 325.0
            self.isExpandRow = true
        }else {
            self.rowHieght.constant = 0.0
            self.isExpandRow = false
        }
    }
    @IBAction func btnActionDone(_ sender: Any) {
    }
    
    @IBAction func btnActionCamera(_ sender: Any) {
        let pickerController = DKImagePickerController()
        pickerController.sourceType = .both
        pickerController.singleSelect = true
        pickerController.allowMultipleTypes = false
        pickerController.assetType = .allPhotos
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            if assets.count != 0 {
                self.setCoverImage(asset: assets[0])
            }
        }
        self.present(pickerController, animated: true, completion: nil)
        
    }
    
    // MARK: - CLASS FUNCTION
    // MARK: - Expand Collapse Row

    func configureCollaboatorsRowExpandCollapse() {
            self.tableView.beginUpdates()
            let index = IndexPath(row: 3, section: 0)
            self.tableView.reloadRows(at: [index], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.reloadData()
    }

    // MARK: - Set Cover Image

    func setCoverImage(asset:DKAsset) {
        let width = self.imgCover.bounds.size.width * 2.0
        let height = self.imgCover.bounds.size.height * 2.0

        asset.fetchOriginalImageWithCompleteBlock { (image, info) in
            if let img = image {
                self.imgCover.image = img.withImage(img, scaledToMaxWidth: width, maxHeight: height)
            }
        }
    }
    @objc func disMissKeyboard(){
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



// MARK: - EXTENSION

// MARK: - DataSource And Delegate

extension AddStreamViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isExpandRow  && indexPath.row == 3{
            return 340.0
        }else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
}
