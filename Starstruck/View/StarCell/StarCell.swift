//
//  StarCell.swift
//  Starstruck
//
//  Created by Arhan Busam on 8/4/2023.
//

import UIKit

class StarCell: UITableViewCell {
    
    @IBOutlet weak var starNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
        avatarImageView.clipsToBounds = true
    }
    
    func configure(name: String?, avatar: UIImage?) {
        starNameLabel.text = name
        avatarImageView.image = avatar
    }
    
}
