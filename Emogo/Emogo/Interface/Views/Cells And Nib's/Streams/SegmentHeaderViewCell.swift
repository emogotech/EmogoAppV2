//
//  SegmentHeaderViewCell.swift
//  Emogo
//
//  Created by Northout on 20/06/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import UIKit

protocol StreamSegmentHeaderDelegate {
    func ShowSegmentControl()
}

class SegmentHeaderViewCell: UICollectionViewCell {
 
    var segmentDelegate:StreamSegmentHeaderDelegate?
    
    @IBOutlet weak var segmentControl: HMSegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

}
