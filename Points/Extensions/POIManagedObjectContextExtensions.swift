//
//  POIManagedObjectContextExtensions.swift
//  Points
//
//  Created by Will Chilcutt on 9/3/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext
{
    func deleteObjects(_ managedObjects : [NSManagedObject])
    {
        for object in managedObjects
        {
            self.delete(object)
        }
    }
}
