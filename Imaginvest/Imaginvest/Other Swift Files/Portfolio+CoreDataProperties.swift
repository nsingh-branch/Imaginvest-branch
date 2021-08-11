//
//  Portfolio+CoreDataProperties.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/22/21.
//
//

import Foundation
import CoreData


extension Portfolio {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Portfolio> {
        return NSFetchRequest<Portfolio>(entityName: "Portfolio")
    }

    @NSManaged public var assets: Data?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?

}

extension Portfolio : Identifiable {

}
