//
//  ListTableViewCell.swift
//  ContributionCenter
//
//  Created by Abad Vera on 5/18/15.
//  Copyright (c) 2015 Abad Vera. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    // Labels shown on tableviewCell
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    // Buttons shown on tableViewCell
    @IBOutlet weak var fridayBttn: UIButton!
    @IBOutlet weak var saturdayBttn: UIButton!
    @IBOutlet weak var sundayBttn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
