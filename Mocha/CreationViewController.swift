//
//  ActionViewController.swift
//  Mocha
//
//  Created by Daniel Heath on 9/22/22.
//

import UIKit

class CreationViewController: UIViewController {
    
    @IBOutlet weak var verticalStack: UIStackView!
    var settingsButton = [UIButton]()
    public var completionHandler: ((Int)->Void)?
    var linkedList: [Construction]=[]
    var constructs = [0,0,0]
    
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
    func update(_ constructList: [Construction]) {
//        linkedList = constructList
//        constructs=[0,0,0]
//        print(settingsButton)
//        for object in linkedList {
//            if object.type>0 && object.type<20 {
//                constructs[0]+=1
//            } else if object.type<0 {
//                constructs[1]+=1
//            } else if object.type==0 {
//                constructs[2]+=1
//            }
//            for i in 0...13 {
//                settingsButton[i].isEnabled=true
//            }
//            settingsButton[5].isEnabled=false       // get rid of this when segments enabled
//            settingsButton[6].isEnabled=false       // get rid of this when rays enabled
//            if constructs[0]<3 {
//                settingsButton[13].isEnabled=false
//            }
//            if constructs[0]<2 {
//                settingsButton[1].isEnabled=false
//                settingsButton[5].isEnabled=false
//                settingsButton[6].isEnabled=false
//                settingsButton[7].isEnabled=false
//                settingsButton[12].isEnabled=false
//            }
//            if constructs[1]<2 {
//                settingsButton[10].isEnabled=false
//                settingsButton[111].isEnabled=false
//            }
//            if constructs[1]<1 {
//                settingsButton[8].isEnabled=false
//                settingsButton[9].isEnabled=false
//            }
//            if constructs[2]<1 {
//                settingsButton[4].isEnabled=false
//            }
//            if constructs[1]+constructs[2]<2 {
//                settingsButton[3].isEnabled=false
//            }
//        }
    }
}
