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
    
    var segmentDelegate : MyStreamSegmentDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
