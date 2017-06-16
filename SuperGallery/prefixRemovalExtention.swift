//
//  prefixRemovalExtention.swift
//  SuperGallery
//
//  Created by jakub skrzypczynski on 16/06/2017.
//  Copyright © 2017 test project. All rights reserved.
//

import Foundation
extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
    }
    
   
    

}

