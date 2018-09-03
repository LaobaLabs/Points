//
//  POIPersonDetailsViewController.swift
//  Points
//
//  Created by Will Chilcutt on 9/3/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit
import CoreData

class POIPersonDetailsViewController : UIViewController
{
    private let person : Person
    
    override var hidesBottomBarWhenPushed: Bool { get { return true } set { self.hidesBottomBarWhenPushed = newValue} }
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var dollarsLabel         : UILabel!
    @IBOutlet weak var totalPointsLabel     : UILabel!
    @IBOutlet weak var resetPointsButton    : UIButton!
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
        self.dollarsLabel.text      = self.person.allPoints().dollarValue()
        self.totalPointsLabel.text  = "\(Int(self.person.allPoints().totalPoints()))"
        
        let enableRemovePointsButtons = self.person.allPoints().count != 0
        
        self.resetPointsButton.isEnabled    = enableRemovePointsButtons
        self.removePointsButton.isEnabled   = enableRemovePointsButtons
    }
    
    private func removeAllPoints()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let pointsSet = self.person.points else { return }
        
        let allPoints = self.person.allPoints()
        
        self.person.removeFromPoints(pointsSet)
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.deleteObjects(allPoints)
        
        do
        {
            try  managedContext.save()
        }
        catch (let error)
        {
            print("Could not remove all points: \(error)")
        }
        
        self.loadPoints()
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
    
    @IBAction func handleUserPressedResetPointsButton(_ sender: Any)
    {
        let alertController = UIAlertController(title: "Reset?",
                                                message: "Are you sure you want to reset all points for \(self.person.name!)? \n\n This cannot be undone.",
                                                preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Reset",
                                        style: .destructive)
        { (_) in
            self.removeAllPoints()
        }
        
        alertController.addAction(resetAction)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alertController.addAction(cancelAction)
        
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
}
