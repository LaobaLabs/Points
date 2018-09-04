//
//  POIListPeoplePersonTableViewCell.swift
//  Points
//
//  Created by Will Chilcutt on 9/3/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

let kPOIListPeoplePersonTableViewCellIdentifier = String(describing: POIListPeoplePersonTableViewCell.self)

class POIListPeoplePersonTableViewCell : UITableViewCell
{
    //MARK: - IBOutlet
    
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var pointsTotalLabel: UILabel!
    
    func setUp(withPerson person : Person)
    {
        self.personNameLabel.text   = person.name
        self.pointsTotalLabel.text  = "\(Int(person.allPoints().totalPoints()))"
    }
}
