//
//  MyStreamSegmentHeaderView.swift
//  iMessageExt
//
//  Created by Northout on 21/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

protocol MyStreamSegmentDelegate {
    //func showSegmentView()
}

class MyStreamSegmentHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var segmentControl: HMSegmentedControl!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var kSegmentHeight: NSLayoutConstraint!
    
    var segmentDelegate : MyStreamSegmentDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
