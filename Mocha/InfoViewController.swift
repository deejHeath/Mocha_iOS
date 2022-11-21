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
        label1.text = "Mocha, ⓒ 2022-23 by Daniel Heath of Pactific Lutheran University. Special thanks to Renzhi Cao and Joshua Jacobs for significant contributions."
        label1.font = UIFont.preferredFont(forTextStyle: .body)
        label1.adjustsFontForContentSizeCategory = true
        label1.textColor = .black
        label1.backgroundColor = .white
        label1.numberOfLines = 0
        
        label2 = UILabel()
        label2.text = "Mocha is a dynamic straightedge, compass, and origami contruction application designed for mathematics educators and students."
        label2.font = UIFont.preferredFont(forTextStyle: .body)
        label2.adjustsFontForContentSizeCategory = true
        label2.textColor = .black
        label2.backgroundColor = .white
        label2.numberOfLines = 0
        
        }
//        textview1.text="Mocha, ⓒ 2022-23 by Daniel Heath of Pactific Lutheran University. Special thanks to Renzhi Cao and Joshua Jacobs for significant contributions."
//        textview2.text="Mocha is a dynamic straightedge, compass, and origami contruction application designed for mathematics educators and students."

    @IBAction func returnButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
