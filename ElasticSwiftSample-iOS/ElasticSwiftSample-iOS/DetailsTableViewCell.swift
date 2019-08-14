//
//  DetailsTableViewCell.swift
//  ElasticSwiftSample-iOS
//
//  Created by Prafull Kumar Soni on 3/11/18.
//  Copyright © 2018 pksprojects. All rights reserved.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var propertyNameLabel: UILabel!
    @IBOutlet weak var propertyValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
