//
//  ViewController.swift
//  SuperGallery
//
//  Created by jakub skrzypczynski on 14/06/2017.
//  Copyright © 2017 test project. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class PhotoVC: UITableViewController {

    
    //MARK: - creating fetch using variable. 
    
    lazy var fetchedResultController:
        NSFetchedResultsController<NSFetchRequestResult> = {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Photo.self))
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "author", ascending: true)]
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
                CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            // frc.delegate = self
            return frc
    }()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try self.fetchedResultController.performFetch()
            print("COUNT FETCHED FIRST: \(self.fetchedResultController.sections?[0].numberOfObjects)")
        } catch let error {
            print("ERROR: \(error)")
        }
        
    
        
        
        let service = APIService()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.saveInCoreDataWith(array: data)
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
        
    }

 //MARK: - helper method that accepts dictionary and returns a NSManagedObject
    
    
    private func createPhotoEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let photoEntity = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as? Photo {
            photoEntity.author = dictionary["author"] as? String
            photoEntity.tags = dictionary["tags"] as? String
            
            let mediaDictionary = dictionary["media"] as? [String: AnyObject]
            photoEntity.mediaURL = mediaDictionary?["m"] as? String
            return photoEntity
            
        }
        return nil
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
//        let action = UIAlertAction(title: title, style: .default)
//        {
//            (action) in self.dismiss(animated: true, completion: nil)
//            alertController.addAction(action)
        
            self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
 // MARK: saving data in Core date using Map
    
    
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createPhotoEntityFrom(dictionary: $0)}
        do {
            try
                CoreDataStack.sharedInstance.persistentContainer.viewContext.save() }
        catch let error {
            print(error)
        }
    }
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! PhotoCell
        if let photo = fetchedResultController.object(at: indexPath) as? Photo {
            cell.setPhotoCellWith(photo: photo)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0 
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width + 100 //100 = sum of labels height + height of divider line
    }

    

}

