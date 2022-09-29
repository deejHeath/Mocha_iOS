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
    var showLabel=false
    var value = -1.0
    var coordinates: CGPoint
    var slope=CGPoint(x: 1.0,y: 0.0)
    var parent: [Construction] = []
    var type = 0
    var index = -1
    let POINT = 1, PTonLINE = 2, PTonCIRCLE = 3, MIDPOINT = 4, LINEintLINE = 5
    let CIRCintCIRC0 = 6,CIRCintCIRC1 = 7, LINEintCIRC0 = 8, LINEintCIRC1 = 9, FOLDedPT = 10
    let FOLD6PT0 = 11, FOLD6PT1 = 12, FOLD6PT2 = 13
    let DISTANCE = 20, ANGLE = 21, RATIO = 22
    let CIRCLE = 0
    let LINE = -1, PERP = -2, PARALLEL = -3, BISECTOR0 = -4, BISECTOR1 = -5, FOLD6LINE0 = -7
    let FOLD6LINE1 = -8, FOLD6LINE2 = -9, SEGMENT = -10, RAY = -11
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
    func distance(_ point1: CGPoint,_ point2: CGPoint) -> Double {
        return sqrt(pow(point1.x-point2.x,2)+pow(point1.y-point2.y,2))
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
        } else if type<=PTonCIRCLE {
            context.setFillColor(UIColor.black.cgColor)
        } else {
            context.setFillColor(UIColor.clear.cgColor)
        }
        context.setLineWidth(2.0)
        let currentRect = CGRect(x: coordinates.x-5.0,y:coordinates.y-5.0,
                                 width: 10.0,
                                 height: 10.0)
        if type<=PTonCIRCLE {
            context.fillEllipse(in: currentRect)
            context.drawPath(using: .fillStroke)
        } else {
            context.addEllipse(in: currentRect)
            context.drawPath(using: .fillStroke)
        }
        if showLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 12)!]
            let string = "\(character[index%26])\(index/26)"
            string.draw(with: CGRect(x: coordinates.x+8, y: coordinates.y+8, width: 20, height: 12), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
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

class MidPoint: Point {                                                     // parents: point, point
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // this is usually
        super.init(point: point,number:number)                              // invisible
        for object in ancestor {
            parent.append(object)
        }
        update()
        type=MIDPOINT
        index=number
    }
    func update() {
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            isReal=true
            let x0=parent[0].coordinates.x, y0=parent[0].coordinates.y
            let x1=parent[1].coordinates.x, y1=parent[1].coordinates.y
            coordinates=CGPoint(x: (x0+x1)/2, y: (y0+y1)/2)
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

class CircIntCirc0: Point {                                 // parent: circle, circle
    var alternateCoordinates = CGPoint.zero                 // the slope will be used as the lastPoint
    var alternateSlope = CGPoint.zero                       // and alternates...will be used by CircIntCirc1
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        let point0=ancestor[0].coordinates                                  //
        super.init(point: point0, number: number)
        for object in ancestor {
            parent.append(object)
        }
        update()
        slope=coordinates
        alternateSlope=alternateCoordinates
        type=CIRCintCIRC0
        index=number
    }
    func update() {
        if parent[0].isReal && parent[1].isReal {
            let x0=parent[0].coordinates.x, y0=parent[0].coordinates.y  // coordinates of center of circle0
            let sx0=parent[0].slope.x, sy0=parent[0].slope.y            // coordinates of point on circle0
            let x1=parent[1].coordinates.x, y1=parent[1].coordinates.y  // coordinates of center of circle1
            let sx1=parent[1].slope.x, sy1=parent[1].slope.y            // coordinates of point on circle1
            let r0=pow(x0-sx0,2)+pow(y0-sy0,2), r1=pow(x1-sx1,2)+pow(y1-sy1,2)
            let discriminant = -(x1*x1*x1*x1-4*x0*x1*x1*x1+(6*x0*x0+2*y0*y0-4*y0*y1+2*y1*y1-2*r0-2*r1)*x1*x1+4*x0*(-x0*x0-y0*y0+2*y0*y1-y1*y1+r0+r1)*x1+x0*x0*x0*x0+(2*y0*y0-4*y0*y1+2*y1*y1-2*r0-2*r1)*x0*x0+r0*r0+(-2*y0*y0+4*y0*y1-2*y1*y1-2*r1)*r0+(r1-(y0-y1)*(y0-y1))*(r1-(y0-y1)*(y0-y1)))*(y0-y1)*(y0-y1)
            if discriminant >= 0 {
                isReal=true
                let xx = (sqrt(discriminant)+x0*x0*x0-x0*x0*x1+(-x1*x1+y0*y0-2*y0*y1+y1*y1-r0+r1)*x0+x1*x1*x1+(y0*y0-2*y0*y1+y1*y1+r0-r1)*x1)/(2*x0*x0-4*x0*x1+2*x1*x1+2*(y0-y1)*(y0-y1))
                var yy = y0+sqrt(-xx*xx+2*xx*x0-x0*x0+r0)
                if parent[1].distance(CGPoint(x: xx, y: yy))>epsilon || parent[0].distance(CGPoint(x: xx, y: yy))>epsilon {
                    yy = y0-sqrt(-xx*xx+2*xx*x0-x0*x0+r0)
                }
                coordinates = CGPoint(x: xx, y: yy)
                let xxx = (-sqrt(discriminant)+x0*x0*x0-x0*x0*x1+(-x1*x1+y0*y0-2*y0*y1+y1*y1-r0+r1)*x0+x1*x1*x1+(y0*y0-2*y0*y1+y1*y1+r0-r1)*x1)/(2*x0*x0-4*x0*x1+2*x1*x1+2*(y0-y1)*(y0-y1))
                var yyy = y0-sqrt(-xxx*xxx+2*xxx*x0-x0*x0+r0)
                if parent[1].distance(CGPoint(x: xxx, y: yyy))>epsilon || parent[0].distance(CGPoint(x: xxx, y: yyy))>epsilon {
                    yyy = y0+sqrt(-xxx*xxx+2*xxx*x0-x0*x0+r0)
                }
                alternateCoordinates = CGPoint(x: xxx, y: yyy)
            } else {
                isReal=false
            }
        } else {
            isReal=false
        }
        if distance(coordinates,slope)+distance(alternateCoordinates,alternateSlope)>distance(coordinates,alternateSlope)+distance(alternateCoordinates,slope) {
            let temp = alternateCoordinates
            alternateCoordinates=coordinates
            coordinates=temp
        }
        slope=coordinates
        alternateSlope=alternateCoordinates
    }
}

class CircIntCirc1: Point {                                       // parent: circ, circ, cic0
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        let point0=ancestor[0].coordinates                                  //
        super.init(point: point0, number: number)
        for object in ancestor {
            parent.append(object)
        }
        update()
        type=CIRCintCIRC1
        index=number
    }
    func update() {
        if parent[0].isReal && parent[1].isReal && parent[2].isReal {
            if let temp = parent[2] as? CircIntCirc0 {
                isReal=temp.isReal
                coordinates=temp.alternateCoordinates
            } else {
                isReal=false
            }
        } else {
            isReal=false
        }
    }
}

class LineIntCirc0: Point {                                 // parent: circle, circle
    var alternateCoordinates = CGPoint.zero                 // the slope will be used as the lastPoint
    var alternateSlope = CGPoint.zero                       // and alternates...will be used by LineIntCirc1
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        let point0=ancestor[0].coordinates                                  //
        super.init(point: point0, number: number)
        for object in ancestor {
            parent.append(object)
        }
        update()
        slope=coordinates
        alternateSlope=alternateCoordinates
        type=LINEintCIRC0
        index=number
    }
    func update() {
        if parent[0].isReal && parent[1].isReal {
            let x0=parent[0].coordinates.x, y0=parent[0].coordinates.y  // coordinates of point on line
            let sx0=parent[0].slope.x, sy0=parent[0].slope.y            // slope of line
            let x1=parent[1].coordinates.x, y1=parent[1].coordinates.y  // coordinates of center of circle
            let sx1=parent[1].slope.x, sy1=parent[1].slope.y            // coordinates of point on circle
            let r1=pow(x1-sx1,2)+pow(y1-sy1,2)
            let discriminant = (-y0*y0+2*y0*y1-y1*y1+r1)*sx0*sx0+2*sy0*(y0-y1)*(x0-x1)*sx0+sy0*sy0*(-x0*x0+2*x0*x1-x1*x1+r1)
            if discriminant >= 0 {
                isReal=true
                let xx = (sx0*sx0*x1+(-y0+y1)*sy0*sx0+sy0*sy0*x0+sx0*sqrt(discriminant))/(sx0*sx0+sy0*sy0)
                var yy = y1-sqrt(-xx*xx+2*xx*x1-x1*x1+r1)
                if parent[1].distance(CGPoint(x: xx, y: yy))>epsilon || parent[0].distance(CGPoint(x: xx, y: yy))>epsilon {
                    yy = y1+sqrt(-xx*xx+2*xx*x1-x1*x1+r1)
                }
                coordinates = CGPoint(x: xx, y: yy)
                let xxx = (sx0*sx0*x1+(-y0+y1)*sy0*sx0+sy0*sy0*x0-sx0*sqrt(discriminant))/(sx0*sx0+sy0*sy0)
                var yyy = y1+sqrt(-xxx*xxx+2*xxx*x1-x1*x1+r1)
                if parent[1].distance(CGPoint(x: xxx, y: yyy))>epsilon || parent[0].distance(CGPoint(x: xxx, y: yyy))>epsilon {
                    yyy = y1-sqrt(-xxx*xxx+2*xxx*x1-x1*x1+r1)
                }
                alternateCoordinates = CGPoint(x: xxx, y: yyy)
            } else {
                isReal=false
            }
        } else {
            isReal=false
        }
        if distance(coordinates,slope)+distance(alternateCoordinates,alternateSlope)>distance(coordinates,alternateSlope)+distance(alternateCoordinates,slope) {
            let temp = alternateCoordinates
            alternateCoordinates=coordinates
            coordinates=temp
        }
        slope=coordinates
        alternateSlope=alternateCoordinates
    }
}

class LineIntCirc1: Point {                                       // parent: line, circ, lic0
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        let point0=ancestor[0].coordinates                                  //
        super.init(point: point0, number: number)
        for object in ancestor {
            parent.append(object)
        }
        update()
        type=LINEintCIRC1
        index=number
    }
    func update() {
        if parent[0].isReal && parent[1].isReal && parent[2].isReal {
            if let temp = parent[2] as? LineIntCirc0 {
                isReal=temp.isReal
                coordinates=temp.alternateCoordinates
            } else {
                isReal=false
            }
        } else {
            isReal=false
        }
    }
}
class FoldedPoint: Point {                                                  // parents: point, line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // fold point with crease
        super.init(ancestor: ancestor, point: point, number: number)        //
        for object in ancestor {
            parent.append(object)
        }
        let point0=ancestor[0].coordinates                                  // the line
        let point1=ancestor[1].parent[0].coordinates                        //
        let mx=ancestor[1].slope.x, my=ancestor[1].slope.y
        let C=(mx*mx-my*my)/(mx*mx+my*my), S=2*mx*my/(mx*mx+my*my)
        let x0=point0.x, y0=point0.y, x1=point1.x, y1=point1.y
        coordinates=CGPoint(x: x0*C+y0*S+x1-x1*C-y1*S,y: x0*S-y0*C+y1+y1*C-x1*S)
        update()
        type=FOLDedPT
        index=number
    }
    func update() {
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            isReal=true
            let point0=parent[0].coordinates
            let point1=parent[1].parent[0].coordinates
            let mx=parent[1].slope.x, my=parent[1].slope.y
            let C=(mx*mx-my*my)/(mx*mx+my*my), S=2*mx*my/(mx*mx+my*my)
            let x0=point0.x, y0=point0.y, x1=point1.x, y1=point1.y
            coordinates=CGPoint(x: x0*C+y0*S+x1-x1*C-y1*S,y: x0*S-y0*C+y1+y1*C-x1*S)
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
        parent[0].showLabel=true
        parent[1].showLabel=true
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

class PerpLine: Line {                                                      // parents: point, line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // the line on the point
        let point0=ancestor[0].coordinates                                  // and perp to the given
        let line1=ancestor[1].slope                                         // line.
            super.init(ancestor: ancestor, point: point0, number: number)
            slope=CGPoint(x: -line1.y,y: line1.x)
            normalizeSlope()
            for object in ancestor {
                parent.append(object)
            }
        self.update()
        type=PERP
        index=number
    }
    override func update() {
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            isReal=true
            coordinates=parent[0].coordinates
            slope=CGPoint(x: parent[1].slope.y,y: -parent[1].slope.x)
            normalizeSlope()
        }
    }
}

class ParallelLine: Line {                                                  // parents: point, line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // the line on the point
        let point0=ancestor[0].coordinates                                  // and parallel to the
        let line1=ancestor[1].slope                                         // given line.
            super.init(ancestor: ancestor, point: point0, number: number)
            slope=CGPoint(x: -line1.y,y: line1.x)
            normalizeSlope()
            for object in ancestor {
                parent.append(object)
            }
        self.update()
        type=PARALLEL
        index=number
    }
    override func update() {
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            isReal=true
            coordinates=parent[0].coordinates
            slope=parent[1].slope
            normalizeSlope()
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

