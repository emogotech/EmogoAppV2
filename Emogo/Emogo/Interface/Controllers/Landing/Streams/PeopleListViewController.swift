//
//  PeopleListViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import ESPullToRefresh

class PeopleListViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var peopleCollectionView: UICollectionView!
    
    
    // MARK: - Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Prepare Layouts
    
    func prepareLayouts(){
        self.title = "People List"
        self.configureNavigationWithTitle()
        peopleCollectionView.alwaysBounceVertical = true

        HUDManager.sharedInstance.showHUD()
        self.getUsersList(type:.start)
        let header = RefreshHeaderAnimator(frame: .zero)
        let  footer = RefreshFooterAnimator(frame: .zero)
        
        self.peopleCollectionView.es.addPullToRefresh(animator: header) { [weak self] in
            self?.getUsersList(type:.up)
        }
        self.peopleCollectionView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            self?.getUsersList(type:.down)
        }
        
    }

    // MARK: -  Action Methods And Selector

    // MARK: - Class Methods

    
    // MARK: - API Methods
    func getUsersList(type:RefreshType){
        if type == .start || type == .up {
            UIApplication.shared.beginIgnoringInteractionEvents()
            PeopleList.sharedInstance.arrayPeople.removeAll()
            self.peopleCollectionView.reloadData()
        }
        APIServiceManager.sharedInstance.apiForGetPeopleList(type:type) { (refreshType, errorMsg) in
            if type == .start {
                HUDManager.sharedInstance.hideHUD()
            }
            if refreshType == .end {
                self.peopleCollectionView.es.stopLoadingMore()
            }
            if type == .up {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.peopleCollectionView.es.stopPullToRefresh()
            }else if type == .down {
                self.peopleCollectionView.es.stopLoadingMore()
            }
            self.peopleCollectionView.reloadData()
            if !(errorMsg?.isEmpty)! {
                self.showToast(type: .success, strMSG: errorMsg!)
            }
        }
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


extension PeopleListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PeopleList.sharedInstance.arrayPeople.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell and return the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCell_PeopleCell, for: indexPath) as! PeopleCell
           let people = PeopleList.sharedInstance.arrayPeople[indexPath.row]
            cell.prepareData(people:people)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width/3.0 - 12.0
        return CGSize(width: itemWidth, height: 100)
    }
    
    
}
