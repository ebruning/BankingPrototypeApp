//
//  PopViewCell.swift
//  KofaxBank
//
//  Created by Rupali on 28/06/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class PopViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(image_name: String!, title: String, subTitle: String!) {
        if (image_name) != nil || image_name != "" {
            //thumbnail.image = UIImage.init(named: image_name)
        }
        
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
}
