//
//  BoxesTableViewCell.swift
//  ContributionCenter
//
//  Created by Abad Vera on 6/6/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class BoxesTableViewCell: UITableViewCell {
    // Labels for the tableViewCell
    @IBOutlet weak var boxNumberLabel: UILabel!
    @IBOutlet weak var sistersNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
