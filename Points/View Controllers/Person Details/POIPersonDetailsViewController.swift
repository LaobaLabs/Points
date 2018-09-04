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
    private let person              : Person
    
    //Points picker related views
    private var shadowView          : UIView?
    private var hiddenTextField     : UITextField?
    private var pointsPickerView    : UIPickerView?
    
    override var hidesBottomBarWhenPushed: Bool
    {
        get
        {
            return true
        }
        
        set
        {
            self.hidesBottomBarWhenPushed = newValue
        }
    }
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var dollarsLabel         : UILabel!
    @IBOutlet weak var totalPointsLabel     : UILabel!

    @IBOutlet weak var addPointsButton      : UIButton!
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
        
        self.setUpButtons()

        self.loadPoints()
    }
    
    private func setUpButtons()
    {
        let buttonsArray : [UIButton] = [self.addPointsButton,removePointsButton]
        
        for button in buttonsArray
        {
            button.layer.borderWidth    = 2.0
            button.layer.borderColor    = button.tintColor.cgColor
            button.layer.cornerRadius   = button.frame.size.width / 2.0
            button.layer.masksToBounds  = true
        }
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                      action: #selector(self.handleUserDidLongPressOnAddPointsButton))
        
        self.addPointsButton.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    //MARK: - Points management
    
    private func loadPoints()
    {
        self.dollarsLabel.text      = self.person.allPoints().dollarValue()
        self.totalPointsLabel.text  = "\(Int(self.person.allPoints().totalPoints()))"
        
        let enableRemovePointsButtons = self.person.allPoints().count != 0
        
        self.resetPointsButton.isEnabled    = enableRemovePointsButtons
        self.removePointsButton.isEnabled   = enableRemovePointsButtons
        self.removePointsButton.layer.borderColor = enableRemovePointsButtons == true ? self.removePointsButton.tintColor.cgColor : UIColor.gray.cgColor
    }
    
    private func addPointsToUser(withPointValue pointValue : Double)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let newPoint = Point(context: managedContext)
        newPoint.value      = pointValue
        newPoint.dateGiven  = Date()
        
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
    
    //MARK: - #selctor methods
    
    @objc private func handleUserTappedOutsideOfPickerView()
    {
        if self.hiddenTextField?.isFirstResponder == true
        {
            self.shadowView?.removeFromSuperview()
            self.hiddenTextField?.resignFirstResponder()
        }
    }
    
    @objc private func handleUserSelectedPointsFromPicker()
    {
        guard let pickerView = self.pointsPickerView else { return }
        
        self.addPointsToUser(withPointValue: Double(pickerView.selectedRow(inComponent: 0)))
        self.handleUserTappedOutsideOfPickerView()
        self.pointsPickerView?.selectRow(0, inComponent: 0, animated: false)
    }
    
    @objc private func handleUserDidLongPressOnAddPointsButton()
    {
        guard self.hiddenTextField?.isFirstResponder == false || self.hiddenTextField == nil else { return }
        
        if self.hiddenTextField == nil
        {
            let pickerView = UIPickerView(frame: .zero)
            pickerView.delegate     = self
            pickerView.dataSource   = self
            
            pointsPickerView = pickerView
            
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.tintColor = self.view.tintColor
            toolBar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "Give Points",
                                             style:.done,
                                             target: self,
                                             action:#selector(self.handleUserSelectedPointsFromPicker))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                              target: nil,
                                              action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel",
                                               style: .plain,
                                               target: self,
                                               action: #selector(self.handleUserTappedOutsideOfPickerView))
            
            toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            
            let textField = UITextField(frame: .zero)
            textField.inputView             = pickerView
            textField.inputAccessoryView    = toolBar
            
            self.view.addSubview(textField)
            
            self.hiddenTextField = textField
        }
        
        let shadowView = UIView(frame: self.view.bounds)
        shadowView.backgroundColor = .black
        shadowView.alpha = 0.40
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(self.handleUserTappedOutsideOfPickerView))
        shadowView.addGestureRecognizer(tapGestureRecognizer)
        
        self.view.addSubview(shadowView)
        
        self.shadowView = shadowView
        
        guard let textField = self.hiddenTextField else { return }
        
        textField.becomeFirstResponder()
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
        self.addPointsToUser(withPointValue: 1.0)
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

extension POIPersonDetailsViewController : UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 100
    }
}

extension POIPersonDetailsViewController : UIPickerViewDelegate
{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if row == 0
        {
            return "How many points to give?"
        }
        else
        {
            return "\(row)"
        }
    }
}
