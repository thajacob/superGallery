//
//  PhotoCell.swift
//  SuperGallery
//
//  Created by jakub skrzypczynski on 14/06/2017.
//  Copyright © 2017 test project. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {

    
    @IBOutlet weak var photoImageview: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
        
    
   internal let tapRecognizer1: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//MARK: Implementation of the set data with cells
    
    func setPhotoCellWith(photo: Photo) {
        DispatchQueue.main.async {
            self.authorLabel.text = photo.author
            self.tagsLabel.text = photo.tags
            if let url = photo.mediaURL {
                self.photoImageview.loadImageUsingCacheWithURLString(url, placeHolder: UIImage(named: "placeholder"))
            }
        }
    }
    
    
    
}
