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
    let POINT = 1, PTonLINE = 2, PTonCIRCLE = 3, MIDPOINT = 4
    let LINEintLINE = 5, FOLDedPT = 6, INVERTedPT=7
    let CIRCintCIRC0 = 8,CIRCintCIRC1 = 9, LINEintCIRC0 = 10, LINEintCIRC1 = 11
    let BiPOINT = 12, THREEptCIRCLEcntr=13
    let BELOCHpt0 = 14, BELOCHpt1 = 15, BELOCHpt2 = 16, HIDDENthing=17, MOVedPT=18
    let DISTANCE = 20, ANGLE = 21, TriAREA=22, CircAREA=23
    let SUM = 24, DIFFERENCE = 25, PRODUCT = 26, RATIO = 27, SINE=28, COSINE=29
    let CIRCLE = 0
    let LINE = -1, PERP = -2, PARALLEL = -3, BISECTOR0 = -4, BISECTOR1 = -5, BELOCHline0 = -7
    let BELOCHline1 = -8, BELOCHline2 = -9, THREEptLINE = -10, SEGMENT = -11, RAY = -12
    
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
            if linkedList[i].isReal && linkedList[i].isShown && (linkedList[i].type==CircAREA || linkedList[i].type==TriAREA) {
                if clickedIndex.contains(i) {
                        linkedList[i].draw(context,true)
                } else {
                    linkedList[i].draw(context,false)
                }
            }
        }
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
            if linkedList[i].isReal && linkedList[i].isShown && (linkedList[i].type>0  && linkedList[i].type<DISTANCE) {
                if clickedIndex.contains(i) {
                        linkedList[i].draw(context,true)
                } else {
                    linkedList[i].draw(context,false)
                }
            }
        }
        for i in 0..<linkedList.count {
            if linkedList[i].isReal && linkedList[i].isShown && linkedList[i].type>=DISTANCE {
                if let temp = linkedList[i] as? Measure {
                    if clickedIndex.contains(i) {
                        temp.drawString(context,true)
                    } else {
                        temp.drawString(context,false)
                    }
                }
            }
        }
    }
}
