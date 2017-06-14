//
//  extentions.swift
//  SuperGallery
//
//  Created by jakub skrzypczynski on 14/06/2017.
//  Copyright © 2017 test project. All rights reserved.
//

import UIKit

//MARK: - extention to UIImageView to cache the images


let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageUsingCacheWithURLString(_ URLString: String, placeHolder: UIImage?) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        
        
        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler:
                {(data, response, error) in
                    //print("RESPONSE FROM API: \(response)")
                    if error != nil {
                        //print("ERROR Loading images from URL: \(error)")
                        DispatchQueue.main.async {
                            self.image = placeHolder
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        if let data = data {
                            if let dowloadedImage = UIImage(data: data)
                            {
                                imageCache.setObject(dowloadedImage, forKey: NSString(string:URLString))
                                self.image = dowloadedImage
                            }
                            
                        }
                    }
            }).resume()
        }
    }
}




