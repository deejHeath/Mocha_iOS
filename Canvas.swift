//
//  Canvas.swift
//  Mocha
//
//  Created by Daniel Heath on 9/23/22.
//

import UIKit

class Canvas: UIView {
    var linkedList: [Construction] = []
    var clickedIndex: [Int] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(constructions: [Construction], indices: [Int]) {
        linkedList = constructions
        clickedIndex = indices
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        context.setStrokeColor(UIColor.black.cgColor)
        
        for i in 0..<linkedList.count {
            if linkedList[i].isReal && linkedList[i].isShown {
                if clickedIndex.contains(i) {
                    linkedList[i].draw(context,true)
                } else {
                    linkedList[i].draw(context,false)
                }
            }
        }

            
//        for object in linkedList {
//            object.draw(context,false)
//            if let temp = object as? Point {
//                let currentRect = CGRect(x: temp.coordinates.x-5.0,y:temp.coordinates.y-5.0,
//                                         width: 10.0,
//                                         height: 10.0)
//                context.addEllipse(in: currentRect)
//                context.fillEllipse(in: currentRect)
//                context.drawPath(using: .fillStroke)
//            }
//        }
        //print("draw: \(linkedList)")

//        context.setStrokeColor(UIColor.red.cgColor)
//        context.move(to: CGPoint(x: 0,y: 150))
//        context.addLine(to: CGPoint(x: 400,y: 350))
//        context.strokePath()
//        context.setStrokeColor(UIColor.green.cgColor)
//        let rect1 = CGRect(x: 120, y: 200, width: 50, height: 80)//.insetBy(dx: 5, dy: 5)
//        let rect2 = CGRect(x: 150, y: 240, width: 90, height: 70)//.insetBy(dx: 5, dy: 5)
//        let rect3 = CGRect(x: 22, y: 332, width: 8, height: 8)
//        context.setFillColor(UIColor.blue.cgColor)
//        context.setLineWidth(2)
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
//        context.setFillColor(UIColor.systemGray3.cgColor)
//        context.addEllipse(in: rect3)
//        context.drawPath(using: .fillStroke)
//        string.draw(with: CGRect(x: 37, y: 328, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
}
