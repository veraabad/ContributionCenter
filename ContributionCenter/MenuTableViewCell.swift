//
//  MenuTableViewCell.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/9/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    // UILabel for menu items
    @IBOutlet weak var menuItemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
