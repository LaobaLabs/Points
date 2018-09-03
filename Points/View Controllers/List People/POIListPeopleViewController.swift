//
//  POIListPeopleViewController.swift
//  Points
//
//  Created by Will Chilcutt on 9/2/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit
import CoreData

class POIListPeopleViewController : UIViewController
{
    private var peopleArray : [Person] = []
    
    private var newPersonAddAction       : UIAlertAction?
    private var newPersonNameTextField  : UITextField?

    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "People"
                
        self.setUpTableView()
        self.setUpNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getPeople()
    }
    
    private func getPeople()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let results = try? managedContext.fetch(Person.fetchRequest()) as? [Person], let people = results else { return }
        
        self.peopleArray = people
        
        self.tableView.reloadData()
    }
    
    private func setUpNavigationBar()
    {
        let addPersonButton = UIBarButtonItem(barButtonSystemItem: .add,
                                              target: self,
                                              action: #selector(self.handleUserWantsToAddNewPerson))
        
        self.navigationItem.rightBarButtonItem = addPersonButton
    }
    
    private func setUpTableView()
    {
        self.tableView.rowHeight            = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight   = 100.0
        
        self.tableView.register(UINib(nibName: kPOIListPeoplePersonTableViewCellIdentifier, bundle: nil),
                                forCellReuseIdentifier: kPOIListPeoplePersonTableViewCellIdentifier)
    }
    
    //MARK: - handleUserWantsToAddNewPerson
    
    @objc private func handleUserWantsToAddNewPerson()
    {
        let alertController = UIAlertController(title: "Add a new Person",
                                                message: "Give the new person a name:",
                                                preferredStyle: .alert)
        
        alertController.addTextField
        { (textField) in
            self.newPersonNameTextField = textField
            
            textField.delegate                  = self
            textField.placeholder               = "Name"
            textField.autocapitalizationType    = .words
        }
        
        let addAction = UIAlertAction(title: "Add",
                                     style: .default,
                                     handler:
        { (_) in
            guard let nameTextField = self.newPersonNameTextField, let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            
            self.handleUserWantsToCreateNewPerson(withName: name)
        })
        addAction.isEnabled = false
        
        self.newPersonAddAction = addAction
        alertController.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler:nil)
        
        alertController.addAction(cancelAction)

        
        self.present(alertController,
                     animated: true,
                     completion: nil)
    }
    
    //MARK: - handleUserWantsToCreateNewPerson
    
    private func handleUserWantsToCreateNewPerson(withName name : String)
    {
        if self.peopleArray.filter({ return $0.name?.lowercased() == name.lowercased() }).count != 0
        {
            print("Someone has that name!")
        }
        else
        {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let person = Person(context: managedContext)
            person.name = name
            
            managedContext.insert(person)
            
            do
            {
                try  managedContext.save()
            }
            catch (let error)
            {
                print("Could not save new person: \(error)")
            }
            
            self.getPeople()
        }
    }
    
    private func deletePerson(_ personToDelete : Person)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.deleteObjects(personToDelete.allPoints())
        managedContext.delete(personToDelete)
        
        do
        {
            try  managedContext.save()
        }
        catch (let error)
        {
            print("Could not delete person: \(error)")
        }
        
        self.getPeople()
    }
}

//MARK: - UITableViewDataSource

extension POIListPeopleViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return peopleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: kPOIListPeoplePersonTableViewCellIdentifier,
                                                 for: indexPath)
        
        if let cell = cell as? POIListPeoplePersonTableViewCell
        {
            let person = self.peopleArray[indexPath.row]
            cell.setUp(withPerson: person)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension POIListPeopleViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        
        let person = self.peopleArray[indexPath.row]
        
        let detailsVC = POIPersonDetailsViewController(withPerson: person)
        
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .destructive,
                                          title: "Delete")
        { (action, indexPath) in
            
            let person = self.peopleArray[indexPath.row]
            
            guard let personName = person.name else { return }
            
            let alertController = UIAlertController(title: "Delete?",
                                                    message: "Are you sure you want to delete \(personName)? This cannot be undone.",
                                                    preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete",
                                             style: .destructive,
                                             handler:
            { (_) in
                self.deletePerson(person)
            })

            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
            alertController.addAction(cancelAction)
            
            
            self.present(alertController,
                         animated: true,
                         completion: nil)
        }
        
        return [deleteAction]
    }
}

extension POIListPeopleViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if  textField == self.newPersonNameTextField,
            let textFieldText = textField.text
        {
            let newString = NSString(string:textFieldText).replacingCharacters(in: range,
                                                                               with: string)
            
            self.newPersonAddAction?.isEnabled = newString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
        
        return true
    }
}
