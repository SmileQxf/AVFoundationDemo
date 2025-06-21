//
//  HomeListCell.swift
//  AVFoundationDemo
//
//  Created by Coding on 2025/6/21.
//  Copyright © 2025 smile. All rights reserved.
//

import UIKit

let kHomeListCell_ID = "HomeListCell"
class HomeListCell: UITableViewCell {

    @IBOutlet weak private var containerView: UIView!
    /// 标题Label
    @IBOutlet weak var titleLabel: UILabel!
    /// 标题Label
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        self.setupUI()
    }
    
    public func setInfoAvatar(_ model: HomeListCellModel) {
        titleLabel.text = model.rowTitle
        valueLabel.text = model.rowValue
    }

    private func setupUI() {
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        
        valueLabel.font = .systemFont(ofSize: 15)
        valueLabel.textColor = .black
        valueLabel.numberOfLines = 2
        valueLabel.adjustsFontSizeToFitWidth = true
        
        containerView.backgroundColor =  kCell_Container_BgColor
        containerView.layer.cornerRadius = kTwoPageCellCornerRadius
        containerView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
