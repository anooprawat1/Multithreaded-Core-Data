//
//  EarthQuake+CoreDataClass.swift
//  MultiThreadedCoreData
//
//  Created by Anoop Rawat on 13/03/17.
//  Copyright © 2017 Anoop Rawat. All rights reserved.
//

import Foundation
import CoreData


public class EarthQuake: NSManagedObject {
    
    
  public static func createQuakeFromDictionary(managedObjectContext:NSManagedObjectContext,quakeDictionary:[String:AnyObject]) -> EarthQuake? {
        
        guard let properties = quakeDictionary["properties"] as? [String: AnyObject],
            let newCode = properties["code"] as? String,
            let newMagnitude = properties["mag"] as? NSNumber,
            let newPlaceName = properties["place"] as? String,
            let newDetailURL = properties["detail"] as? String,
            let newTime = properties["time"] as? NSNumber,
            let geometry = quakeDictionary["geometry"] as? [String: AnyObject],
            let coordinates = geometry["coordinates"] as? [NSNumber] else {
                
                print("Data not parsed")
                return nil
        }
    
    let earthQuake = EarthQuake(context: managedObjectContext)

        earthQuake.code = newCode
        earthQuake.magnitude = newMagnitude
        earthQuake.placeName = newPlaceName
        earthQuake.detailURL = newDetailURL
        earthQuake.time = NSDate(timeIntervalSince1970: newTime.doubleValue / 1000.0)
        earthQuake.longitude = coordinates[0]
        earthQuake.latitude = coordinates[1]
        earthQuake.depth = coordinates[2]
        
        return earthQuake
    }

}
