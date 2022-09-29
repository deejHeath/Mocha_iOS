import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    var potentialClick: Construction?
    var linkedList: [Construction] = []
    let canvas = Canvas()
    var clickedList: [Construction] = []
    var futureList: [Construction] = []
    var clickedIndex: [Int] = []
    let actionText=["Draw or move POINTS.", "Draw midpoint between 2 POINTS.","Draw intersection of 2 OBJECTS.","Fold POINT in LINE.","Invert POINT in CIRCLE.", "Draw segment on 2 POINTS.", "Draw ray on 2 POINTS.","Draw line on 2 POINTS.","Draw line on POINT and ⊥ to LINE.","Draw line on POINT and || to LINE.","Draw bisector to 2 LINES.","Origami 6: Fold 2 POINTS to 2 LINES.","Draw circle with center POINT and POINT on it.","Draw 3 POINT circle."]
    let measureText=["Measure distance between 2 POINTS.","Choose 3 POINTS to measure angle.", "Measure area of CIRCLE.","Show sum of two MEASURES.","Show difference of 2 MEASURES.","Show product of 2 MEASURES.","Show ratio of 2 MEASURES.","Hide OBJECT.","Show or hide label of OBJECT.","Toggle degrees / radians."]
    let makePoints=0, makeMidpoint=1, makeIntersections=2, foldPoints=3, invertPoints=4
    let makeSegments=5, makeRays=6, makeLines=7, makePerps=8, makeParallels=9
    let makeBisectors=10, useOrigamiSix=11, makeCircles=12, make3PTCircle=13
    let measureDistance=20
    let hideObject=27
    let POINT = 1, PTonLINE = 2, PTonCIRCLE = 3, MIDPOINT = 4
    let LINEintLINE = 5, FOLDedPT = 6, INVERTedPT=7
    let CIRCintCIRC0 = 8,CIRCintCIRC1 = 9, LINEintCIRC0 = 10, LINEintCIRC1 = 11
    let BiPOINT = 12, THREEptCIRCLEcntr=13
    let TOOL6PT0 = 14, TOOL6PT1 = 15, TOOL6PT2 = 16
    let DISTANCE = 20, ANGLE = 21, RATIO = 22
    let CIRCLE = 0
    let LINE = -1, PERP = -2, PARALLEL = -3, BISECTOR0 = -4, BISECTOR1 = -5, TOOL6LINE0 = -7
    let TOOL6LINE1 = -8, TOOL6LINE2 = -9, THREEptLINE = -10, SEGMENT = -11, RAY = -12
    private var whatToDo=0
    var firstTouch: CGPoint?
    var activeConstruct = false
    let touchSense=16.0
    var unitChosen=false
    var unitIndex = -1
    var newPoint=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.backgroundColor = .white
        canvas.isUserInteractionEnabled = true
        canvas.isMultipleTouchEnabled = false // if we want to add dilation functionality this will need to be true
        view.addSubview(canvas)
        NSLayoutConstraint.activate([canvas.centerXAnchor.constraint(equalTo: view.centerXAnchor),canvas.centerYAnchor.constraint(equalTo: view.centerYAnchor),canvas.widthAnchor.constraint(equalTo: view.widthAnchor),canvas.heightAnchor.constraint(equalToConstant: 540)])
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: canvas)
        firstTouch=location
        activeConstruct=false
        newPoint=false
        switch whatToDo {
        case makePoints:
            getPointOrMeasure(location)
            if !activeConstruct {
                newPoint=true
                getLineOrCircle(location)
            }
            if !activeConstruct {
                linkedList.append(Point(ancestor: [], point: location, number: linkedList.count))
                setActiveConstruct(linkedList.count-1)
            } else {
                if clickedList[0].type<0 {
                    linkedList.append(PointOnLine(ancestor: clickedList, point: location, number: linkedList.count))
                    setActiveConstruct(linkedList.count-1)
                } else if clickedList[0].type==0 {
                    linkedList.append(PointOnCircle(ancestor: clickedList, point: location, number: linkedList.count))
                    setActiveConstruct(linkedList.count-1)
                }
            }
            break
        case makeLines,measureDistance,makeCircles,makeMidpoint,make3PTCircle:
            getPoint(location)
            if !activeConstruct {
                potentialClick=nil
            }
            break
        case makeBisectors:
            getLine(location)
            if !activeConstruct {
                potentialClick=nil
            }
            break
        case foldPoints,makePerps,makeParallels:
            if clickedList.count==0 {
                getPoint(location)
            } else if clickedList.count==1 {
                getLine(location)
            }
            if !activeConstruct {
                potentialClick=nil
            }
            break
        case invertPoints:
            if clickedList.count==0 {
                getPoint(location)
            } else if clickedList.count==1 {
                getCircle(location)
            }
            if !activeConstruct {
                potentialClick=nil
            }
            break
        case makeIntersections:
            getLineOrCircle(location)
            if !activeConstruct {
                potentialClick=nil
            }
            break
        case useOrigamiSix:
            if clickedList.count==0 || clickedList.count==1 {
                getPoint(location)
            } else if clickedList.count==2 || clickedList.count==3 {
                getLine(location)
            }
            break
        case hideObject:
            if !activeConstruct {
                getPoint(location)
            }
            if !activeConstruct {
                getLineOrCircle(location)
            }
            if !activeConstruct {
                potentialClick=nil
            }
            break
        default:
            print("touchesBegan \(location)")
        }
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: canvas)
        switch whatToDo {
        case makePoints:
            if !newPoint {
                update(object: clickedList[0], point: location)
            } else { // otherwise the point is new, and we can do what we like with it.
                clearAllPotentials()
                getLineOrCircle(location)
                if activeConstruct {
                    if clickedList[0].type<0 {
                        linkedList.removeLast()
                        linkedList.append(PointOnLine(ancestor: clickedList, point: location, number: linkedList.count))
                        setActiveConstruct(linkedList.count-1)
                    } else {
                        linkedList.removeLast()
                        linkedList.append(PointOnCircle(ancestor: clickedList, point: location, number: linkedList.count))
                        setActiveConstruct(linkedList.count-1)
                    }
                } else {
                    linkedList.removeLast()
                    linkedList.append(Point(ancestor: [], point: location, number: linkedList.count))
                    setActiveConstruct(linkedList.count-1)
                }
            }
            for object in linkedList {
                update(object: object, point: object.coordinates)
                update(object: object, point: object.coordinates)
            }
            break
        case makeLines, measureDistance, makeCircles, makeMidpoint,make3PTCircle:
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                getPoint(location)
            }
            break
        case makeBisectors:
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                getLine(location)
            }
            break
        case foldPoints,makePerps,makeParallels:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if clickedList.count==0 {
                getPoint(location)
            } else if clickedList.count==1 {
                getLine(location)
            }
            break
        case invertPoints:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Circle {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if clickedList.count==0 {
                getPoint(location)
            } else if clickedList.count==1 {
                getCircle(location)
            }
            break
        case useOrigamiSix:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if clickedList.count==0 || clickedList.count==1 {
                getPoint(location)
            } else if clickedList.count==2 || clickedList.count==3 {
                getLine(location)
            }
            break
        case makeIntersections:
            if activeConstruct {
                if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Circle {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                getLineOrCircle(location)
            }
            break
        case hideObject:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        activeConstruct=false
                        clearLastPotential()
                    }
                }
                if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        activeConstruct=false
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                getPoint(location)
            }
            if !activeConstruct {
                getLineOrCircle(location)
            }
            break
        default:
            print("touchesMoved: \(location)")
        }
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: canvas)
        switch whatToDo {
        case makePoints:
            if activeConstruct {
                if clickedList[0].type>0 {
                    update(object: clickedList[0], point: location)
                } else if clickedList[0].type<0 {
                    let temp = PointOnLine(ancestor: clickedList, point: location, number: linkedList.count)
                    update(object: temp, point: location)
                    linkedList.removeLast()
                    linkedList.append(temp)
                } else if clickedList[0].type==0 {
                    let temp = PointOnCircle(ancestor: clickedList, point: location, number: linkedList.count)
                    update(object: temp, point: location)
                    linkedList.removeLast()
                    linkedList.append(temp)
                }
            } else {
                linkedList.append(Point(point: location, number: linkedList.count))
            }
            clearAllPotentials()
            break
        case makeLines:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==LINE {
                        if let temp=linkedList[i] as? Line {
                            if !alreadyExists {
                                if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                    alreadyExists=true
                                    linkedList[i].isShown=true
                                    clearAllPotentials()
                                }
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(Line(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    clearAllPotentials()
                }
            }
            break
        case makeMidpoint:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==MIDPOINT {
                        if let temp=linkedList[i] as? MidPoint {
                            if !alreadyExists {
                                if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                    alreadyExists=true
                                    linkedList[i].isShown=true
                                    clearAllPotentials()
                                }
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(MidPoint(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    clearAllPotentials()
                }
            }
            break
        case makeBisectors:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==BiPOINT {
                        if let temp=linkedList[i] as? BisectorPoint {
                            if !alreadyExists {
                                if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                    alreadyExists=true
                                    linkedList[i+1].isShown=true
                                    linkedList[i+2].isShown=true
                                    clearAllPotentials()
                                }
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(BisectorPoint(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].isShown=false
                    clickedList.insert(linkedList[linkedList.count-1], at: 0)
                    linkedList.append(Bisector0(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    linkedList.append(Bisector1(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    clearAllPotentials()
                }
            }
            break
        case foldPoints:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==FOLDedPT {
                        if let temp=linkedList[i] as? FoldedPoint {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(FoldedPoint(ancestor: clickedList, point: location, number: linkedList.count))
                    clearAllPotentials()
                }
            }
            break
        case invertPoints:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Circle {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==INVERTedPT {
                        if let temp=linkedList[i] as? InvertedPoint {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(InvertedPoint(ancestor: clickedList, point: location, number: linkedList.count))
                    clearAllPotentials()
                }
            }
            break
        case makePerps:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==PERP {
                        if let temp=linkedList[i] as? PerpLine {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(PerpLine(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    clearAllPotentials()
                }
            }
            break
        case makeParallels:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==PARALLEL {
                        if let temp=linkedList[i] as? ParallelLine {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(ParallelLine(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    clearAllPotentials()
                }
            }
            break
        case makeCircles:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Circle {
                        if !alreadyExists {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(Circle(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(ancestor: linkedList[linkedList.count-1].parent)
                    clearAllPotentials()
                }
            }
            break
        case make3PTCircle:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==3 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type<0 {
                        if let temp=linkedList[i] as? ThreePointLine {
                            if !alreadyExists {
                                if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index && temp.parent[2].index == clickedList[2].index {
                                    alreadyExists=true
                                    linkedList[i].isShown=true
                                    linkedList[i+2].isShown=true
                                    clearAllPotentials()
                                }
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(ThreePointLine(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    clickedList.append(linkedList[linkedList.count-1])
                    linkedList.append(ThreePointCircleCntr(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].isShown=false
                    let temp=clickedList[0]
                    clearAllPotentials()
                    clickedList.append(linkedList[linkedList.count-1])
                    clickedList.append(temp)
                    linkedList.append(Circle(ancestor: clickedList, point: location, number: linkedList.count))
                    clearAllPotentials()
                }
            }
            break
        case useOrigamiSix:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==4 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==TOOL6PT0 {
                        if let temp=linkedList[i] as? Tool6Point0 {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index && temp.parent[2].index==clickedList[2].index && temp.parent[3].index==clickedList[3].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                linkedList[i+1].isShown=true
                                linkedList[i+2].isShown=true
                                linkedList[i+3].isShown=true
                                linkedList[i+4].isShown=true
                                linkedList[i+5].isShown=true
                                
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(Tool6Point0(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].isShown=false
                    clickedList.removeAll()
                    clickedList.append(linkedList[linkedList.count-1])
                    linkedList.append(Tool6Line0(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList.append(Tool6Point1(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].isShown=false
                    clickedList.insert(linkedList[linkedList.count-1], at: 0)
                    linkedList.append(Tool6Line1(ancestor: clickedList, point: location, number: linkedList.count))
                    clickedList.remove(at: 0)
                    linkedList.append(Tool6Point2(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].isShown=false
                    clickedList.insert(linkedList[linkedList.count-1], at: 0)
                    linkedList.append(Tool6Line2(ancestor: clickedList, point: location, number: linkedList.count))

                }
                clearAllPotentials()
            }
            break
        case makeIntersections:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {       // need to construct InterPt0 & InterPt1.
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? LineIntLine {
                        if !alreadyExists {
                            if (temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index) || (temp.parent[0].index == clickedList[1].index && temp.parent[1].index == clickedList[0].index){
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    if clickedList[0].type<0 && clickedList[1].type<0 {             // both lines
                        linkedList.append(LineIntLine(ancestor: clickedList, point: location, number: linkedList.count))
                        linkedList[linkedList.count-1].update(ancestor: linkedList[linkedList.count-1].parent)
                        clearAllPotentials()
                    } else if clickedList[0].type==0 && clickedList[1].type==0 {    // both circles
                        linkedList.append(CircIntCirc0(ancestor: clickedList, point: location, number: linkedList.count))
                        update(object: linkedList[linkedList.count-1],point: location)
                        clickedList.append(linkedList[linkedList.count-1])
                                        // used this for getting CIC0 in there to pass information to CIC1
                        linkedList.append(CircIntCirc1(ancestor: clickedList, point: location, number: linkedList.count))
                        update(object: linkedList[linkedList.count-1],point: location)
                        clearAllPotentials()
                    } else {                                                        // one line, one circle
                        if clickedList[0].type==0 {                 // make sure line is [0], circle is [1]
                            clickedList.append(clickedList[0])
                            clickedList.removeFirst()
                        }
                        linkedList.append(LineIntCirc0(ancestor: clickedList, point: location, number: linkedList.count))
                        update(object: linkedList[linkedList.count-1],point: location)
                        clickedList.append(linkedList[linkedList.count-1])
                                        // used this for getting LIC0 in there to pass information to LIC1
                        linkedList.append(LineIntCirc1(ancestor: clickedList, point: location, number: linkedList.count))
                        update(object: linkedList[linkedList.count-1],point: location)
                        clearAllPotentials()
                    }
                }
            }
            break
        case measureDistance:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Distance {
                        if !alreadyExists {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    } 
                }
                if !alreadyExists {
                    linkedList.append(Distance(ancestor: clickedList, point: location, number: linkedList.count))
                    if !unitChosen {
                        unitChosen=true
                        unitIndex=linkedList.count-1
                    }
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x:  (linkedList[linkedList.count-1].parent[0].coordinates.x+2*linkedList[linkedList.count-1].parent[1].coordinates.x)/3,y:  (2*linkedList[linkedList.count-1].parent[0].coordinates.y+linkedList[linkedList.count-1].parent[1].coordinates.y)/3))
                    clearAllPotentials()
                }
            }
            break
        case hideObject:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                } else if let temp = potentialClick as? Line {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==1 {
                linkedList[clickedIndex[0]].isShown=false
                clearAllPotentials()
            }
            break
        default:
            print("touchesEnded: \(location)")
        }
        for object in linkedList {
            update(object: object, point: object.coordinates)
            update(object: object, point: object.coordinates)
        }
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: canvas)
        print("touchesCancelled: \(location)")
        clearAllPotentials()
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
    
    func distance(_ object: Construction, _ point: CGPoint) -> Double {
        if let temp = object as? Point {
            return temp.distance(point)
        } else if let temp = object as? Line {
            return temp.distance(point)
        } else if let temp = object as? Circle {
            return temp.distance(point)
        } else {
            return 1000
        }
    }
    func getPointOrMeasure(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown && linkedList[i].isReal {
                if (linkedList[i].type>0 && linkedList[i].type<MIDPOINT) || linkedList[i].type>=DISTANCE {
                    setActiveConstruct(i)
                }
            }
        }
    }
    func getPoint(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown && linkedList[i].isReal {
                if linkedList[i].type>0 && linkedList[i].type<DISTANCE {
                    setActiveConstruct(i)
                }
            }
        }
    }
    func getLineOrCircle(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown && linkedList[i].isReal {
                if linkedList[i].type <= 0 {
                    setActiveConstruct(i)
                }
            }
        }
    }
    func getLine(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown && linkedList[i].isReal {
                if linkedList[i].type < 0 {
                    setActiveConstruct(i)
                }
            }
        }
    }
    func getCircle(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown && linkedList[i].isReal {
                if linkedList[i].type == 0 {
                    setActiveConstruct(i)
                }
            }
        }
    }
    func getRidOfActivesThatAreTooFar(_ location: CGPoint) {
        if activeConstruct {
            if let temp = potentialClick as? Point {
                if distance(temp,location)>touchSense {
                    clearLastPotential()
                }
            }
        }
    }
    func arrangeClickedObjectsByIndex() {
        if clickedIndex[0]>clickedIndex[1] {
            clickedList.append(clickedList[0]);
            clickedList.removeFirst();
        }
        if clickedList.count==3 {
            if clickedIndex[0]>clickedIndex[2] {
                clickedList.append(clickedList[0]);
                clickedList.removeFirst()
            }
            if clickedIndex[1]>clickedIndex[2] {
                clickedList.append(clickedList[1])
                clickedList.remove(at:1)
            }
        }
    }
    func clearActives() {
        if activeConstruct {
            potentialClick=nil
            activeConstruct=false
        }
    }
    func clearLastPotential() {
        clearActives()
        clickedList.removeLast()
        clickedIndex.removeLast()
    }
    func getRidOfDuplicates() {
        if clickedList.count>1 {
            if clickedIndex[0]==clickedIndex[1] {
                clearLastPotential()
            }
            if clickedList.count==3 {
                if clickedIndex[0]==clickedIndex[2] || clickedIndex[1]==clickedIndex[2] {
                    clearLastPotential()
                }
            }
        }
    }
    func clearAllPotentials() {
        clearActives()
        clickedIndex.removeAll()
        clickedList.removeAll()
    }
    
    func setActiveConstruct(_ i: Int) {
        activeConstruct=true
        potentialClick=linkedList[i]
        clickedList.append(linkedList[i])
        clickedIndex.append(i)
    }
    
    func update(object: Construction, point: CGPoint) {
        if let temp = object as? Distance {
            temp.update(point: point, unitValue: linkedList[unitIndex].value)
        } else if let temp = object as? PointOnLine {
            temp.update(point: point)
        } else if let temp = object as? PointOnCircle {
            temp.update(point: point)
        } else if let temp = object as? MidPoint {
            temp.update()
        } else if let temp = object as? LineIntLine {
            temp.update()
        } else if let temp = object as? CircIntCirc0 {
            temp.update()
        } else if let temp = object as? CircIntCirc1 {
            temp.update()
        } else if let temp = object as? LineIntCirc0 {
            temp.update()
        } else if let temp = object as? LineIntCirc1 {
            temp.update()
        } else if let temp = object as? FoldedPoint {
            temp.update()
        } else if let temp = object as? InvertedPoint {
            temp.update()
        } else if let temp = object as? ThreePointCircleCntr {
            temp.update()
        } else if let temp = object as? BisectorPoint {
            temp.update()
        } else if let temp = object as? BisectorPoint {
            temp.update()
        } else if let temp = object as? Tool6Point0 {
            temp.update()
        } else if let temp = object as? Tool6Point1 {
            temp.update()
        } else if let temp = object as? Tool6Point2 {
            temp.update()
        } else if let temp = object as? Point {
            temp.update(point: point)
        } else if let temp = object as? PerpLine {
            temp.update()
        } else if let temp = object as? ParallelLine {
            temp.update()
        } else if let temp = object as? ThreePointLine {
            temp.update()
        } else if let temp = object as? Bisector0 {
            temp.update()
        } else if let temp = object as? Bisector1 {
            temp.update()
        } else if let temp = object as? Tool6Line0 {
            temp.update()
        } else if let temp = object as? Tool6Line1 {
            temp.update()
        } else if let temp = object as? Tool6Line2 {
            temp.update()
        } else if let temp = object as? Line {
            temp.update()
        } else if let temp = object as? Circle {
            temp.update()
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let creationController = storyboard.instantiateViewController(withIdentifier: "creation_VC") as! CreationViewController
        creationController.view.backgroundColor = .white.withAlphaComponent(0.9)
        //creationController.modalPresentationStyle = .fullScreen
        creationController.completionHandler = {tag in
            self.whatToDo=tag
            self.infoLabel.text = self.actionText[self.whatToDo]
        }
        self.present(creationController, animated: false, completion: nil)
        clearAllPotentials()
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
    @IBAction func measureButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let measureController = storyboard.instantiateViewController(withIdentifier: "measure_VC") as! MeasureViewController
        measureController.view.backgroundColor = .white.withAlphaComponent(0.9)
        //measureController.modalPresentationStyle = .fullScreen
        measureController.completionHandler = {tag in
            self.whatToDo=tag
            self.infoLabel.text = self.measureText[self.whatToDo-20]
        }
        self.present(measureController, animated: false, completion: nil)
        clearAllPotentials()
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
    @IBAction func shareButtonPressed() {
        let renderer = UIGraphicsImageRenderer(size: canvas.bounds.size)
        let image = renderer.image { ctx in
            canvas.drawHierarchy(in: canvas.bounds, afterScreenUpdates: true)
        }
        let activity = UIActivityViewController(activityItems: [image] ,applicationActivities: nil)
        present(activity, animated: true)
        print("shareButtonPressed")
      }
    @IBAction func clearLastButtonPressed() {
        if linkedList.count-1 == unitIndex {
            unitChosen=false
            unitIndex=0
        }
        if linkedList.count>0 {
            if linkedList[linkedList.count-1].type==THREEptCIRCLEcntr {
                linkedList.removeLast()
                linkedList.removeLast()
            }
            if linkedList[linkedList.count-1].type==CIRCintCIRC1 || linkedList[linkedList.count-1].type==LINEintCIRC1 {
                linkedList.removeLast()                        // since there were two created at once
            }
            linkedList.removeLast()
            clearAllPotentials()
            canvas.update(constructions: linkedList, indices: clickedIndex)
            canvas.setNeedsDisplay()
        }
        if linkedList.count<2 {
            self.whatToDo=self.makePoints
            self.infoLabel.text = self.actionText[self.whatToDo]
        }
    }
    @IBAction func clearAllButtonPressed(_ sender: UIButton) {
        self.linkedList.removeAll()
        self.whatToDo=self.makePoints
        self.infoLabel.text = self.actionText[self.whatToDo]
        clearAllPotentials()
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
}
