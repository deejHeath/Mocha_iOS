//
//  ViewController.swift
//  Mocha
//
//  Created by Daniel Heath on 9/22/22.
//

import UIKit

class MainViewController: UIViewController {
    
    let canvas = Canvas()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.backgroundColor = .white
        view.addSubview(canvas)
        NSLayoutConstraint.activate([canvas.centerXAnchor.constraint(equalTo: view.centerXAnchor),canvas.centerYAnchor.constraint(equalTo: view.centerYAnchor),canvas.widthAnchor.constraint(equalTo: view.widthAnchor),canvas.heightAnchor.constraint(equalToConstant: 540)])
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: view)
        print("tB: \(location)")
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: view)
        print("tM: \(location)")
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: view)
        print("tE: \(location)")
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: view)
        print("tC: \(location)")
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
        print("share pressed")
    }
    @IBAction func clearLastButtonPressed(_ sender: Any) {
        print("clear last pressed")
    }
    @IBAction func clearAllButtonPressed(_ sender: UIButton) {
        print("clear all pressed")
    }

}

class Canvas: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else {return}
//        context.setStrokeColor(UIColor.red.cgColor)
//        context.setLineWidth(2)
//        context.move(to: CGPoint(x: 0,y: 150))
//        context.addLine(to: CGPoint(x: 400,y: 350))
//        context.strokePath()
//        context.setStrokeColor(UIColor.green.cgColor)
//        let rect1 = CGRect(x: 120, y: 200, width: 50, height: 80).insetBy(dx: 5, dy: 5)
//        let rect2 = CGRect(x: 150, y: 240, width: 90, height: 70).insetBy(dx: 5, dy: 5)
//        let rect3 = CGRect(x: 22, y: 332, width: 10, height: 10)
//        context.setFillColor(UIColor.blue.cgColor)
//        context.setLineWidth(10)
//        context.addRect(rect1)
//        context.drawPath(using: .fillStroke)
//        context.fill(rect1)
//        context.setStrokeColor(UIColor.yellow.cgColor)
//        context.setFillColor(UIColor.cyan.cgColor)
//        context.addEllipse(in: rect2)
//        context.drawPath(using: .fillStroke)
//        "this".draw(at: CGPoint(x: 185, y: 267))
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .center
//        let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 12)!]
//        let string = "d(C0,F0) = 4.700359"
//        context.setStrokeColor(UIColor.black.cgColor)
//        context.setFillColor(UIColor.darkGray.cgColor)
//        context.fillEllipse(in: rect3)
//        string.draw(with: CGRect(x: 37, y: 328, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
}
