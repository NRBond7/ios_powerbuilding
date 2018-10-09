//
//  CardTableViewCell.swift
//  PowerBuilding531
//
//  Created by Bond, Noah on 10/8/18.
//  Copyright © 2018 Bond, Noah. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var set1WarmUp: UILabel!
    @IBOutlet weak var set1MainLift: UILabel!
    @IBOutlet weak var set1Core: UILabel!
    @IBOutlet weak var set2WarmUp: UILabel!
    @IBOutlet weak var set2MainLift: UILabel!
    @IBOutlet weak var set2Core: UILabel!
    @IBOutlet weak var set3WarmUp: UILabel!
    @IBOutlet weak var set3MainLift: UILabel!
    @IBOutlet weak var set3Core: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
