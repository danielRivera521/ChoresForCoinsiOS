//
//  OverviewTableViewCell.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 7/15/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Charts

class OverviewTableViewCell: UITableViewCell {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameCellHeader: UILabel!
    @IBOutlet weak var coinsPieChart: PieChartView!
    @IBOutlet weak var choresPieChart: PieChartView!
    
    
    // MARK: UIViewController methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
