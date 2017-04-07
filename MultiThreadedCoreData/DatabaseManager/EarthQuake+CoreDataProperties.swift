//
//  EarthQuake+CoreDataProperties.swift
//  MultiThreadedCoreData
//
//  Created by Anoop Rawat on 13/03/17.
//  Copyright © 2017 Anoop Rawat. All rights reserved.
//

import Foundation
import CoreData


extension EarthQuake {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EarthQuake> {
        return NSFetchRequest<EarthQuake>(entityName: "EarthQuake");
    }

    @NSManaged public var code: String?
    @NSManaged public var depth: NSNumber?
    @NSManaged public var detailURL: String?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var magnitude: NSNumber?
    @NSManaged public var placeName: String?
    @NSManaged public var time: NSDate?

}
