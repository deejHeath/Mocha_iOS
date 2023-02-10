//
//  DisplayViewController.swift
//  Mocha
//
//  Created by Daniel Heath on 2/9/23.
//

import UIKit

class DisplayViewController: UIViewController {

    @IBOutlet weak var verticalStack: UIStackView!
    var settingsButton = [UIButton]()
    public var completionHandler: ((Int)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for case let button as UIButton in verticalStack.arrangedSubviews {
            settingsButton.append(button)
        }
        
    }
    
    @IBAction func seetingsButtonPressed(_ sender: UIButton) {
        completionHandler?(sender.tag)
        dismiss(animated: true, completion: nil)
    }
}
