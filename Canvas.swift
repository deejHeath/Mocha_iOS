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
        for i in 0..<linkedList.count {
            if linkedList[i].isReal && linkedList[i].isShown && linkedList[i].type<=0 {
                if clickedIndex.contains(i) {
                        linkedList[i].draw(context,true)
                } else {
                    linkedList[i].draw(context,false)
                }
            }
        }
        for i in 0..<linkedList.count {
            if linkedList[i].isReal && linkedList[i].isShown && linkedList[i].type>0 {
                if clickedIndex.contains(i) {
                        linkedList[i].draw(context,true)
                } else {
                    linkedList[i].draw(context,false)
                }
            }
        }
    }
}
