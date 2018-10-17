//
//  ConditioningCardCell.swift
//  PowerBuilding531
//
//  Created by Bond, Noah on 10/9/18.
//  Copyright © 2018 Bond, Noah. All rights reserved.
//

import UIKit

class ConditioningCardCell: UITableViewCell {

    
    @IBOutlet weak var lift1: UILabel!
    @IBOutlet weak var lift2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
