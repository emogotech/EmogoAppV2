//
//  VideoEditor+PlayRate.swift
//  Emogo
//
//  Created by Pushpendra on 21/05/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation

extension VideoEditorViewController  {
    
    func  prepareForPlayRate(){
        let alert = UIAlertController(title: "Video Play Rate", message: nil, preferredStyle: .actionSheet)
        let low = UIAlertAction(title: "1X", style: .destructive) { (action) in
            self.applySelected(rate: 1.5)
        }
        let medium = UIAlertAction(title: "2X", style: .destructive) { (action) in
            self.applySelected(rate: 2.0)
        }
        let high = UIAlertAction(title: "3X", style: .destructive) { (action) in
            self.applySelected(rate: 2.5)
        }
       
        let original = UIAlertAction(title: "original", style: .destructive) { (action) in
            self.applySelected(rate: 1.0)
        }
        
        let cancel = UIAlertAction(title: kAlert_Cancel_Title, style: .cancel) { (action) in
            self.configureNavigationButtons()
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(low)
        alert.addAction(medium)
        alert.addAction(high)
        alert.addAction(original)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func applySelected(rate:Float){
        let (start,end) = self.editManager.getFileDuration(file: self.localFileURl!)
        if let start = start ,let end = end {
            self.editManager.setVideoRate(path: self.localFileURl!, rate: rate, begin: Float64(start), end: end, progress: { (progress, strprogress) in
                
            }, finish: { (fileURL, error) in
                if let fileURL = fileURL {
                    DispatchQueue.main.async {
                        self.configureNavigationForEditing()
                        self.updatePlayerAsset(videURl: fileURL)
                    }
                }
            })
        }
    }
    
}
