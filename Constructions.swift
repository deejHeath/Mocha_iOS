//
//  Construction.swift
//  Mocha
//
//  Created by Daniel Heath on 9/22/22.
//

import UIKit

class Construction {
    var character = ["A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var isReal=true
    var isShown=true
    var showLabel=false
    var value = -1.0
    var coordinates: CGPoint
    var slope=CGPoint(x: 1.0,y: 0.0)
    var parent: [Construction] = []
    var type = 0
    var index = -1
    let POINT = 1, PTonLINE = 2, PTonCIRCLE = 3, MIDPOINT = 4
    let LINEintLINE = 5, FOLDedPT = 6, INVERTedPT=7
    let CIRCintCIRC0 = 8,CIRCintCIRC1 = 9, LINEintCIRC0 = 10, LINEintCIRC1 = 11
    let BiPOINT = 12, THREEptCIRCLEcntr=13
    let TOOL6PT0 = 14, TOOL6PT1 = 15, TOOL6PT2 = 16
    let DISTANCE = 20, ANGLE = 21, TriAREA=22, CircAREA=23
    let SUM = 24, DIFFERENCE = 25, PRODUCT = 26, RATIO = 27, SINE=28, COSINE=29
    let CIRCLE = 0
    let LINE = -1, PERP = -2, PARALLEL = -3, BISECTOR0 = -4, BISECTOR1 = -5, TOOL6LINE0 = -7
    let TOOL6LINE1 = -8, TOOL6LINE2 = -9, THREEptLINE = -10, SEGMENT = -11, RAY = -12
    let epsilon = 0.0000001
    var textString=""
    var canvasWidth = 200.0, canvasHeight = 200.0
    let strokeWidth=1.5
    
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
    func update(width: CGFloat, height: CGFloat) {
        canvasWidth = width
        canvasHeight = height
    }
    func update(point: CGPoint) {
        coordinates=point
    }
    func update(point: CGPoint, unitValue: Double) {
    }
    func update(ancestor: [Construction]) {
    }
    func draw(_ context: CGContext, _ isRed: Bool) {
    }
    func distance(_ point: CGPoint) -> Double {
        return 1024
    }
    func distance(_ point1: CGPoint,_ point2: CGPoint) -> Double {
        return sqrt(pow(point1.x-point2.x,2)+pow(point1.y-point2.y,2))
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
        coordinates=point
        type = POINT
        index=number
    }
    override func distance(_ point: CGPoint)->Double {
        return sqrt(pow(coordinates.x-point.x,2)+pow(coordinates.y-point.y,2))
    }
    override func draw(_ context: CGContext,_ isRed: Bool) {
        if isRed {
            context.setFillColor(UIColor.red.withAlphaComponent(1.0).cgColor)
        } else if type<=PTonCIRCLE {
            context.setFillColor(UIColor.yellow.cgColor)
        } else {
            context.setFillColor(UIColor.clear.cgColor)
        }
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setLineWidth(strokeWidth)
        let currentRect = CGRect(x: coordinates.x-6.0,y:coordinates.y-6.0,
                                 width: 12.0,
                                 height: 12.0).insetBy(dx: 1.0, dy: 1.0)
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
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.yellow]
            let string = "\(character[index%24])\(index/24)"
            string.draw(with: CGRect(x: coordinates.x+8, y: coordinates.y+8, width: 50, height: 18), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
    func invalidatePointOffSegment(i: Int, location: CGPoint) {
        if parent[i].parent[0].coordinates.x<parent[i].parent[1].coordinates.x {
            if location.x<parent[i].parent[0].coordinates.x || location.x>parent[i].parent[1].coordinates.x {
                isReal=false
            }
        } else if parent[i].parent[0].coordinates.x>parent[i].parent[1].coordinates.x {
            if location.x>parent[i].parent[0].coordinates.x || location.x<parent[i].parent[1].coordinates.x {
                isReal=false
            }
        } else if parent[i].parent[0].coordinates.y<parent[i].parent[1].coordinates.y {
            if location.y<parent[i].parent[0].coordinates.y || location.y>parent[i].parent[1].coordinates.y {
                isReal=false
            }
        } else if parent[i].parent[0].coordinates.y>parent[i].parent[1].coordinates.y {
            if location.y>parent[i].parent[0].coordinates.y || location.y<parent[i].parent[1].coordinates.y {
                isReal=false
            }
        }
    }
    func invalidatePointOffRay(i: Int, location: CGPoint) {
        if parent[i].parent[0].coordinates.x<parent[i].parent[1].coordinates.x {
            if location.x<parent[i].parent[0].coordinates.x {
                isReal=false
            }
        } else if parent[i].parent[0].coordinates.x>parent[i].parent[1].coordinates.x {
            if location.x>parent[i].parent[0].coordinates.x {
                isReal=false
            }
        } else if parent[i].parent[0].coordinates.y<parent[i].parent[1].coordinates.y {
            if location.y<parent[i].parent[0].coordinates.y {
                isReal=false
            }
        } else if parent[i].parent[0].coordinates.y>parent[i].parent[1].coordinates.y {
            if location.y>parent[i].parent[0].coordinates.y {
                isReal=false
            }
        }
    }
}

class PointOnLine: Point {                                                  // parents: line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        super.init(ancestor: ancestor, point: point, number: number)        // it needs a location
        update(point: point)
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
                // next we check to see if the point is on the segment/ray, and if not,
                // we put it at the closest point.
                if parent0.type==SEGMENT {
                    if parent0.parent[0].coordinates.x<parent0.parent[1].coordinates.x {
                        if coordinates.x<parent0.parent[0].coordinates.x {
                            coordinates=parent0.parent[0].coordinates
                        } else if coordinates.x>parent0.parent[1].coordinates.x {
                            coordinates=parent0.parent[1].coordinates
                        }
                    } else if parent0.parent[0].coordinates.x>parent0.parent[1].coordinates.x {
                        if coordinates.x<parent0.parent[1].coordinates.x {
                            coordinates=parent0.parent[1].coordinates
                        } else if coordinates.x>parent0.parent[0].coordinates.x {
                            coordinates=parent0.parent[0].coordinates
                        }
                    } else if parent0.parent[0].coordinates.y<parent0.parent[1].coordinates.y {
                        if coordinates.y<parent0.parent[0].coordinates.y {
                            coordinates=parent0.parent[0].coordinates
                        } else if coordinates.y>parent0.parent[1].coordinates.y {
                            coordinates=parent0.parent[1].coordinates
                        }
                    } else if parent0.parent[0].coordinates.y>parent0.parent[1].coordinates.y {
                        if coordinates.y<parent0.parent[1].coordinates.y {
                            coordinates=parent0.parent[1].coordinates
                        } else if coordinates.y>parent0.parent[0].coordinates.y {
                            coordinates=parent0.parent[0].coordinates
                        }
                    }
                }
                if parent0.type==RAY {
                    if parent0.parent[0].coordinates.x<parent0.parent[1].coordinates.x {
                        if coordinates.x<parent0.parent[0].coordinates.x {
                            coordinates=parent0.parent[0].coordinates
                        }
                    } else if parent0.parent[0].coordinates.x>parent0.parent[1].coordinates.x {
                        if coordinates.x>parent0.parent[0].coordinates.x {
                            coordinates=parent0.parent[0].coordinates
                        }
                    } else if parent0.parent[0].coordinates.y<parent0.parent[1].coordinates.y {
                        if coordinates.y<parent0.parent[0].coordinates.y {
                            coordinates=parent0.parent[0].coordinates
                        }
                    } else if parent0.parent[0].coordinates.y>parent0.parent[1].coordinates.y {
                        if coordinates.y>parent0.parent[0].coordinates.y {
                            coordinates=parent0.parent[0].coordinates
                        }
                    }
                }
            }
        }
    }
}

class PointOnCircle: Point {                                                // parents: line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        super.init(ancestor: ancestor, point: point, number: number)        // it needs a location
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
        super.init(ancestor: ancestor, point: point,number:number)          // invisible
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

class LineIntLine: Point {                                                  // parents: line, line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // this is the intersection
        super.init(ancestor: ancestor, point: point, number: number)        // point of two lines
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
                    // now if either parent is a segment or ray, we need to check whether the point of intersection is on it, and if not, set isReal=false
                    if parent[0].type==SEGMENT {
                        invalidatePointOffSegment(i: 0,location: coordinates)
                    }
                    if parent[1].type==SEGMENT {
                        invalidatePointOffSegment(i: 1,location: coordinates)
                    }
                    if parent[0].type==RAY {
                        invalidatePointOffRay(i: 0,location: coordinates)
                    }
                    if parent[1].type==RAY {
                        invalidatePointOffRay(i: 1,location: coordinates)
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
        super.init(ancestor: ancestor, point: point0, number: number)
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
        super.init(ancestor: ancestor, point: point0, number: number)
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
        super.init(ancestor: ancestor, point: point0, number: number)
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
        // now we need to check if parent[0] is a segment or ray, and if so, whether the point of intersection is on it.  If not, set isReal=false. (And pass second root to LIC1)
        if parent[0].type==SEGMENT {
            invalidatePointOffSegment(i: 0, location: coordinates)
        }
        if parent[0].type==RAY {
            invalidatePointOffRay(i: 0, location: coordinates)
        }
    }
}

class LineIntCirc1: Point {                                       // parent: line, circ, lic0
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        let point0=ancestor[0].coordinates                                  //
        super.init(ancestor: ancestor, point: point0, number: number)
        update()
        type=LINEintCIRC1
        index=number
    }
    func update() {
        if parent[0].isReal && parent[1].isReal {
            if let temp = parent[2] as? LineIntCirc0 {
                let x0=parent[0].coordinates.x, y0=parent[0].coordinates.y  // coordinates of point on line
                let sx0=parent[0].slope.x, sy0=parent[0].slope.y            // slope of line
                let x1=parent[1].coordinates.x, y1=parent[1].coordinates.y  // coordinates of center of circle
                let sx1=parent[1].slope.x, sy1=parent[1].slope.y            // coordinates of point on circle
                let r1=pow(x1-sx1,2)+pow(y1-sy1,2)
                let discriminant = (-y0*y0+2*y0*y1-y1*y1+r1)*sx0*sx0+2*sy0*(y0-y1)*(x0-x1)*sx0+sy0*sy0*(-x0*x0+2*x0*x1-x1*x1+r1)
                isReal=(discriminant >= 0)
                coordinates=temp.alternateCoordinates
                if parent[0].type==SEGMENT {
                    invalidatePointOffSegment(i: 0, location: coordinates)
                }
                if parent[0].type==RAY {
                    invalidatePointOffRay(i: 0, location: coordinates)
                }
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
        super.init(ancestor: ancestor, point: point, number: number)        // the line
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

class InvertedPoint: Point {                                // parent: point, circle
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // invert point in circle
        super.init(ancestor: ancestor, point: point, number: number)        //
        update()
        type=INVERTedPT
        index=number
    }
    func update() {
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            let point0=parent[0].coordinates                  // point to invert
            let point1=parent[1].parent[0].coordinates        // center of circle
            let radius=parent[1].parent[0].distance(parent[1].slope)    // radius of circle
            let distance=parent[1].parent[0].distance(point0)
            if  distance<epsilon {
                isReal=false
            } else {
                isReal=true
                coordinates = CGPoint(x: pow(radius,2)*(point0.x-point1.x)/pow(distance,2)+point1.x,y: pow(radius,2)*(point0.y-point1.y)/pow(distance,2)+point1.y)
            }
        }
    }
}

class BisectorPoint: Point {                                                // parents: line, line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // two cases: If the lines
        super.init(ancestor: ancestor, point: point, number: number)   // intersect, then this is an
        update()         // IntPT. If not, then this pt needsto be any midpoint between the lines.
        type=BiPOINT     // We find it by using the PT0 on L0, find the PerpLine using it & L1,
        index=number     // intersect PL with L1, then the midpoint of PT0 and temp1.
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
                    if abs(sx0*sy1-sx1*sy0)<epsilon {           // if the two lines are parallel
                        let temp0 = PerpLine(ancestor: [p0.parent[0],p1], point: p1.coordinates, number: 0)
                        let temp1 = LineIntLine(ancestor: [temp0,p1], point: p1.coordinates, number: 1)
                        let temp2 = MidPoint(ancestor: [p0.parent[0],temp1], point: temp1.coordinates, number: 2)
                        coordinates=temp2.coordinates
                        
                    } else {                                    // otherwise they intersect
                        coordinates=CGPoint(x: (sx0*sx1*y0-sx0*sx1*y1+sx0*sy1*x1-sx1*sy0*x0)/(sx0*sy1-sx1*sy0), y: (sx0*sy1*y0-sx1*sy0*y1-sy0*sy1*x0+sy0*sy1*x1)/(sx0*sy1-sx1*sy0))
                    }
                }
            }
        }
    }
}

class ThreePointCircleCntr: Point { // parent: point, point, point, ThreePointLine
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: CGPoint.zero, number: number)
        update()
        type=THREEptCIRCLEcntr
        index=number
    }
    func update() {
        isReal = !parent[3].isReal && parent[0].isReal && parent[1].isReal && parent[2].isReal
        if isReal {
            coordinates=parent[3].coordinates
        }
    }
}

class Measure: Point {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
    }
    override func draw(_ context: CGContext,_ isRed: Bool) {
        context.setFillColor(UIColor.clear.cgColor)
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
            context.setStrokeColor(UIColor.white.cgColor)
        }
        context.setLineWidth(strokeWidth)
        let currentRect = CGRect(x: coordinates.x-4.0,y:coordinates.y-4.0,
                                 width: 8.0,
                                 height: 8.0)
        context.addEllipse(in: currentRect)
        context.drawPath(using: .fillStroke)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        let string = textString+" ≈ \(round(1000000*(value)+0.3)/1000000)"
        string.draw(with: CGRect(x: coordinates.x+10, y: coordinates.y-8, width:350, height: 18), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
}

class Distance: Measure {       // parents: point, point (for unit distance), or
    var measuredValue=1.0       // parents: point, point, (unit) distance.
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        coordinates=parent[0].coordinates
        type = DISTANCE
        index=number
        update(point: coordinates)
        parent[0].showLabel=true
        parent[1].showLabel=true
        showLabel=false
        textString="\(character[index%24])\(index/24) : d(\(character[parent[0].index%24])\(parent[0].index/24),\(character[parent[1].index%24])\(parent[1].index/24))"
    }
    override func update(point: CGPoint) {
        var parentsAllReal=true
        for object in parent {
            if !object.isReal {
                parentsAllReal=false
            }
        }
        if parentsAllReal {
            isReal=true
            coordinates=point
            measuredValue=sqrt(pow(parent[0].coordinates.x-parent[1].coordinates.x,2)+pow(parent[0].coordinates.y-parent[1].coordinates.y,2))
            if parent.count==3 {
                if let temp = parent[2] as? Distance {
                    if temp.measuredValue>epsilon {
                        value=measuredValue/temp.measuredValue
                    } else {
                        isReal=false
                    }
                } else {
                    isReal=false
                }
            } else {
                value=1.0
            }
        } else {
            isReal=false
        }
    }
}
class Angle: Measure {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor,point: point, number: number)
        type = ANGLE
        index=number
        update(point: point);
        parent[0].showLabel=true
        parent[1].showLabel=true
        parent[2].showLabel=true
        showLabel=false
        textString="\(character[index%24])\(index/24) : ∠(\(character[parent[0].index%24])\(parent[0].index/24),\(character[parent[1].index%24])\(parent[1].index/24),\(character[parent[2].index%24])\(parent[2].index/24))"
    }
    override func update(point: CGPoint) {
        var parentsAllReal=true
        for object in parent {
            if !object.isReal {
                parentsAllReal=false
            }
        }
        if parentsAllReal {
            isReal=true
            coordinates=point
            let p0=parent[0].coordinates
            let p1=parent[1].coordinates
            let p2=parent[2].coordinates
            let uDotV=(p0.x-p1.x)*(p2.x-p1.x)+(p0.y-p1.y)*(p2.y-p1.y)
            let normU=sqrt(pow(p0.x-p1.x,2)+pow(p0.y-p1.y,2))
            let normV=sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2))
            value=acos(uDotV/(normU*normV))*180/3.141592653589793
            value=value*signum((p0.y-p1.y)*(p2.x-p1.x)-(p0.x-p1.x)*(p2.y-p1.y))
            // this last line makes left- and right-handed angles
        } else {
            isReal=false
        }
    }
}
class Ratio: Distance {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        coordinates=parent[0].coordinates
        type = RATIO
        index=number
        if abs(parent[1].value)>epsilon {
            value=parent[0].value/parent[1].value
        } else {
            isReal=false
        }
        showLabel=false
        textString="\(character[index%24])\(index/24) : \(character[parent[0].index%24])\(parent[0].index/24) / \(character[parent[1].index%24])\(parent[1].index/24)"
    }
    override func update(point: CGPoint) {
        if parent[0].isReal && parent[1].isReal && abs(parent[1].value)>epsilon {
            isReal=true
            coordinates=point
            value=parent[0].value/parent[1].value
        } else {
            isReal=false
        }
    }
}
class Product: Distance {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        coordinates=parent[0].coordinates
        type = PRODUCT
        index=number
        value=parent[0].value*parent[1].value
        showLabel=false
        textString="\(character[index%24])\(index/24) : \(character[parent[0].index%24])\(parent[0].index/24) ⋅ \(character[parent[1].index%24])\(parent[1].index/24)"
    }
    override func update(point: CGPoint) {
        if parent[0].isReal && parent[1].isReal {
            isReal=true
            coordinates=point
            value=parent[0].value*parent[1].value
        } else {
            isReal=false
        }
    }
}
class Sum: Distance {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        coordinates=parent[0].coordinates
        type = SUM
        index=number
        value=parent[0].value+parent[1].value
        showLabel=false
        textString="\(character[index%24])\(index/24) : \(character[parent[0].index%24])\(parent[0].index/24) + \(character[parent[1].index%24])\(parent[1].index/24)"
    }
    override func update(point: CGPoint) {
        if parent[0].isReal && parent[1].isReal {
            isReal=true
            coordinates=point
            value=parent[0].value+parent[1].value
        } else {
            isReal=false
        }
    }
}
class Difference: Distance {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        coordinates=parent[0].coordinates
        type = DIFFERENCE
        index=number
        value=parent[0].value-parent[1].value
        showLabel=false
        textString="\(character[index%24])\(index/24) : \(character[parent[0].index%24])\(parent[0].index/24) - \(character[parent[1].index%24])\(parent[1].index/24)"
    }
    override func update(point: CGPoint) {
        if parent[0].isReal && parent[1].isReal {
            isReal=true
            coordinates=point
            value=parent[0].value-parent[1].value
        } else {
            isReal=false
        }
    }
}
class Sine: Measure {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        coordinates=point
        type = SINE
        value=sin(parent[0].value)
        index=number
        update(point: point)
        type=SINE
        showLabel=false
        textString="\(character[index%24])\(index/24) : sin(\(character[parent[0].index%24])\(parent[0].index/24))"
    }
    override func update(point: CGPoint) {
        if parent[0].isReal {
            isReal=true
            coordinates=point
            value=sin(3.141592653589793*parent[0].value/180)
        } else {
            isReal=false
        }
    }
}
class Cosine: Measure {
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        coordinates=point
        type = COSINE
        index=number
        update(point: point)
        type=COSINE
        showLabel=false
        textString="\(character[index%24])\(index/24) : cos(\(character[parent[0].index%24])\(parent[0].index/24))"
    }
    override func update(point: CGPoint) {
        if parent[0].isReal {
            isReal=true
            coordinates=point
            value=cos(3.141592653589793*parent[0].value/180)
        } else {
            isReal=false
        }
    }
}
    
    
    
    
class Line: Construction {                                                  // parents: point, point
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // (usually)
        let point0=ancestor[0].coordinates                                  // the first must be a
        super.init(ancestor: ancestor, point: point0, number: number)       // point
        update()
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
            if type==BISECTOR0 || type==BISECTOR1 {
                context.setStrokeColor(UIColor.blue.cgColor)
            } else if type==TOOL6LINE0 || type==TOOL6LINE1 || type==TOOL6LINE2 {
                context.setStrokeColor(UIColor.systemGreen.cgColor)
            } else {
                context.setStrokeColor(UIColor.systemGray2.cgColor)
            }
        }
        context.setLineWidth(strokeWidth)
        context.move(to: CGPoint(x: coordinates.x+65536*slope.x,y: coordinates.y+65536*slope.y))
        context.addLine(to: CGPoint(x: coordinates.x-65536*slope.x,y: coordinates.y-65536*slope.y))
        context.strokePath()
        if showLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            var attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.white]
            if type==BISECTOR0 || type==BISECTOR1 {
                attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
            }
            if type==TOOL6LINE0 || type==TOOL6LINE1 || type==TOOL6LINE2 {
                attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
            }
            let string = "\(character[index%24])\(index/24)"
            var xx=10.0, yy=10.0
            if abs(slope.x)>epsilon {
                if coordinates.y+slope.y/slope.x*(20-coordinates.x)>20 && coordinates.y+slope.y/slope.x*(20-coordinates.x)<canvasHeight-40 {
                    xx=20-slope.y*10
                    yy=coordinates.y+slope.y/slope.x*(20-coordinates.x)+slope.x*0
                } else if coordinates.y+slope.y/slope.x*(canvasWidth-40-coordinates.x)>20 && coordinates.y+slope.y/slope.x*(canvasWidth-40-coordinates.x)<canvasHeight-40 {
                    xx=canvasWidth-40-slope.y*10
                    yy=coordinates.y+slope.y/slope.x*(canvasWidth-40-coordinates.x)+slope.x*0
                } else if abs(slope.y)>epsilon {
                    xx=coordinates.x-slope.x/slope.y*(coordinates.y-20)-slope.y*10
                    yy=10+slope.x*0
                }
                string.draw(with: CGRect(x: xx, y: yy+10, width: 50, height: 18), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            }
        }
    }
}
class Segment: Line {                                                  // parents: point, point
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // (usually)
        let point0=ancestor[0].coordinates                                  // the first must be a
        super.init(ancestor: ancestor, point: point0, number: number)       // point
        update()
        type=SEGMENT
        index=number
    }
    override func distance(_ point: CGPoint) -> Double {
        let temp=PointOnLine(ancestor: [self], point: point, number: 0)
        temp.update(point: point)
        return sqrt(pow(temp.coordinates.x-point.x,2)+pow(temp.coordinates.y-point.y,2))
    }
    override func draw(_ context: CGContext,_ isRed: Bool) {
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
            context.setStrokeColor(UIColor.systemGray2.cgColor)
        }
        context.setLineWidth(strokeWidth)
        context.move(to: CGPoint(x: parent[0].coordinates.x,y: parent[0].coordinates.y))
        context.addLine(to: CGPoint(x: parent[1].coordinates.x,y: parent[1].coordinates.y))
        context.strokePath()
        if showLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.white]
            let string = "\(character[index%24])\(index/24)"
            let xx=(coordinates.x+(parent[1].coordinates.x-coordinates.x)/3)+slope.y*20, yy=(coordinates.y+(parent[1].coordinates.y-coordinates.y)/3)-slope.x*20
            string.draw(with: CGRect(x: xx, y: yy, width: 50, height: 18), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
}
class Ray: Line {                                                  // parents: point, point
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  // (usually)
        let point0=ancestor[0].coordinates                                  // the first must be a
        super.init(ancestor: ancestor, point: point0, number: number)       // point
        update()
        type=RAY
        index=number
    }
    override func distance(_ point: CGPoint) -> Double {
        let temp=PointOnLine(ancestor: [self], point: point, number: 0)
        temp.update(point: point)
        return sqrt(pow(temp.coordinates.x-point.x,2)+pow(temp.coordinates.y-point.y,2))
    }
    override func draw(_ context: CGContext,_ isRed: Bool) {
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
            context.setStrokeColor(UIColor.systemGray2.cgColor)
        }
        context.setLineWidth(strokeWidth)
        context.move(to: CGPoint(x: coordinates.x,y: coordinates.y))
        context.addLine(to: CGPoint(x: coordinates.x+256*(parent[1].coordinates.x-coordinates.x), y: coordinates.y+256*(parent[1].coordinates.y-coordinates.y)))
        context.strokePath()
        if showLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.white]
            let string = "\(character[index%24])\(index/24)"
            let xx=(coordinates.x+1.4*(parent[1].coordinates.x-coordinates.x))+slope.y*20, yy=(coordinates.y+1.4*(parent[1].coordinates.y-coordinates.y))-slope.x*20
            string.draw(with: CGRect(x: xx, y: yy, width: 50, height: 18), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
}
class PerpLine: Line {                   // parents: point, line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        let point0=ancestor[0].coordinates
        super.init(ancestor: ancestor, point: point0, number: number)
        update()
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
    
class ParallelLine: Line {                         // parents: point, line
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        let point0=ancestor[0].coordinates
        super.init(ancestor: ancestor, point: point0, number: number)
        update()
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
    
class Circle: Construction {                        // parent: point, point
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        let point0=ancestor[0].coordinates               // first: center, second: point on
        super.init(ancestor: ancestor, point: point0, number: number)
        update()
        type=CIRCLE
        index=number
    }
    func update() {
        if !parent[0].isReal || !parent[1].isReal {
            isReal=false
        } else {
            isReal=true
            coordinates=parent[0].coordinates
            slope=parent[1].coordinates         // We use slope for coordinates
        }                                       // of second point
    }
    override func draw(_ context: CGContext, _ isRed: Bool) {
        context.setFillColor(UIColor.clear.cgColor)
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
            context.setStrokeColor(UIColor.blue.cgColor)
        }
        context.setLineWidth(strokeWidth)
        let radius = sqrt(pow(coordinates.x-slope.x,2)+pow(coordinates.y-slope.y,2))
        let rect=CGRect(x: coordinates.x-radius, y: coordinates.y-radius, width: radius*2, height: radius*2)
        context.addEllipse(in: rect)
        context.drawPath(using: .fillStroke)
        if showLabel {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
            let string = "\(character[index%24])\(index/24)"
            let xx=slope.x-coordinates.x, yy=slope.y-coordinates.y, dd=sqrt(xx*xx+yy*yy)
            string.draw(with: CGRect(x: yy/dd*(dd+20)+coordinates.x, y: -xx*(dd+20)/dd+coordinates.y, width: 50, height: 18), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
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
    
class ThreePointLine: Line {     // parent: point, point, point.
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: CGPoint.zero, number: number)
        update()
        type=THREEptLINE
        index=number
    }
    override func update() {
        if parent[0].isReal && parent[1].isReal && parent[2].isReal {
            let temp0=Line(ancestor:[parent[0],parent[1]],point:parent[0].coordinates,number: 0)
            if temp0.distance(parent[2].coordinates)<epsilon {
                isReal=true
                temp0.update()
                slope=temp0.slope
                coordinates=parent[0].coordinates
            } else {
                isReal=false
                let point=CGPoint.zero
                let temp1=MidPoint(ancestor: [parent[0],parent[1]], point: point, number: 1)
                let temp2=MidPoint(ancestor: [parent[0],parent[2]], point: point, number: 2)
                let temp3=Line(ancestor: [parent[0],parent[1]], point: point, number: 3)
                let temp4=Line(ancestor: [parent[0],parent[2]], point: point, number: 4)
                let temp5=PerpLine(ancestor: [temp1,temp3], point: point, number: 5)
                let temp6=PerpLine(ancestor: [temp2,temp4], point: point, number: 6)
                let temp7=LineIntLine(ancestor: [temp5,temp6], point: point, number: 7)
                coordinates=temp7.coordinates
            }
        } else {
            isReal = false
        }
    }
}
    
class Bisector0: Line {                            // parents: point, line, line
    var lastSlope=CGPoint(x: 1.0, y: 0.0)
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        let point0=ancestor[0].coordinates                                  //
        super.init(ancestor: ancestor, point: point0, number: number)       //
        update()
        type=BISECTOR0
        index=number
    }
    
    override func update() {                                                //
        coordinates=parent[0].coordinates                                   //
        if !parent[0].isReal || !parent[1].isReal || !parent[2].isReal {    //
            isReal=false                                                    //
        } else {                                                            //
            isReal=true                                                     //
            let c0=parent[1].slope.x, c1=parent[2].slope.x                  //
            let s0=parent[1].slope.y, s1=parent[2].slope.y                  //
            if abs(s1*c0-s0*c1)<epsilon {
                slope=parent[1].slope
            } else if abs(s0+s1)<epsilon {
                slope=CGPoint(x: 1.0, y: 0.0)
            } else {
                isReal=true
                let slope1=CGPoint(x: sqrt((1+c0*c1-s0*s1)/2), y: sqrt((1-c0*c1+s0*s1)/2)*abs(s0+s1)/(s0+s1))
                let slope2=CGPoint(x: sqrt((1-c0*c1+s0*s1)/2), y: -sqrt((1+c0*c1-s0*s1)/2)*abs(s0+s1)/(s0+s1))
                let point1=CGPoint(x: cos(2*atan2(slope1.x,slope1.y)),y: sin(2*atan2(slope1.x,slope1.y)))
                let point2=CGPoint(x: cos(2*atan2(slope2.x,slope2.y)),y: sin(2*atan2(slope2.x,slope2.y)))
                let point=CGPoint(x: cos(2*atan2(lastSlope.x,lastSlope.y)),y: sin(2*atan2(lastSlope.x,lastSlope.y)))
                if sqrt(pow(point1.x-point.x,2)+pow(point1.y-point.y,2)) < sqrt(pow(point2.x-point.x,2)+pow(point2.y-point.y,2)) {
                    slope=slope1
                } else {
                    slope=slope2
                }
            }
            lastSlope=slope
            normalizeSlope()
        }                                                                   //
    }                                                                       //
}
    
class Bisector1: Line {                                                // parents: point, line, line
    var lastSlope = CGPoint(x: 0.0,y: 1.0)
    override init(ancestor: [Construction], point: CGPoint, number: Int) {  //
        let point0=ancestor[0].coordinates                                  //
        super.init(ancestor: ancestor, point: point0, number: number)       //
        update()
        type=BISECTOR1
        index=number
    }
    override func update() {                                                //
        coordinates=parent[0].coordinates                                   //
        let c0=parent[1].slope.x, c1=parent[2].slope.x                      //
        let s0=parent[1].slope.y, s1=parent[2].slope.y                      //
        if !parent[0].isReal || !parent[1].isReal || !parent[2].isReal || abs(s0*c1-c0*s1)<epsilon {
            isReal=false                                                    //
        } else {                                                            //
            isReal=true
            if abs(s0+s1)<epsilon {
                slope=CGPoint(x: 1.0, y: 0.0)
            } else {
                let slope1=CGPoint(x: sqrt((1+c0*c1-s0*s1)/2), y: sqrt((1-c0*c1+s0*s1)/2)*abs(s0+s1)/(s0+s1))
                let slope2=CGPoint(x: sqrt((1-c0*c1+s0*s1)/2), y: -sqrt((1+c0*c1-s0*s1)/2)*abs(s0+s1)/(s0+s1))
                let point1=CGPoint(x: cos(2*atan2(slope1.x,slope1.y)),y: sin(2*atan2(slope1.x,slope1.y)))
                let point2=CGPoint(x: cos(2*atan2(slope2.x,slope2.y)),y: sin(2*atan2(slope2.x,slope2.y)))
                let point=CGPoint(x: cos(2*atan2(lastSlope.x,lastSlope.y)),y: sin(2*atan2(lastSlope.x,lastSlope.y)))
                if sqrt(pow(point1.x-point.x,2)+pow(point1.y-point.y,2)) < sqrt(pow(point2.x-point.x,2)+pow(point2.y-point.y,2)) {
                    slope=slope1
                } else {
                    slope=slope2
                }
            }
            lastSlope=slope
            normalizeSlope()
        }
    }
}
    
class Tool6Point0: Point {                   // parents: point, point, line, line
    var points=[CGPoint.zero,CGPoint.zero,CGPoint.zero]
    var lastSlopes=[CGPoint.zero,CGPoint.zero,CGPoint.zero]
    var slopes=[CGPoint.zero,CGPoint.zero,CGPoint.zero]
    var reals=[true,true,true]
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        let point0=ancestor[0].coordinates
        super.init(ancestor: ancestor, point: point0, number: number)
        update()
        type=TOOL6PT0
        index=number
        update()
    }
    
    func update() {
        if parent[0].isReal && parent[1].isReal && parent[2].isReal && parent[3].isReal {
            let point0=parent[0].coordinates, point1=parent[1].coordinates
            let point2=parent[2].parent[0].coordinates, line2=parent[2].slope
            let point3=parent[3].parent[0].coordinates, line3=parent[3].slope
            let x0 = point0.x, y0 = point0.y, x1 = point1.x, y1 = point1.y
            let x2 = point2.x, y2 = point2.y, x3 = point3.x, y3 = point3.y
            let mx = 1.0                                                        // and x4 = 0
            let sx2 = line2.x, sy2 = line2.y, sx3 = line3.x, sy3 = line3.y
            let d = mx*mx*mx*sx3*((y0+y2)*sx2+sy2*(x0-x2))-mx*mx*mx*sx2*((y1+y3)*sx3+sy3*(x1-x3))
            let c = -2*mx*mx*sx3*(sx2*x0-sy2*y0)+sy3*((y0+y2)*sx2+sy2*(x0-x2))*mx*mx+2*mx*mx*sx2*(sx3*x1-sy3*y1)-sy2*((y1+y3)*sx3+sy3*(x1-x3))*mx*mx
            let b = mx*sx3*(-(y0-y2)*sx2-sy2*(x0+x2))-2*sy3*(sx2*x0-sy2*y0)*mx-mx*sx2*(-(y1-y3)*sx3-sy3*(x1+x3))+2*sy2*(sx3*x1-sy3*y1)*mx
            let a = sy3*(-(y0-y2)*sx2-sy2*(x0+x2))-sy2*(-(y1-y3)*sx3-sy3*(x1+x3))
            let mySolutions = cubicSolve(a: a, b: b, c: c, d: d)
            for i in 0..<3 {
                if i<mySolutions.count {
                    reals[i]=true
                    let my=mySolutions[i].real
                    points[i]=CGPoint(x: 0.0,y: (((y0+y2)*sx2+sy2*(x0-x2))*mx*mx-2*my*(sx2*x0-sy2*y0)*mx-my*my*((y0-y2)*sx2+sy2*(x0+x2)))/(2*mx*(mx*sx2+my*sy2)))
                    slopes[i]=CGPoint(x: 1.0, y: my)
                } else {
                    reals[i]=false
                }
            }
            coordinates=points[0]
        }
        // Next we need to check whether we should permute the points based on their proximity to lastPoints.
        // However, we need to do this based off lastSlopes, since the distance is huge when the slope changes
        // from close to negative pi/2 to close to pi/2...
        var s = [CGPoint.zero,CGPoint.zero,CGPoint.zero]
        var ls = [CGPoint.zero,CGPoint.zero,CGPoint.zero]
        for i in 0..<3 {
            s[i]=CGPoint(x: cos(2*atan2(slopes[i].x,slopes[i].y)),y: sin(2*atan2(slopes[i].x,slopes[i].y)))
            ls[i]=CGPoint(x: cos(2*atan2(lastSlopes[i].x,lastSlopes[i].y)),y: sin(2*atan2(lastSlopes[i].x,lastSlopes[i].y)))
        }
        if pow(s[0].x-ls[0].x,2)+pow(s[0].y-ls[0].y,2)+pow(s[1].x-ls[1].x,2)+pow(s[1].y-ls[1].y,2) > pow(s[0].x-ls[1].x,2)+pow(s[0].y-ls[1].y,2)+pow(s[1].x-ls[0].x,2)+pow(s[1].y-ls[0].y,2) {
            let temp0=points[0], temp1=slopes[0], temp2=reals[0]
            points[0]=points[1]
            slopes[0]=slopes[1]
            reals[0]=reals[1]
            points[1]=temp0
            slopes[1]=temp1
            reals[1]=temp2
        }
        for i in 0..<3 {
            s[i]=CGPoint(x: cos(2*atan2(slopes[i].x,slopes[i].y)),y: sin(2*atan2(slopes[i].x,slopes[i].y)))
            ls[i]=CGPoint(x: cos(2*atan2(lastSlopes[i].x,lastSlopes[i].y)),y: sin(2*atan2(lastSlopes[i].x,lastSlopes[i].y)))
        }
        if pow(s[1].x-ls[1].x,2)+pow(s[1].y-ls[1].y,2)+pow(s[2].x-ls[2].x,2)+pow(s[2].y-ls[2].y,2) > pow(s[1].x-ls[2].x,2)+pow(s[1].y-ls[2].y,2)+pow(s[2].x-ls[1].x,2)+pow(s[2].y-ls[1].y,2)  {
            let temp0=points[2], temp1=slopes[2], temp2=reals[2]
            points[2]=points[1]
            slopes[2]=slopes[1]
            reals[2]=reals[1]
            points[1]=temp0
            slopes[1]=temp1
            reals[1]=temp2
        }
        for i in 0..<3 {
            s[i]=CGPoint(x: cos(2*atan2(slopes[i].x,slopes[i].y)),y: sin(2*atan2(slopes[i].x,slopes[i].y)))
            ls[i]=CGPoint(x: cos(2*atan2(lastSlopes[i].x,lastSlopes[i].y)),y: sin(2*atan2(lastSlopes[i].x,lastSlopes[i].y)))
        }
        if pow(s[0].x-ls[0].x,2)+pow(s[0].y-ls[0].y,2)+pow(s[1].x-ls[1].x,2)+pow(s[1].y-ls[1].y,2) > pow(s[0].x-ls[1].x,2)+pow(s[0].y-ls[1].y,2)+pow(s[1].x-ls[0].x,2)+pow(s[1].y-ls[0].y,2)  {
            let temp0=points[0], temp1=slopes[0], temp2=reals[0]
            points[0]=points[1]
            slopes[0]=slopes[1]
            reals[0]=reals[1]
            points[1]=temp0
            slopes[1]=temp1
            reals[1]=temp2
        }
        for i in 0..<3 {    // here we check to make sure the fold moves pt0 & pt1 to line2 & line3
            if reals[i] {let temp=Point(point: points[i], number: 0)
                let temp0=Point(point: CGPoint(x: points[i].x + slopes[i].x, y: points[i].y + slopes[i].y), number: 1)
                let temp1=Line(ancestor: [temp,temp0], point: coordinates, number: 2)
                let temp2=FoldedPoint(ancestor:[parent[0],temp1],point: parent[0].coordinates, number: 3)
                let temp3=FoldedPoint(ancestor:[parent[1],temp1],point: parent[1].coordinates, number: 4)
                if parent[2].distance(temp2.coordinates)+parent[3].distance(temp3.coordinates)>epsilon {
                    reals[i]=false
                } else {
                    reals[i]=true
                }
            }
        }
        isReal=reals[0]
        coordinates=points[0]
        for i in 0..<3 {
            if reals[i] {
                lastSlopes[i]=slopes[i]
            }
        }
    }
}
class Tool6Line0: Line {                                  // parents: point (T6P0)
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        if let temp = parent[0] as? Tool6Point0 {
            isReal=temp.reals[0]
            coordinates=temp.points[0]
            slope=temp.slopes[0]
            normalizeSlope()
        } else {
            isReal=false
        }
        type=TOOL6LINE0
        index=number
    }
    override func update() {
        if let temp=parent[0] as? Tool6Point0 {
            coordinates=temp.points[0]
            slope=temp.slopes[0]
            isReal=temp.reals[0]
            normalizeSlope()
        } else {
            isReal=false
        }
        isReal = isReal && parent[0].isReal
    }
}
class Tool6Point1: Point {                                  // parents: point (T6P0)
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        if let temp = parent[0] as? Tool6Point0 {
            isReal=temp.reals[1]
            coordinates=temp.points[1]
            slope=temp.slopes[1]
        } else {
            isReal=false
        }
        type=TOOL6PT1
        index=number
    }
    
    func update() {
        if let temp=parent[0] as? Tool6Point0 {
            isReal=temp.reals[1]
            coordinates=temp.points[1]
            slope=temp.slopes[1]
        } else {
            isReal=false
        }
    }
}
class Tool6Line1: Line {                                  // parents: T6P1, point T6P0
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        if let temp = parent[0] as? Tool6Point1 {
            isReal=temp.isReal
            coordinates=temp.coordinates
            slope=temp.slope
            normalizeSlope()
        } else {
            isReal=false
        }
        type=TOOL6LINE1
        index=number
    }
    
    override func update() {
        if let temp = parent[0] as? Tool6Point1 {
            isReal=temp.isReal
            coordinates=temp.coordinates
            slope=temp.slope
            normalizeSlope()
        } else {
            isReal=false
        }
        isReal = isReal && parent[0].isReal
    }
}
class Tool6Point2: Point {                                  // parents: point (T6P0)
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        if let temp = parent[0] as? Tool6Point0 {
            isReal=temp.reals[2]
            coordinates=temp.points[2]
            slope=temp.slopes[2]
        } else {
            isReal=false
        }
        type=TOOL6PT2
        index=number
    }
    
    func update() {
        if let temp=parent[0] as? Tool6Point0 {
            isReal=temp.reals[2]
            coordinates=temp.points[2]
            slope=temp.slopes[2]
        } else {
            isReal=false
        }
    }
}
class Tool6Line2: Line {                                  // parents: T6P2, point T6P0
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        if let temp = parent[0] as? Tool6Point2 {
            isReal=temp.isReal
            coordinates=temp.coordinates
            slope=temp.slope
            normalizeSlope()
        } else {
            isReal=false
        }
        type=TOOL6LINE2
        index=number
    }
    
    override func update() {
        if let temp=parent[0] as? Tool6Point2 {
            isReal=temp.isReal
            coordinates=temp.coordinates
            slope=temp.slope
            normalizeSlope()
        } else {
            isReal=false
        }
        isReal = isReal && parent[0].isReal
    }
}

class Triangle: Measure { // parent: point, point, point, (unit) distance
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        type=TriAREA
        textString="\(character[index%24])\(index/24) :  Δ(\(character[parent[0].index%24])\(parent[0].index/24),\(character[parent[1].index%24])\(parent[1].index/24),\(character[parent[2].index%24])\(parent[2].index/24))"
        for i in 0..<3 {
            parent[i].showLabel=true
        }
        showLabel=false
        coordinates=point
    }
    override func update(point: CGPoint) {
        let labels=[parent[0].showLabel,parent[1].showLabel,parent[2].showLabel]
        var parentsAllReal=true
        for object in parent {
            if !object.isReal {
                parentsAllReal=false
            }
        }
        if parentsAllReal {
            isReal=true
            coordinates=point
            let temp0=Line(ancestor: [parent[0],parent[1]], point: point, number: 0)
            let temp1=PerpLine(ancestor: [parent[2],temp0], point: point, number: 1)
            let temp2=LineIntLine(ancestor: [temp0,temp1], point: point, number: 2)
            let temp3=Distance(ancestor: [parent[0],parent[1],parent[3]], point: point, number: 3)
            let temp4=Distance(ancestor: [temp2,parent[2],parent[3]], point: point, number: 4)
            value=temp4.value*temp3.value/2
        }
        else {
            isReal=false
        }
        for i in 0..<3 {
            parent[i].showLabel=labels[i]
        }
    }
    override func draw(_ context: CGContext, _ isRed: Bool) {
        context.setFillColor(UIColor(hue:(CGFloat(3*index)/22.0), saturation: 1.0, brightness: 1.0, alpha: 0.25).cgColor)
        context.move(to: parent[0].coordinates)
        context.addLine(to: parent[1].coordinates)
        context.addLine(to: parent[2].coordinates)
        context.closePath()
        context.fillPath()      // up to here highlighted the triangle
        
        context.setFillColor(UIColor.clear.cgColor)
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
            context.setStrokeColor(UIColor(hue:(CGFloat(3*index)/22.0), saturation: 1.0, brightness: 1.0, alpha: 0.5).cgColor)
        }
        context.setLineWidth(strokeWidth)
        let currentRect = CGRect(x: coordinates.x-4.0,y:coordinates.y-4.0,
                                 width: 8.0,
                                 height: 8.0)
        context.addEllipse(in: currentRect)
        context.drawPath(using: .fillStroke)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        let string = textString+" ≈ \(round(1000000*(value)+0.3)/1000000)"
        string.draw(with: CGRect(x: coordinates.x+10, y: coordinates.y-8, width:350, height: 18), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
}

class CircleArea: Measure { // parent: circle, (unit) distance
    override init(ancestor: [Construction], point: CGPoint, number: Int) {
        super.init(ancestor: ancestor, point: point, number: number)
        type=CircAREA
        parent[0].showLabel=true
        textString="\(character[index%24])\(index/24) : ⦿(\(character[parent[0].index%24])\(parent[0].index/24))"
        coordinates=point
    }
    override func update(point: CGPoint) {
        let labels=[parent[0].parent[0].showLabel,parent[0].parent[1].showLabel]
        var parentsAllReal=true
        for object in parent {
            if !object.isReal {
                parentsAllReal=false
            }
        }
        if parentsAllReal {
            isReal=true
            let temp=Distance(ancestor: [parent[0].parent[0],parent[0].parent[1],parent[1]], point: point, number: 0)
            value = 3.141592653589793*temp.value*temp.value
            coordinates=point
        }
        else {
            isReal=false
        }
        parent[0].parent[0].showLabel=labels[0]
        parent[0].parent[1].showLabel=labels[1]
    }
    override func draw(_ context: CGContext, _ isRed: Bool) {
        context.setFillColor(UIColor(hue:(CGFloat(3*index)/22.0), saturation: 1.0, brightness: 1.0, alpha: 0.25).cgColor)
        let radius = sqrt(pow(parent[0].parent[0].coordinates.x-parent[0].parent[1].coordinates.x,2)+pow(parent[0].parent[0].coordinates.y-parent[0].parent[1].coordinates.y,2))
        let rect0 = CGRect(x: parent[0].coordinates.x-radius,
                           y: parent[0].coordinates.y-radius,
                           width: 2*radius, height:2*radius)
        context.fillEllipse(in: rect0)
        context.setFillColor(UIColor.clear.cgColor)
        if isRed {
            context.setStrokeColor(UIColor.red.cgColor)
        } else {
            context.setStrokeColor(UIColor(hue:(CGFloat(3*index)/22.0), saturation: 1.0, brightness: 1.0, alpha: 0.5).cgColor)
        }
        context.setLineWidth(strokeWidth)
        let currentRect = CGRect(x: coordinates.x-4.0,y:coordinates.y-4.0,
                                 width: 8.0,
                                 height: 8.0)
        context.addEllipse(in: currentRect)
        context.drawPath(using: .fillStroke)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        let string = textString+" ≈ \(round(1000000*(value)+0.3)/1000000)"
        string.draw(with: CGRect(x: coordinates.x+10, y: coordinates.y-8, width:350, height: 18), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
    }
}
