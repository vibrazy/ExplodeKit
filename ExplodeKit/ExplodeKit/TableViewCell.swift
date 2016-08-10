//
//  TableViewCell.swift
//  ExplodeKit
//
//  Created by Daniel Tavares on 10/08/2016.
//  Copyright © 2016 Daniel Tavares. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	override func prepareForReuse() {
		super.prepareForReuse()
		contentView.alpha = 1.0
	}
}
