//
//  SummaryTableViewCell.swift
//  forecast
//
//  Created by Terry Lee on 2021/05/12.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {

    static let identifier = "SummaryTableViewCell"
    
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var minMaxLabel: UILabel!
    
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        statusLabel.textColor = .white
        minMaxLabel.textColor = statusLabel.textColor
        currentTemperatureLabel.textColor = statusLabel.textColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
