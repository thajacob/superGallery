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

var search: String = ""
var escapedSearchText: String = search.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)!
var endPoint:String = { return "https://api.flickr.com/services/feeds/photos_public.gne?format=json&tags=\(search)&nojsoncallback=1#" }()




class APIService: NSObject,UISearchBarDelegate, DataEnterDelegate {
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        search = searchBar.text!
        print(search)
        
        endPoint = { return "https://api.flickr.com/services/feeds/photos_public.gne?format=json&tags=\(search)&nojsoncallback=1#" }()
        print(endPoint)
        print("boo")
    }
    
    
    func userDidEnterSearchInformation(info: String) {
        
        search = info
        print("this is from API \(search)")
        
    }
        
        
   


    
    
//Mark: - func accepts parameter fetching data from server
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
       // print("API \(endPoint)")
        guard let url = URL(string: endPoint) else {return}
     
        
        //Mark: - URLSession with completion get request to server
        
        URLSession.shared.dataTask(with: url) { (data,response, error) in
            
            //Mark: - guard to handle potential errors
            
            guard error == nil else {return}
            guard let data = data else {return}
            do {
                
                //Mark: - call the completion on the main thread
                
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                  print(json)
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
