//
//  Location+CoreDataProperties.swift
//  MonashSport
//
//  Created by 杨申 on 20/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//  
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var run: Run?

}
