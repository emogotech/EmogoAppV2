//
//  MLFiltersViewController.swift
//  Emogo
//
//  Created by Pushpendra on 02/07/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

protocol MLFiltersViewControllerDelegate {
    func selected(image:UIImage)
}

class MLFiltersViewController: UIViewController {
    
    @IBOutlet private weak var gramImageView: UIImageView!
    @IBOutlet private weak var filterCollectionView: UICollectionView!
    
    let filters: [PMFilter] = [
        MosaicFilter(),
        TheScreamFilter(),
        LaMuseFilter(),
        UdnieFilter(),
        CandyFilter(),
        FeathersFilter(),
        ]
    
    var renderedFilterBuffer: [String: ImageBuffer] = [:]
    var imageBuffer: ImageBuffer?
    private var selectedIndex: Int = 0
    let cellIdentifier = "mlFilterCollectionViewCell"
    var image:UIImage?
    var delegate:MLFiltersViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.gramImageView.image = image
        prepareNavigationButton()
        prepareLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func prepareLayout(){
        if let image = gramImageView.image {
            let resizedImage = image.resize(to: CGSize(width: 720, height: 720))
            gramImageView.image = resizedImage
            imageBuffer = resizedImage.buffer()
            loadRenderedImages()
        }
    }
    
    
    
    func prepareNavigationButton() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.3)
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
            let btnSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.actionForSaveButton))
            let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.actionForCancelButton))
            self.navigationItem.leftBarButtonItem = btnCancel
            self.navigationItem.rightBarButtonItem = btnSave
            navigationItem.hidesBackButton = true
    }
    
    
    // MARK: - Private functions
    private func loadRenderedImages() {
        renderedFilterBuffer.removeAll()
        guard let buffer = imageBuffer else {
            return
        }
        
        filters.forEach { (filter) in
            if let filteredBuffer = filter.render(from: buffer) {
                renderedFilterBuffer[filter.name] = filteredBuffer
            }
        }
        
        filterCollectionView.reloadData()
    }
    
    private func updateImageView() {
        guard let imageBuffer = imageBuffer else {
            return
        }
        
        let image = UIImage(imageBuffer: imageBuffer)
        gramImageView.image = image
    }
    
    @objc func actionForSaveButton(){
        if self.delegate != nil {
            self.delegate?.selected(image: self.gramImageView.image!)
        }
        self.dismiss(animated: false, completion: nil)
    }
    @objc func actionForCancelButton(){
        self.dismiss(animated: false, completion: nil)
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

// MARK: - UICollectionViewDataSource
extension MLFiltersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MLFilterCollectionViewCell
        cell.isSelected = selectedIndex == indexPath.row
        
        let filter = filters[indexPath.row]
        if let buffer = renderedFilterBuffer[filter.name] {
            cell.setup(with: filter, imageBuffer: buffer)
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension MLFiltersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MLFilterCollectionViewCell
        
        // Scroll to item selected.
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // Deselect old item if there was one.
        deselectOldItem(collectionView: collectionView)
        // Set current selected.
        cell.isSelected = true
        // Save index of selected item.
        selectedIndex = indexPath.row
        
        let filter = filters[indexPath.row]
        if let buffer = renderedFilterBuffer[filter.name] {
            imageBuffer = buffer
        }
        updateImageView()
    }
    
    func deselectOldItem(collectionView: UICollectionView) {
        if let itemsSelected = collectionView.indexPathsForSelectedItems?.first {
            let previouslySelectedCell = collectionView.cellForItem(at: itemsSelected)
            previouslySelectedCell?.isSelected = false
        }
    }
    
}



class MLFilterCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var filterImageView: UIImageView!
    
    // MARK: - Overriden function
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // animate selection
                nameLabel.font = UIFont.boldSystemFont(ofSize: 13)
            } else {
                // animate deselection
                nameLabel.font = UIFont.systemFont(ofSize: 13)
            }
        }
    }
    
    // MARK: - Public functions
    /// Setup collection view cell with given filter and image buffer.
    ///
    /// - Parameters:
    ///   - filter: Filter.
    ///   - imageBuffer: Image buffer used to showed a preview of the filter work.
    func setup(with filter: PMFilter, imageBuffer: ImageBuffer) {
        nameLabel.text = filter.name
        filterImageView.image = UIImage(imageBuffer: imageBuffer)
    }
    
}
