//
//  InfoViewController.swift
//  Mocha
//
//  Created by Daniel Heath on 11/20/22.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1 = UILabel()
        label2 = UILabel()
        
        }

    @IBAction func returnButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
