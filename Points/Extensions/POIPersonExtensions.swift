//
//  POIPersonExtensions.swift
//  Points
//
//  Created by Will Chilcutt on 9/3/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

extension Person
{
    func allPoints() -> [Point]
    {
        guard let pointsArray = self.points?.array as? [Point] else { return [] }
        
        return pointsArray
    }
}
