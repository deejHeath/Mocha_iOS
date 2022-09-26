//
//  Construction.swift
//  Mocha
//
//  Created by Daniel Heath on 9/22/22.
//

import UIKit

class Construction {
    var character = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var isReal=true
    var isShown=true
    var showLabel=true
    var value = -1.0
    var coordinates: CGPoint
    var slope=CGPoint(x: 1.0,y: 0.0)
    var parent: [Construction] = []
    var type = 0
    var index = -1
    let makePoints=0, makeLines=1, makeSegments=2, makeRays=3, makeCircles=4
    let POINT = 1, PTonLINE0 = 2, IntPT = 3, PTonLINE = 4
    let DISTANCE = 10
    let CIRCLE = 0
    let LINE = -1, SEGMENT = -2, RAY = -3
    let epsilon = 0.0000001
    var canvasWidth = 200.0
    
    init(point: CGPoint, number: Int) {
        coordinates=point
        index=number
    }
    init(ancestor: [Construction], point: CGPoint, number: Int) {
        for object in ancestor {
            parent.append(object)
        }
        coordinates=point
        index=number
    }
    func update(width: CGFloat) {
        canvasWidth = width
    }
    func update(point: CGPoint) {
        coordinates=point
    }
    func update(point: CGPoint, unitValue: Double) {
    }
    func update(ancestor: [Construction]) {
    }
    func update(point: CGPoint,scaleFactor: Double) {
    }
    func draw(_ context: CGContext, _ isRed: Bool){
    }
    func draw(_ context: CGContext, _ isRed: Bool, scaleFactor: Double){
    }
    func distance(_ point: CGPoint)->Double {
        return 1000.0
    }
    func setShown(_ x: Bool) {
        isShown = x
    }
}

class Point: Construction {                             // parents: []
    override init(point: CGPoint, number: Int) {        // generally without parents
        super.init(point: point, number: number)
        type = POINT
        index=number
    }
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor,point: point, number: number)
        for object in ancestor {
            parent.append(object)
        }
        coordinates=point
        type = POINT
        index=number
    }

    override func distance(_ point: CGPoint)->Double {
        return sqrt(pow(coordinates.x-point.x,2)+pow(coordinates.y-point.y,2))
    }

    override func draw(_ context: CGContext,_ isRed: Bool) {
        if isRed {
            context.setFillColor(UIColor.red.cgColor)
        } else {
            context.setFillColor(UIColor.black.cgColor)
        }
        context.setLineWidth(2.0)
        let currentRect = CGRect(x: coordinates.x-5.0,y:coordinates.y-5.0,
                                 width: 10.0,
                                 height: 10.0)
        context.fillEllipse(in: currentRect)
        context.drawPath(using: .fillStroke)
        if showLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 12)!]
            let string = "\(character[index%26])\(index/26)"
            string.draw(with: CGRect(x: coordinates.x+8, y: coordinates.y+8, width: 20, height: 12), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
}

class Line: Construction {                                                  // parents: point, point
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // (usually)
        let point0=ancestor[0].coordinates                                  // the first must be a
        let point1=ancestor[1].coordinates                                  // point
        super.init(point: point0, number: number)
        slope=CGPoint(x: point0.x-point1.x,y: point0.y-point1.y)
        normalizeSlope()
        for object in ancestor {
            parent.append(object)
        }
        type=LINE
        index=number
    }
    override init(point: CGPoint, number: Int) {
        super.init(point: point, number: number)
    }

    func normalizeSlope() {
        let ds=sqrt(pow(slope.x,2)+pow(slope.y,2))
        if ds < epsilon {
            isReal=false
        } else {
            isReal=true
            if slope.x<0 {
                slope = CGPoint(x: -slope.x/ds, y: -slope.y/ds)
            } else {
                slope = CGPoint(x: slope.x/ds, y: slope.y/ds)
            }

        }
    }

    override func distance(_ point: CGPoint)->Double{
        if isReal {
            let x1 = parent[0].coordinates.x, y1=parent[0].coordinates.y
            let sx = slope.x, sy=slope.y
            let x0=point.x, y0=point.y
            if sx*sx+sy*sy < epsilon {
                isReal=false
                return 1000.0
            } else {
                isReal=true
                return sqrt((sx*y0-sx*y1-sy*x0+sy*x1)*(sx*y0-sx*y1-sy*x0+sy*x1)/(sx*sx+sy*sy))
            }
        } else {
            return 1024
        }
    }

    func update(){
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            isReal=true
            coordinates=parent[0].coordinates
            slope=CGPoint(x: coordinates.x-parent[1].coordinates.x,y: coordinates.y-parent[1].coordinates.y)
            normalizeSlope()
        }

    }

    override func draw(_ context: CGContext,_ isRed: Bool) {
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
                context.setStrokeColor(UIColor.black.cgColor)
        }
        context.setLineWidth(2.0)
        context.move(to: CGPoint(x: coordinates.x+65536*slope.x,y: coordinates.y+65536*slope.y))
        context.addLine(to: CGPoint(x: coordinates.x-65536*slope.x,y: coordinates.y-65536*slope.y))
        context.strokePath()
        if showLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 12)!]
            let string = "\(character[index%26])\(index/26)"
            var xx=10.0, yy=10.0
            if abs(slope.x)>epsilon {
                if coordinates.y+slope.y/slope.x*(20-coordinates.x)>20 && coordinates.y+slope.y/slope.x*(20-coordinates.x)<520 {
                    xx=20-slope.y*20
                    yy=coordinates.y+slope.y/slope.x*(10-coordinates.x)+slope.x*20
                } else if coordinates.y+slope.y/slope.x*(canvasWidth-40-coordinates.x)>20 && coordinates.y+slope.y/slope.x*(canvasWidth-40-coordinates.x)<520 {
                    xx=canvasWidth-40-slope.y*20
                    yy=coordinates.y+slope.y/slope.x*(canvasWidth-40-coordinates.x)+slope.x*20
                } else if abs(slope.y)>epsilon {
                    xx=coordinates.x-slope.x/slope.y*(coordinates.y-20)-slope.y*20
                    yy=10+slope.x*20
                }
                string.draw(with: CGRect(x: xx, y: yy+10, width: 20, height: 12), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            }
        }
    }
}

class Distance: Point {
    var scaleFactor = 1.0
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor,point: point, number: number)
        for object in ancestor {
            parent.append(object)
        }
        coordinates=CGPoint(x: (parent[0].coordinates.x+parent[1].coordinates.x)/2, y: (parent[0].coordinates.y+parent[1].coordinates.y)/2)
        type = DISTANCE
        index=number
        value=sqrt(pow(parent[0].coordinates.x-parent[1].coordinates.x,2)+pow(parent[0].coordinates.y-parent[1].coordinates.y,2))
        showLabel=false
        scaleFactor=1.0
    }
    
    override func update(point: CGPoint, unitValue: Double) {
        coordinates=point
        value=sqrt(pow(parent[0].coordinates.x-parent[1].coordinates.x,2)+pow(parent[0].coordinates.y-parent[1].coordinates.y,2))
        scaleFactor=unitValue
    }
    
    override func draw(_ context: CGContext,_ isRed: Bool) {
        context.setFillColor(UIColor.systemGray4.cgColor)
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
                context.setStrokeColor(UIColor.black.cgColor)
        }
        context.setLineWidth(2.0)
        let currentRect = CGRect(x: coordinates.x-5.0,y:coordinates.y-5.0,
                                 width: 10.0,
                                 height: 10.0)
        context.addEllipse(in: currentRect)
        context.drawPath(using: .fillStroke)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 12)!]
        let string = "d(\(character[parent[0].index%26])\(parent[0].index/26),\(character[parent[1].index%26])\(parent[1].index/26))=\(value/scaleFactor)"
        string.draw(with: CGRect(x: coordinates.x+8, y: coordinates.y-5, width:120, height: 12), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        
    }
}

class PointOnLine: Construction {                                           // parents: line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        super.init(point: point,number: number)                             // it needs a location
        for object in ancestor {                                            // to update
            parent.append(object)
        }
        self.update(point: point)
        type=PTonLINE
        index=number
    }
    override func update(point: CGPoint) {
        if !parent[0].isReal {
            isReal=false
        } else {
            isReal=true
            if let parent0=parent[0] as? Line {
                let x1=parent0.parent[0].coordinates.x, y1=parent0.parent[0].coordinates.y
                let x0=point.x,y0=point.y,sx=parent0.slope.x,sy=parent0.slope.y
                coordinates=CGPoint(x: (sx*sx*x0+sx*sy*y0-sx*sy*y1+sy*sy*x1)/(sx*sx+sy*sy), y: (sx*sx*y1+sx*sy*x0-sx*sy*x1+sy*sy*y0)/(sx*sx+sy*sy))
            }
        }
    }
}

