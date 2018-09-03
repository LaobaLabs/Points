//
//  POIPersonDetailsViewController.swift
//  Points
//
//  Created by Will Chilcutt on 9/3/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

class POIPersonDetailsViewController : UIViewController
{
    private let person : Person
    
    override var hidesBottomBarWhenPushed: Bool { get { return true } set { self.hidesBottomBarWhenPushed = newValue} }
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var totalPointsLabel     : UILabel!
    @IBOutlet weak var removePointsButton   : UIButton!
    
    init(withPerson person : Person)
    {
        self.person = person
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = self.person.name

        self.loadPoints()
    }
    
    private func loadPoints()
    {
        self.totalPointsLabel.text = "\(Int(self.person.allPoints().totalPoints()))"
        
        self.removePointsButton.isEnabled = self.person.allPoints().count != 0
    }
    
    //MARK: - IBAction
    
    @IBAction func handleUserPressedRemovePointsButton(_ sender: Any)
    {
        guard let lastAddedPoint = self.person.allPoints().latestPoint() else { return }
        
        self.person.removeFromPoints(lastAddedPoint)
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(lastAddedPoint)
        
        do
        {
            try  managedContext.save()
        }
        catch (let error)
        {
            print("Could not delete point: \(error)")
        }
        
        self.loadPoints()
    }
    
    @IBAction func handleUserPressAddPointsButton(_ sender: Any)
    {
        print("Add")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let newPoint = Point(context: managedContext)
        newPoint.value = 1.0
        newPoint.dateGiven = Date()
        
        managedContext.insert(newPoint)
        
        self.person.addToPoints(newPoint)
        
        do
        {
            try  managedContext.save()
        }
        catch (let error)
        {
            print("Could not save new point: \(error)")
        }
        
        self.loadPoints()
    }
}
