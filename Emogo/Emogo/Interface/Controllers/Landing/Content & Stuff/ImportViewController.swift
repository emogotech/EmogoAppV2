//
//  ImportViewController.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/17.
//  Copyright © 2017 Vikas Goyal. All rights reserved.
//

import UIKit
import Gallery

class ImportViewController: UIViewController {

    // MARK: - UI Elements
    
    // MARK: - Variables
    
    var gallery: GalleryController!
    let editor: VideoEditing = VideoEditor()
    
    // MARK: - Override Functions
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.prepareLayouts()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareGalleryView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareLayouts(){
        Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
        Gallery.Config.tabsToShow = [.imageTab, .videoTab]
        Gallery.Config.initialTab =  .imageTab
    }
  
    func prepareGalleryView(){
        gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
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


extension ImportViewController:GalleryControllerDelegate {
    func galleryControllerDidCancel(_ controller: GalleryController) {
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
            DispatchQueue.main.async {
                if let tempPath = tempPath {
                    print(tempPath)
                }
            }
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
}
