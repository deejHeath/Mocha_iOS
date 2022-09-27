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
    let makePoints=0, makeLines=1, makeSegments=2, makeRays=3, makeCircles=4, makeIntersections=5
    let measureDistance=20
    let POINT = 1, PTonLINE = 2, PTonCIRCLE=3, LINEintLINE=6
    let DISTANCE = 20
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
    func draw(_ context: CGContext, _ isRed: Bool) {
    }
    func draw(_ context: CGContext, _ isRed: Bool, scaleFactor: Double){
    }
    func distance(_ point: CGPoint) -> Double {
        return 1024
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
    override func distance(_ point: CGPoint) -> Double {
        if isReal {
            let x1 = parent[0].coordinates.x, y1=parent[0].coordinates.y
            let sx = slope.x, sy=slope.y
            let x0=point.x, y0=point.y
            if sx*sx+sy*sy < epsilon {
                isReal=false
                return 1024
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
        var parentsAllReal=true
        for object in parent {
            if !object.isReal {
                parentsAllReal=false
            }
        }
        if parentsAllReal {
            isReal=true
            coordinates=point
            value=sqrt(pow(parent[0].coordinates.x-parent[1].coordinates.x,2)+pow(parent[0].coordinates.y-parent[1].coordinates.y,2))
            scaleFactor=unitValue
        } else {
            isReal=false
        }
    }
    override func draw(_ context: CGContext,_ isRed: Bool) {
        context.setFillColor(UIColor.clear.cgColor)
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
                context.setStrokeColor(UIColor.black.cgColor)
        }
        context.setLineWidth(2.0)
        let currentRect = CGRect(x: coordinates.x-4.0,y:coordinates.y-4.0,
                                 width: 8.0,
                                 height: 8.0)
        context.addEllipse(in: currentRect)
        context.drawPath(using: .fillStroke)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 12)!]
        let string = "d(\(character[parent[0].index%26])\(parent[0].index/26),\(character[parent[1].index%26])\(parent[1].index/26)) ≈ \(round(1000000*(value/scaleFactor)+0.3)/1000000)"
        string.draw(with: CGRect(x: coordinates.x+10, y: coordinates.y-8, width:120, height: 12), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        
    }
}

class PointOnLine: Point {                                                  // parents: line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        super.init(point: point, number: number)                            // it needs a location
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

class Circle: Construction {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // parent: point, point
        let point0=ancestor[0].coordinates                                  // the first must be a
        let point1=ancestor[1].coordinates                                  // point
        super.init(point: point0, number: number)
        coordinates=point0
        slope=point1                                    // Here we use slope for coordinates of second point
        for object in ancestor {
            parent.append(object)
        }
        type=CIRCLE
        index=number
    }
    func update() {
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            isReal=true
            coordinates=parent[0].coordinates
            slope=parent[1].coordinates
        }
    }
    override func draw(_ context: CGContext, _ isRed: Bool) {
        context.setFillColor(UIColor.clear.cgColor)
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
                context.setStrokeColor(UIColor.black.cgColor)
        }
        context.setLineWidth(2.0)
        let radius = sqrt(pow(coordinates.x-slope.x,2)+pow(coordinates.y-slope.y,2))
        let rect=CGRect(x: coordinates.x-radius, y: coordinates.y-radius, width: radius*2, height: radius*2)
        context.addEllipse(in: rect)
        context.drawPath(using: .fillStroke)
        if showLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 12)!]
            let string = "\(character[index%26])\(index/26)"
            let xx=slope.x-coordinates.x, yy=slope.y-coordinates.y, dd=sqrt(xx*xx+yy*yy)
            string.draw(with: CGRect(x: yy/dd*(dd+18)+coordinates.x, y: -xx*(dd+18)/dd+coordinates.y, width: 20, height: 12), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
    override func distance(_ point: CGPoint) -> Double {
        if !isReal {
            return 1024
        } else {
            return abs(sqrt(pow(parent[1].coordinates.x-parent[0].coordinates.x,2)+pow(parent[1].coordinates.y-parent[0].coordinates.y,2))-sqrt(pow(point.x-parent[0].coordinates.x,2)+pow(point.y-parent[0].coordinates.y,2)))
        }
    }
}

class PointOnCircle: Point {                                                // parents: line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        super.init(point: point, number: number)                            // it needs a location
        for object in ancestor {                                            // to update
            parent.append(object)
        }
        self.update(point: point)
        type=PTonCIRCLE
        index=number
    }
    override func update(point: CGPoint) {
        if !parent[0].isReal || parent[0].parent[0].distance(point)<epsilon {
            isReal=false
        } else {
            isReal=true
            let xx=point.x-parent[0].coordinates.x, yy=point.y-parent[0].coordinates.y
            let ss=sqrt(xx*xx+yy*yy)
            let rr=sqrt(pow(parent[0].parent[0].coordinates.x-parent[0].parent[1].coordinates.x,2)+pow(parent[0].parent[0].coordinates.y-parent[0].parent[1].coordinates.y,2))
            coordinates=CGPoint(x: xx*rr/ss+parent[0].coordinates.x, y: yy*rr/ss+parent[0].coordinates.y)
        }
    }
}

class LineIntLine: Point {                                                      // parents: line, line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // this is the intersection
        super.init(point: point,number:number)                              // point of two lines
        for object in ancestor {
            parent.append(object)
        }
        update()
        type=LINEintLINE
        index=number
    }
    
    func update() {
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            isReal=true
            if let p0=parent[0] as? Line {
                if let p1=parent[1] as? Line {
                    let x0=p0.parent[0].coordinates.x
                    let y0=p0.parent[0].coordinates.y
                    let x1=p1.parent[0].coordinates.x
                    let y1=p1.parent[0].coordinates.y
                    let sx0=p0.slope.x,sy0=p0.slope.y
                    let sx1=p1.slope.x,sy1=p1.slope.y
                    if abs(sx0*sy1-sx1*sy0)<epsilon {
                        isReal=false
                    } else {
                        coordinates=CGPoint(x: (sx0*sx1*y0-sx0*sx1*y1+sx0*sy1*x1-sx1*sy0*x0)/(sx0*sy1-sx1*sy0), y: (sx0*sy1*y0-sx1*sy0*y1-sy0*sy1*x0+sy0*sy1*x1)/(sx0*sy1-sx1*sy0))
                    }
                }
            }
        }
        
    }
    override func distance(_ point: CGPoint)->Double {
        if isReal {
            return sqrt(pow(coordinates.x-point.x,2)+pow(coordinates.y-point.y,2))
        } else {
            return 1024
        }
    }
}

//class CircIntCirc: Point {                                            // parent: circle, circle
//    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
//            let point0=ancestor[0].coordinates                                  //
//            let point1=ancestor[1].coordinates                                  //
//            super.init(point: point0, number: number)
//            for object in ancestor {
//                parent.append(object)
//            }
//            let x0=parent[0].coordinates.x, y0=parent[0].coordinates.y
//            let sx0=parent[0].slope.x, sy0=parent[0].slope.y
//            let x1=parent[1].coordinates.x, y1=parent[1].coordinates.y
//            let sx1=parent[1].slope.x, sy1=parent[1].slope.y
//            let r0=pow(x0-sx0,2)+pow(y0-sy0,2), r1=pow(x1-sx1,2)+pow(y1-sy1,2)
//            if parent[0].type==0 {
//                if parent[1].type==0 {
//                    let discriminant = 4*y0*y1*y1*y1-y1*y1*y1*y1+(-2*x0*x0+4*x0*x1-2*x1*x1-6*y0*y0+2*r0+2*r1)*y1*y1-4*y0*(-x0*x0+2*x0*x1-x1*x1-y0*y0+r0+r1)*y1-y0*y0*y0*y0+(-2*x0*x0+4*x0*x1-2*x1*x1+2*r0+2*r1)*y0*y0-r0*r0+(2*x0*x0-4*x0*x1+2*x1*x1+2*r1)*r0-(r1-(x0-x1)*(x0-x1))*(r1-(x0-x1)*(x0-x1))
//                    if discriminant >= 0 {
//                        let xx = ((y0-y1)*sqrt(discriminant)+x0*x0*x0-x0*x0*x1+(-x1*x1+y0*y0-2*y0*y1+y1*y1-r0+r1)*x0+x1 *  (x1*x1+y0*y0-2*y0*y1+y1*y1+r0-r1))/(2*x0*x0-4*x0*x1+2*x1*x1+2*(y0-y1)*(y0-y1))
//                        let yy = y0+sqrt(-coordinates.x*coordinates.x+2*coordinates.x*x0-x0*x0+r0)
//                        coordinates = CGPoint(x: xx, y: yy)
//                        //coordinates.x =
//                        //coordinates.y = y0+sqrt(-coordinates.x*coordinates.x+2*coordinates.x*x0-x0*x0+r0)
//                    } else {
//                        isReal=false
//                    }
//                } else { // parent[0].type=0, parent[1].type<0
//                        // find int of circle[0] and line[1]
//                }
//            } else if parent[1].type==0 { // parent[0].type<0, parent[1].type<0
//                        
//            } else { // parent[0].type<0, parent[1].type<0
//                        
//            }
//        type=CIRCintCIRC
//        index=number
//    }
//}
