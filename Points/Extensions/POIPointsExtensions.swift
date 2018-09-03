//
//  POIPointsExtensions.swift
//  Points
//
//  Created by Will Chilcutt on 9/3/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import Foundation

extension Array where Element == Point
{
    func totalPoints() -> Double
    {
        var total : Double = 0
        
        for point in self
        {
            total += point.value
        }
        
        return total
    }
    
    func latestPoint() -> Point?
    {
        var latestPoint : Point?
        
        for loopPoint in self
        {
            if let loopPointDate = loopPoint.dateGiven
            {
                if  let latestPoint = latestPoint,
                    let latestPointDate = latestPoint.dateGiven
                {
                    switch loopPointDate.compare(latestPointDate)
                    {
                        case .orderedDescending:
                            break
                        default:
                            break
                    }
                }
                else
                {
                    latestPoint = loopPoint
                }
            }
        }
        
        return latestPoint
    }
}
