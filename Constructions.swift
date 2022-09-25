//
//  Construction.swift
//  Mocha
//
//  Created by Daniel Heath on 9/22/22.
//

import UIKit

class Construction {
    var isReal=true
    var isShown=true
    var showLabel=false
    var value=0.0
    var coordinates: CGPoint
    var slope=CGPoint(x: 1.0,y: 0.0)
    var parent: [Construction] = []
    var type = 0
    var index = -1
    let makePoints=0, makeLines=1, makeSegments=2, makeRays=3, makeCircles=4
    let POINT = 1, PTonLINE0 = 2, IntPT = 3
    let CIRCLE = 0
    let LINE = -1, SEGMENT = -2, RAY = -3
    let epsilon = 0.0000001

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
    func update(point: CGPoint) {
        coordinates=point
    }
    func update(ancestor: [Construction]) {
    }
    func getPoint()->CGPoint {
        return coordinates
    }
    func draw(_ context: CGContext, _ isRed: Bool){
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
//        canvas.draw(in: canvas.bounds, blendMode: .normal, alpha: 1.0)
//        canvas.image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
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
//        canvas.image?.draw(in: canvas.bounds)
//        canvas.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
