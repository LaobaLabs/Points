//
//  POINavigationController.swift
//  Points
//
//  Created by Will Chilcutt on 9/4/18.
//  Copyright © 2018 Laoba Labs. All rights reserved.
//

import UIKit

class POINavigationController: UINavigationController
{
    override var preferredStatusBarStyle: UIStatusBarStyle { get { return .lightContent } }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let navigationBar = self.navigationBar
        
        navigationBar.tintColor             = .white
        navigationBar.barTintColor          = .bubbleGumPink
        navigationBar.isTranslucent         = false
        navigationBar.titleTextAttributes   = [NSAttributedStringKey.foregroundColor:UIColor.white]
    }
}
