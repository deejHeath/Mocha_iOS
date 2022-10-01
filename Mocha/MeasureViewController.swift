//
//  MeasureViewController.swift
//  Mocha
//
//  Created by Daniel Heath on 9/22/22.
//

import UIKit

class MeasureViewController: UIViewController {

    @IBOutlet weak var verticalStack: UIStackView!
    var settingsButton = [UIButton]()
    public var completionHandler: ((Int)->Void)?
    var linkedList: [Construction]=[]
    var constructs = [0,0,0,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for case let button as UIButton in verticalStack.arrangedSubviews {
            settingsButton.append(button)
        }
        
    }
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        completionHandler?(sender.tag)
        dismiss(animated: true, completion: nil)
    }
}
