//
//  APIService.swift
//  SuperGallery
//
//  Created by jakub skrzypczynski on 14/06/2017.
//  Copyright © 2017 test project. All rights reserved.
//

import UIKit
import Foundation

//Mark: - enum cases to accept Any type in the sucess case or error

enum Result <T>{
    case Success(T)
    case Error(String)
}




class APIService: NSObject {
    
    let query = "google"
    lazy var endPoint:String = { return "https://api.flickr.com/services/feeds/photos_public.gne?format=json&tags=\(self.query)&nojsoncallback=1#" }()
    

    
    
 //MARK: - REST REQUEST
    
    func URLForSearchingString(searchString: String) -> String {
    
    let apiKey:String = "e55780f4088d497150679d482ed56919"
    let search:String = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
    
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)$text=\(search)&per_page20$format=json&nojsoncallback=1"
    }
    
    
    
    
//Mark: - func accepts parameter fetching data from server
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        guard let url = URL(string: endPoint) else {return}
        
        //Mark: - URLSession with completion get request to server
        
        URLSession.shared.dataTask(with: url) { (data,response, error) in
            
            //Mark: - guard to handle potential errors
            
            guard error == nil else {return}
            guard let data = data else {return}
            do {
                
                //Mark: - call the completion on the main thread
                
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                  
                    //Mark: - json "items" downcast as an array of dictionaries
                    
                    guard let itemsJsonArray = json["items"] as? [[String: AnyObject]] else { return }
                    
                    DispatchQueue.main.async {
                        completion(.Success(itemsJsonArray))
                    }
                }
            } catch let error {
                print(error)
                
            }
            
            
            } .resume()
        
        
        
    }
}
