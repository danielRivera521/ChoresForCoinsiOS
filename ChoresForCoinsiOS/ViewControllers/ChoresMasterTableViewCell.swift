//
//  ChoresMasterTableViewCell.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 7/17/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit

class ChoresMasterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var choreNameCellLabel: UILabel!
    @IBOutlet weak var usernameCellLabel: UILabel!
    @IBOutlet weak var dueDateCellLabel: UILabel!
    @IBOutlet weak var imageCellImageView: UIImageView!
    @IBOutlet weak var completedImageCellImageView: UIImageView!
    @IBOutlet weak var choreValueCellLabel: UILabel!
    @IBOutlet weak var choreNotifyDot: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
