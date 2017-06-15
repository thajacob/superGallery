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

protocol DataEnterDelegate {
    func userDidEnterSearchInformation(info:String)
}

class PhotoVC: UITableViewController, UISearchBarDelegate {

    var delegate:DataEnterDelegate? = nil
    
   
  //MARK: - Setting up search button 
    
    fileprivate func setupSearchBtn(){
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 65))
        
        
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
    
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search = searchBar.text!
        let searchQuery = searchBar.text
        delegate?.userDidEnterSearchInformation(info: searchQuery as String!)
        updateTableContent()
        
        
        
    }
    
    
   
    
    //MARK: - creating fetch using variable. 
    
    lazy var fetchedResultController:
        NSFetchedResultsController<NSFetchRequestResult> = {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Photo.self))
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "author", ascending: true)]
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
                CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                frc.delegate = self
            return frc
    }()
    
    
    func viewDidAppear() {
     tableView.register(PhotoCell.self, forCellReuseIdentifier: "cellID")
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBtn()
        self.title = "Photos Feed"
        view.backgroundColor = .white
        updateTableContent()
    
        
        
    }
    
    
    
    func updateTableContent() {
        do {
            try self.fetchedResultController.performFetch()
            print("COUNT FETCHED FIRST: \(self.fetchedResultController.sections?[0].numberOfObjects)")
        } catch let error  {
            print("ERROR: \(error)")
        }
        let service = APIService()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
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
            photoEntity.title = dictionary["title"] as? String
            
            
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
          
            //MARK: - tapRecognise implementation 
            
            cell.tapRecognizer1.addTarget(self, action: #selector(PhotoVC.img_Click(sender:)))
            cell.photoImageview.gestureRecognizers = []
            cell.photoImageview.gestureRecognizers!.append(cell.tapRecognizer1)
            
            
        }
        return cell
    }
    
   
    
    func img_Click(sender: UILongPressGestureRecognizer) {

        print("OK I Taped")
            
      //      UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
    
        
    
    }
    
   
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.sections?.first?.numberOfObjects {
            print("this is number of objects \(count)")
            return count
        }
        return 0
    }


  
    //MARK: clearingDATA that was saved before update our storage with new data coming from API. 
    
    
    private func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }

    
}

extension PhotoVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
    

    



