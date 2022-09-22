//
//  ViewController.swift
//  Mocha
//
//  Created by Daniel Heath on 9/22/22.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    @IBAction func measureButtonPressed() {
        let measureController = storyboard?.instantiateViewController(withIdentifier: "measure_VC") as!  MeasureViewController
        present(measureController,animated: true)
    }
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        let actionController = storyboard?.instantiateViewController(withIdentifier: "action_VC") as! ActionViewController
        present(actionController,animated: true)
    }
    @IBAction func shareButtonPressed(_ sender: Any) {
    }
    @IBAction func clearLastButtonPressed(_ sender: Any) {
    }
    @IBAction func clearAllButtonPressed(_ sender: UIButton) {
    }

}

