//
//  POINumberFormatterFactory.swift
//  Points
//
//  Created by Will Chilcutt on 9/3/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

class POINumberFormatterFactory: NSObject
{
    static let sharedInstance : POINumberFormatterFactory = POINumberFormatterFactory()
    
    lazy var dollarFormatter : NumberFormatter =
    {
        let formatter = NumberFormatter()
        
        formatter.locale                        = NSLocale.current
        formatter.numberStyle                   = .currency
        formatter.alwaysShowsDecimalSeparator   = true

        return formatter
    }()
}
