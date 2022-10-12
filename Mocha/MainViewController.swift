import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoXLabel: UILabel!
    var potentialClick: Construction?
    var linkedList: [Construction] = []
    let canvas = Canvas()
    var clickedList: [Construction] = []
    var clickedIndex: [Int] = []
    let actionText=["Create or move POINTS", "Create midpoint between 2 POINTS","Intersect 2 OBJECTS","Fold POINT over LINE","Invert POINT in CIRCLE", "Create segment on 2 POINTS", "Create ray on 2 POINTS","Create line on 2 POINTS","create line on POINT and ⊥ to LINE","create line on POINT and || to LINE","Create bisector from 2 LINES","Fold from 2 POINTS to 2 LINES","Create circle with center POINT and POINT on","Create 3 POINT circle"]
    let measureText=["Measure distance between 2 POINTS","Measure angle from 3 POINTS","Measure area of triangle from 3 POINTS","Measure area of CIRCLE", "Measure sum of two MEASURES","Measure difference of 2 MEASURES","Measure product of 2 MEASURES","Measure ratio of 2 MEASURES","FIND sine of MEASURE","Find cosine of MEASURE.","Hide OBJECT","Show or hide label of OBJECT","Swipe to move everything"]
    let makePoints=0, makeMidpoint=1, makeIntersections=2, foldPoints=3, invertPoints=4
    let makeSegments=5, makeRays=6, makeLines=7, makePerps=8, makeParallels=9
    let makeBisectors=10, useOrigamiSix=11, makeCircles=12, make3PTCircle=13
    let measureDistance=20, measureAngle=21, measureTriArea=22, measureCircArea=23
    let measureSum=24, measureDifference=25, measureProduct=26, measureRatio=27
    let measureSine=28, measureCosine=29, hideObject=30, toggleLabel=31, translateAll=32
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
    private var whatToDo=0
    var firstTouch: CGPoint?
    var activeConstruct = false
    let touchSense=18.0
    var unitChosen=false
    var unitIndex = -1
    var newPoint=false
    var numberOfMeasures=1
    var firstMove=true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.backgroundColor = .white
        canvas.isUserInteractionEnabled = true
        canvas.isMultipleTouchEnabled = false // if we want to add dilation functionality this will need to be true
        view.addSubview(canvas)
        NSLayoutConstraint.activate([canvas.centerXAnchor.constraint(equalTo: view.centerXAnchor),canvas.centerYAnchor.constraint(equalTo: view.centerYAnchor),canvas.widthAnchor.constraint(equalTo: view.widthAnchor),canvas.heightAnchor.constraint(equalToConstant: view.frame.height-200)])
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: canvas)
        firstTouch=location
        activeConstruct=false
        newPoint=false
        firstMove=true
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
        case makeSegments, makeRays, makeLines, makeCircles, makeMidpoint:
            getPointOrLineOrCircle(location)
            if activeConstruct {
                if clickedList[0].type==0 {
                    linkedList.append(PointOnCircle(ancestor: clickedList, point: location, number: linkedList.count))
                    setActiveConstruct(linkedList.count-1)
                    clickedList.removeFirst()
                    clickedIndex.removeFirst()
                } else if clickedList[0].type<0 {
                    linkedList.append(PointOnLine(ancestor: clickedList, point: location, number: linkedList.count))
                    setActiveConstruct(linkedList.count-1)
                    clickedList.removeFirst()
                    clickedIndex.removeFirst()
                }
            } else {
                linkedList.append(Point(ancestor: [], point: location, number: linkedList.count))
                setActiveConstruct(linkedList.count-1)
            }
            break
        case measureDistance, make3PTCircle, measureAngle, measureTriArea:
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
        case foldPoints, makePerps, makeParallels:
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
        case hideObject, toggleLabel:
            getPointOrLineOrCircle(location)
            if !activeConstruct {
                potentialClick=nil
            }
            break
        case measureRatio, measureSum, measureProduct, measureDifference, measureSine, measureCosine:
            getMeasure(location)
            if !activeConstruct {
                potentialClick=nil
            }
            break
        case measureCircArea:
            getCircle(location)
            if !activeConstruct {
                potentialClick=nil
            }
            break
        case translateAll:
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
            }
            break
        case makeSegments, makeRays, makeCircles, makeMidpoint, makeLines:
            if firstMove {
                firstMove=false
            } else {
                linkedList.removeLast() // remove temporary segment
                clickedList.removeLast()
                clickedIndex.removeLast()
                if newPoint {
                    linkedList.removeLast() // remove temporary point
                    clickedList.removeLast()
                    clickedIndex.removeLast()
                    newPoint=false
                }
            }
            activeConstruct=false
            while clickedList.count>1 {
                clickedList.removeLast()
                clickedIndex.removeLast()
            }
            getPointOrLineOrCircle(location)
            if activeConstruct {
                if clickedList[clickedList.count-1].type>0 {
                    newPoint=false
                } else if clickedList[clickedList.count-1].type<0 {
                    newPoint=true
                    linkedList.append(PointOnLine(ancestor: [clickedList[clickedList.count-1]], point: location, number: linkedList.count))
                    clickedList.remove(at: 1)
                    clickedIndex.remove(at: 1)
                    setActiveConstruct(linkedList.count-1)
                } else {
                    newPoint=true
                    linkedList.append(PointOnCircle(ancestor: [clickedList[clickedList.count-1]], point: location, number: linkedList.count))
                    clickedList.remove(at: 1)
                    clickedIndex.remove(at: 1)
                    setActiveConstruct(linkedList.count-1)
                }
            } else {
                newPoint=true
                linkedList.append(Point(ancestor: [], point: location, number: linkedList.count))
                setActiveConstruct(linkedList.count-1)
            }
            switch whatToDo {
            case makeSegments: linkedList.append(Segment(ancestor: clickedList, point: location, number: linkedList.count))
                break
            case makeRays: linkedList.append(Ray(ancestor: clickedList, point: location, number: linkedList.count))
                break
            case makeLines: linkedList.append(Line(ancestor: clickedList, point: location, number: linkedList.count))
                break
            case makeCircles: linkedList.append(Circle(ancestor: clickedList, point: location, number: linkedList.count))
                break
            default: linkedList.append(MidPoint(ancestor: clickedList, point: location, number: linkedList.count))
            }
            setActiveConstruct(linkedList.count-1)
            break
        case measureDistance, make3PTCircle, measureAngle, measureTriArea:
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
        case foldPoints, makePerps, makeParallels:
            getRidOfActivesThatAreTooFar(location)
            if clickedList.count==0 {
                getPoint(location)
            } else if clickedList.count==1 {
                getLine(location)
            }
            break
        case invertPoints:
            getRidOfActivesThatAreTooFar(location)
            if clickedList.count==0 {
                getPoint(location)
            } else if clickedList.count==1 {
                getCircle(location)
            }
            break
        case useOrigamiSix:
            getRidOfActivesThatAreTooFar(location)
            if clickedList.count==0 || clickedList.count==1 {
                getPoint(location)
            } else if clickedList.count==2 || clickedList.count==3 {
                getLine(location)
            }
            break
        case makeIntersections:
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                getLineOrCircle(location)
            }
            break
        case measureRatio, measureSum, measureDifference, measureProduct, measureSine, measureCosine:
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                getMeasure(location)
            }
            break
        case measureCircArea:
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                getCircle(location)
            }
            break
        case hideObject, toggleLabel:
            getRidOfActivesThatAreTooFar(location)
            getPointOrLineOrCircle(location)
            break
        case translateAll:
            for i in 0..<linkedList.count {
                if linkedList[i].type>0 && linkedList[i].type<=PTonCIRCLE {
                    update(object: linkedList[i], point: CGPoint(x: linkedList[i].coordinates.x+location.x-firstTouch!.x,y: linkedList[i].coordinates.y+location.y-firstTouch!.y))
                } else if linkedList[i].type<DISTANCE {
                    update(object: linkedList[i], point: location)
                }
            }
            firstTouch=location
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
                    linkedList.removeLast()
                    linkedList.append(PointOnLine(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1],point: location)
                } else if clickedList[0].type==0 {
                    linkedList.removeLast()
                    
                    linkedList.append(PointOnCircle(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1],point: location)
                }
            } else {
                linkedList.append(Point(point: location, number: linkedList.count))
            }
            clearAllPotentials()
            break
        case makeCircles:
            if !firstMove {
                linkedList.removeLast() // remove temporary segment/ray etc.
                clickedList.removeLast()
                clickedIndex.removeLast()
                if newPoint {
                    linkedList.removeLast() // remove temporary point
                    clickedList.removeLast()
                    clickedIndex.removeLast()
                    newPoint=false
                }
            }
            activeConstruct=false
            while clickedList.count>1 {
                clickedList.removeLast()
                clickedIndex.removeLast()
            }
            getPointOrLineOrCircle(location)
            if activeConstruct {
                if clickedList[clickedList.count-1].type>0 {
                    newPoint=false
                } else if clickedList[clickedList.count-1].type<0 {
                    newPoint=true
                    linkedList.append(PointOnLine(ancestor: [clickedList[clickedList.count-1]], point: location, number: linkedList.count))
                    clickedList.remove(at: 1)
                    clickedIndex.remove(at: 1)
                    setActiveConstruct(linkedList.count-1)
                } else {
                    newPoint=true
                    linkedList.append(PointOnCircle(ancestor: [clickedList[clickedList.count-1]], point: location, number: linkedList.count))
                    clickedList.remove(at: 1)
                    clickedIndex.remove(at: 1)
                    setActiveConstruct(linkedList.count-1)
                }
            } else {
                newPoint=true
                linkedList.append(Point(ancestor: [], point: location, number: linkedList.count))
                setActiveConstruct(linkedList.count-1)
            }
            var alreadyExists=false
            for i in 0..<linkedList.count {
                if linkedList[i].type==CIRCLE {
                    if linkedList[i].parent[0].index==clickedList[0].index && linkedList[i].parent[1].index==clickedList[1].index {
                        alreadyExists=true
                        linkedList[i].isShown=true
                    }
                }
            }
            if !alreadyExists {
                linkedList.append(Circle(ancestor: clickedList, point: location, number: linkedList.count))
            }
            clearAllPotentials()
            clearActives()
            break
        case makeSegments, makeLines, makeRays, makeCircles, makeMidpoint:
            if !firstMove {
                linkedList.removeLast() // remove temporary segment/ray etc.
                clickedList.removeLast()
                clickedIndex.removeLast()
                if newPoint {
                    linkedList.removeLast() // remove temporary point
                    clickedList.removeLast()
                    clickedIndex.removeLast()
                    newPoint=false
                }
            }
            activeConstruct=false
            while clickedList.count>1 {
                clickedList.removeLast()
                clickedIndex.removeLast()
            }
            getPointOrLineOrCircle(location)
            if activeConstruct {
                if clickedList[clickedList.count-1].type>0 {
                    newPoint=false
                } else if clickedList[clickedList.count-1].type<0 {
                    newPoint=true
                    linkedList.append(PointOnLine(ancestor: [clickedList[clickedList.count-1]], point: location, number: linkedList.count))
                    clickedList.remove(at: 1)
                    clickedIndex.remove(at: 1)
                    setActiveConstruct(linkedList.count-1)
                } else {
                    newPoint=true
                    linkedList.append(PointOnCircle(ancestor: [clickedList[clickedList.count-1]], point: location, number: linkedList.count))
                    clickedList.remove(at: 1)
                    clickedIndex.remove(at: 1)
                    setActiveConstruct(linkedList.count-1)
                }
            } else {
                newPoint=true
                linkedList.append(Point(ancestor: [], point: location, number: linkedList.count))
                setActiveConstruct(linkedList.count-1)
            }
            arrangeClickedObjectsByIndex()
            var alreadyExists=false
            for i in 0..<linkedList.count {
                if (linkedList[i].type==LINE && whatToDo==makeLines) || (linkedList[i].type==SEGMENT && whatToDo==makeSegments) || (linkedList[i].type==RAY && whatToDo==makeRays) || (linkedList[i].type==MIDPOINT && whatToDo==makeMidpoint) {
                    if linkedList[i].parent[0].index==clickedList[0].index && linkedList[i].parent[1].index==clickedList[1].index {
                        alreadyExists=true
                        linkedList[i].isShown=true
                    }
                }
            }
            if !alreadyExists {
                switch whatToDo {
                case makeSegments: linkedList.append(Segment(ancestor: clickedList, point: location, number: linkedList.count))
                    break
                case makeRays: linkedList.append(Ray(ancestor: clickedList, point: location, number: linkedList.count))
                    break
                case makeLines: linkedList.append(Line(ancestor: clickedList, point: location, number: linkedList.count))
                    break
                default: linkedList.append(MidPoint(ancestor: clickedList, point: location, number: linkedList.count))
                }
            }
            clearAllPotentials()
            clearActives()
            break
        case makeBisectors:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
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
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? FoldedPoint {
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
                    linkedList.append(FoldedPoint(ancestor: clickedList, point: location, number: linkedList.count))
                    clearAllPotentials()
                }
            }
            break
        case invertPoints:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? InvertedPoint {
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
                    linkedList.append(InvertedPoint(ancestor: clickedList, point: location, number: linkedList.count))
                    clearAllPotentials()
                }
            }
            break
        case makePerps:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? PerpLine {
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
                    linkedList.append(PerpLine(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    clearAllPotentials()
                }
            }
            break
        case makeParallels:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? ParallelLine {
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
                    linkedList.append(ParallelLine(ancestor: clickedList, point: location, number: linkedList.count))
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
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
                    if linkedList[i].type<0 && !alreadyExists {
                        if let temp=linkedList[i] as? ThreePointLine {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index && temp.parent[2].index == clickedList[2].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                linkedList[i+2].isShown=true
                                clearAllPotentials()
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
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==4 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Tool6Point0 {
                        if !alreadyExists {
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
                        //update(object: linkedList[linkedList.count-1],point: location)
                        clickedList.append(linkedList[linkedList.count-1])
                                        // used this for getting CIC0 in there to pass information to CIC1
                        linkedList.append(CircIntCirc1(ancestor: clickedList, point: location, number: linkedList.count))
                        //update(object: linkedList[linkedList.count-1],point: location)
                        clearAllPotentials()
                    } else {                                                        // one line, one circle
                        if clickedList[0].type==0 {                 // make sure line is [0], circle is [1]
                            clickedList.append(clickedList[0])
                            clickedList.removeFirst()
                        }
                        linkedList.append(LineIntCirc0(ancestor: clickedList, point: location, number: linkedList.count))
                        //update(object: linkedList[linkedList.count-1],point: location)
                        clickedList.append(linkedList[linkedList.count-1])
                                        // used this for getting LIC0 in there to pass information to LIC1
                        linkedList.append(LineIntCirc1(ancestor: clickedList, point: location, number: linkedList.count))
                        //update(object: linkedList[linkedList.count-1],point: location)
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
                    if unitChosen {
                        clickedList.append(linkedList[unitIndex])
                    } else {
                        unitChosen=true
                        unitIndex=linkedList.count
                    }
                    linkedList.append(Distance(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    numberOfMeasures+=1
                    clearAllPotentials()
                }
            }
            break
        case measureAngle:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==3 {                               // 
//                if clickedList[0].index>clickedList[2].index {    // this code would be used
//                    clickedList.insert(clickedList[0], at: 2)     // if we measured angles
//                    clickedList.insert(clickedList[3], at: 1)     // without handedness, i.e.
//                    clickedList.removeFirst()                     // only positive measures.
//                    clickedList.removeLast()                      //
//                }                                                 //
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Angle {
                        if !alreadyExists {
                            if temp.parent[1].index == clickedList[1].index && temp.parent[0].index == clickedList[0].index && temp.parent[2].index == clickedList[2].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    linkedList.append(Angle(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    numberOfMeasures+=1
                    clearAllPotentials()
                }
            }
            break
        case measureSum:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Sum {
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
                    linkedList.append(Sum(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    numberOfMeasures+=1
                    clearAllPotentials()
                }
            }
            break
        case measureProduct:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Product {
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
                    linkedList.append(Product(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    numberOfMeasures+=1
                    clearAllPotentials()
                }
            }
            break
        case measureDifference:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Difference {
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
                    linkedList.append(Difference(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    numberOfMeasures+=1
                    clearAllPotentials()
                }
            }
            break
        case measureRatio:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Ratio {
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
                    linkedList.append(Ratio(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    numberOfMeasures+=1
                    clearAllPotentials()
                }
            }
            break
        case measureSine, measureCosine:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==1 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Measure {
                        if !alreadyExists {
                            if temp.parent[0].index == clickedList[0].index && temp.type == whatToDo {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    switch(whatToDo) {
                    case measureSine:
                        linkedList.append(Sine(ancestor: clickedList, point: location, number: linkedList.count))
                        break
                    case measureCosine:
                        linkedList.append(Cosine(ancestor: clickedList, point: location, number: linkedList.count))
                        break
                    default:
                        print("measure (co)sine default reached")
                    }
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    numberOfMeasures+=1
                    clearAllPotentials()
                }
            }
            break
        case measureTriArea:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==3 {
                arrangeClickedObjectsByIndex()
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Triangle {
                        if !alreadyExists {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index && temp.parent[2].index == clickedList[2].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    if !unitChosen { // if no unit length, create one
                        unitChosen=true
                        unitIndex=linkedList.count
                        linkedList.append(Distance(ancestor: [clickedList[0],clickedList[1]], point: location, number: linkedList.count))
                        update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                        numberOfMeasures+=1
                    }
                    clickedList.append(linkedList[unitIndex])
                    linkedList.append(Triangle(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    clearAllPotentials()
                    numberOfMeasures+=1
                }
            }
            break
        case measureCircArea:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==1 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? CircleArea {
                        if !alreadyExists {
                            if temp.parent[0].index == clickedList[0].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
                            }
                        }
                    }
                }
                if !alreadyExists {
                    if !unitChosen { // if no unit length, create one
                        unitChosen=true
                        unitIndex=linkedList.count
                        if clickedList[0].parent[0].index<clickedList[0].parent[1].index {
                            linkedList.append(Distance(ancestor: [clickedList[0].parent[0],clickedList[0].parent[1]], point: location, number: linkedList.count))
                        } else {
                            linkedList.append(Distance(ancestor: [clickedList[0].parent[1],clickedList[0].parent[0]], point: location, number: linkedList.count))
                        }
                        clickedList[0].parent[0].isShown=true
                        clickedList[0].parent[1].isShown=true
                        update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                        numberOfMeasures+=1
                    }
                    clickedList.append(linkedList[unitIndex])
                    linkedList.append(CircleArea(ancestor: clickedList, point: location, number: linkedList.count))
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x: 12,y: 20*numberOfMeasures))
                    clearAllPotentials()
                    numberOfMeasures+=1
                }
            }
            break
        case hideObject:
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==1 {
                linkedList[clickedIndex[0]].isShown=false
                clearAllPotentials()
            }
            break
        case toggleLabel:
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==1 {
                linkedList[clickedIndex[0]].showLabel = !linkedList[clickedIndex[0]].showLabel
                clearAllPotentials()
            }
            break
        case translateAll:
            break
        default:
            print("touchesEnded: \(location)")
        }
        for object in linkedList {
            update(object: object, point: object.coordinates)
        }
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
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
            return 1024
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
    func getMeasure(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown && linkedList[i].isReal {
                if linkedList[i].type>=DISTANCE {
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
    func getPointOrLineOrCircle(_ location: CGPoint) {
        getPoint(location)
        if !activeConstruct {
            getLineOrCircle(location)
        }
    }
    func getRidOfActivesThatAreTooFar(_ location: CGPoint) {
        if activeConstruct {
            if let temp = potentialClick as? Point {
                if distance(temp,location)>touchSense {
                    clearLastPotential()
                }
            } else if let temp = potentialClick as? Line {
                if distance(temp,location)>touchSense {
                    clearLastPotential()
                }
            } else if let temp = potentialClick as? Circle {
                if distance(temp,location)>touchSense {
                    clearLastPotential()
                }
            }
        }
    }
    func arrangeClickedObjectsByIndex() {
        if clickedIndex[0]>clickedIndex[1] {
            clickedList.insert(clickedList[0], at: 2)
            clickedList.removeFirst()
            clickedIndex.insert(clickedIndex[0],at: 2)
            clickedIndex.removeFirst()
        }
        if clickedList.count>=3 {
            if clickedIndex[0]>clickedIndex[2] {
                clickedList.insert(clickedList[0], at: 2)
                clickedList.insert(clickedList[3], at: 1)
                clickedList.removeFirst()
                clickedList.removeLast()
                clickedIndex.insert(clickedIndex[0], at: 2)
                clickedIndex.insert(clickedIndex[3], at: 1)
                clickedIndex.removeFirst()
                clickedIndex.removeLast()
            }
            if clickedIndex[1]>clickedIndex[2] {
                clickedList.append(clickedList[1])
                clickedList.remove(at:1)
                clickedIndex.append(clickedIndex[1])
                clickedIndex.remove(at: 1)
            }
        }
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
            temp.update(point: point)
        } else if let temp = object as? Angle {
            temp.update(point: point)
        } else if let temp = object as? Ratio {
            temp.update(point: point)
        } else if let temp = object as? Product {
            temp.update(point: point)
        } else if let temp = object as? Sum {
            temp.update(point: point)
        } else if let temp = object as? Difference {
            temp.update(point: point)
        } else if let temp = object as? Sine {
            temp.update(point: point)
        } else if let temp = object as? Cosine {
            temp.update(point: point)
        } else if let temp = object as? CircleArea {
            temp.update(point: point)
        } else if let temp = object as? Distance {
            temp.update(point: point)
        } else if let temp = object as? Triangle {
            temp.update(point: point)
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
            self.infoXLabel.text = self.actionText[self.whatToDo]
            
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
            self.infoXLabel.text = self.measureText[self.whatToDo-20]
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
      }
    @IBAction func clearLastButtonPressed() {
        if linkedList.count>0 {
            if linkedList.count-1 == unitIndex {
                unitChosen=false
                unitIndex=0
            }
            if linkedList[linkedList.count-1].type>=DISTANCE {
                numberOfMeasures-=1
            }
            if linkedList.count>1 {
                if linkedList[linkedList.count-2].type==THREEptCIRCLEcntr || linkedList[linkedList.count-1].type==BISECTOR1 {
                    linkedList.removeLast()
                    linkedList.removeLast()         // since there were three created at once
                }
                if linkedList[linkedList.count-1].type==CIRCintCIRC1 || linkedList[linkedList.count-1].type==LINEintCIRC1 {
                    linkedList.removeLast()         // since there were two created at once
                }
                if linkedList[linkedList.count-1].type==TOOL6LINE2 {
                    linkedList.removeLast()
                    linkedList.removeLast()         // since there were six created at once
                    linkedList.removeLast()
                    linkedList.removeLast()
                    linkedList.removeLast()
                }
            }
                linkedList.removeLast()
            clearAllPotentials()
            canvas.update(constructions: linkedList, indices: clickedIndex)
            canvas.setNeedsDisplay()
            if linkedList.count<2 {
                self.whatToDo=self.makePoints
                self.infoLabel.text = self.actionText[self.whatToDo]
                self.infoXLabel.text = self.actionText[self.whatToDo]
            }
        }
    }
    @IBAction func clearAllButtonPressed(_ sender: UIButton) {
        numberOfMeasures=1
        unitChosen=false
        self.linkedList.removeAll()
        self.whatToDo=self.makePoints
        self.infoLabel.text = self.actionText[self.whatToDo]
        self.infoXLabel.text = self.actionText[self.whatToDo]
        clearAllPotentials()
        canvas.update(constructions: linkedList, indices: clickedIndex)
        canvas.setNeedsDisplay()
    }
}
