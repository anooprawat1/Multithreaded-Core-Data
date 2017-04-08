//
//  UserApiManager.swift
//  NetworkLayerURLSession
//
//  Created by Anoop Rawat on 26/02/17.
//  Copyright © 2017 Anoop Rawat. All rights reserved.
//

import UIKit
import CoreData



class QuakeManager : NSObject {
    
    static let sharedInstance = QuakeManager()
    
    override private init () {
        
    }
    
    dynamic var earthQuake:[EarthQuake] = [EarthQuake]()
    dynamic var isSavingFinish = false
    private var size = 200
    private var fetchOffsetCount = 0
    
    
     // MARK: - Reading Data From File
    func readDataFromFile()  {
        
        if let path = Bundle.main.path(forResource: "all_month", ofType: "geojson") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = try JSONSerialization.jsonObject(with: data, options:[]) as! [String: Any]
                self.savingDataToDBInPrivateQueueContext(jsonDictionary:jsonObj)
                
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        
    }
    
    
    // MARK: - Saving Data
    private func savingDataToDBInPrivateQueueContext(jsonDictionary:[String:Any]) {
        
        
        if  let quakeDataArray = jsonDictionary["features"] as? [[String: AnyObject]] {
            
            CoreDataStack.sharedInstance.persistentContainer.performBackgroundTask({ (context) in
                autoreleasepool {
                    
                    let batchInsertSize = self.size
                    let loopRequired = quakeDataArray.count / batchInsertSize + 1
                    
                    for batchNumber in 0..<loopRequired {
                        
                        let startIndex = batchNumber * batchInsertSize
                        
                        let endIndex = startIndex + min(batchInsertSize, quakeDataArray.count - startIndex)
                        
                        for quakes in quakeDataArray[startIndex..<endIndex] {
                            
                            let _ = EarthQuake.createQuakeFromDictionary(managedObjectContext:context, quakeDictionary: quakes)
                        }
                        
                        if context.hasChanges {
                            do {
                                try context.save()
                                if batchNumber == 0 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.executedFetchRequest()
                                    }
                                }
                                else if batchNumber == loopRequired - 1 {
                                    self.isSavingFinish = true
                                }
                            }
                            catch {
                                print("Error while saving")
                            }
                            context.reset()
                        }
                        
                    }
                    context.reset()
                }
            })
            
        }
        
    }
    
    // MARK: - Fetching Data
    func executedFetchRequest() {
        let fetchRequest: NSFetchRequest<EarthQuake> = NSFetchRequest(entityName: "EarthQuake")
        fetchRequest.fetchBatchSize = size
        fetchRequest.fetchLimit = size
        fetchRequest.fetchOffset  = fetchOffsetCount * fetchRequest.fetchLimit
        do{
            self.earthQuake.append(contentsOf: try CoreDataStack.sharedInstance.mainQueueContext.fetch(fetchRequest))
            fetchOffsetCount = fetchOffsetCount + 1
        }
        catch {
            print(error)
        }
    }
    
    
}
