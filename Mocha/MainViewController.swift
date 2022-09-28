import UIKit

class MainViewController: UIViewController {
    

    @IBOutlet weak var infoLabel: UILabel!
    var potentialClick: Construction?
    var linkedList: [Construction] = []
    let canvas = Canvas()
    var clickedList: [Construction] = []
    var futureList: [Construction] = []
    var clickedIndex: [Int] = []
    let actionText=["Draw or move POINTS.", "Draw line on two POINTS.", "Draw segment on two POINTS.","Draw ray on two POINTS.","Draw circle with center POINT and POINT on.","Find intersections of two CONSTRUCTIONS."]
    let measureText=["Measure the distance between POINTS."]
    let makePoints=0, makeLines=1, makeSegments=2, makeRays=3, makeCircles=4, makeIntersections=5
    let makePerps=6, makeParallel=7, makeMidpoint=8, makeBisector=9
    let measureDistance=20
    let POINT = 1, PTonLINE = 2, PTonCIRCLE=3, MIDPOINT=4, LINEintLINE=5, CIRCintCIRC0=6
    let CIRCintCIRC1=7
    let DISTANCE = 20
    let CIRCLE = 0
    let LINE = -1, SEGMENT = -2, RAY = -3
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
        case makeLines,measureDistance,makeCircles:
            getPoint(location)
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
        case makeLines, measureDistance, makeCircles:
            getRidOfActivesThatAreTooFar(location)
            if !activeConstruct {
                getPoint(location)
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
                    if clickedList[0].type>=DISTANCE {                  // Unit (first distance
                        update(object: clickedList[0], point: location) // measured) has to be
                    }                                                   // updated twice.
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
        case makeIntersections:
            getRidOfActivesThatAreTooFar(location)
            clearActives()
            getRidOfDuplicates()
            if clickedList.count==2 {       // need to construct InterPt0 & InterPt1.
                if clickedList[0].type<0 && clickedList[1].type<0 { // both lines
                    arrangeClickedObjectsByIndex()
                    var alreadyExists=false
                    for i in 0..<linkedList.count {
                        if let temp=linkedList[i] as? LineIntLine {
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
                        linkedList.append(LineIntLine(ancestor: clickedList, point: location, number: linkedList.count))
                        linkedList[linkedList.count-1].update(ancestor: linkedList[linkedList.count-1].parent)
                        clearAllPotentials()
                    }
                } else if clickedList[0].type==0 && clickedList[1].type==0 { // both circles
                    arrangeClickedObjectsByIndex()
                    var alreadyExists=false
                    for i in 0..<linkedList.count {
                        if let temp=linkedList[i] as? CircIntCirc0 {
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
                        linkedList.append(CircIntCirc0(ancestor: clickedList, point: location, number: linkedList.count))
                        update(object: linkedList[linkedList.count-1],point: location)
                        clickedList.append(linkedList[linkedList.count-1])
                        // used this for getting CIC0 in there to pass information to CIC1
                        linkedList.append(CircIntCirc1(ancestor: clickedList, point: location, number: linkedList.count))
                        update(object: linkedList[linkedList.count-1],point: location)
                        clearAllPotentials()
                    }
                } else { // one circle, one line
                    // check whether it already exists, and if not, create LineIntCirc
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
                    update(object: linkedList[linkedList.count-1], point: CGPoint(x:  (linkedList[linkedList.count-1].parent[0].coordinates.x+linkedList[linkedList.count-1].parent[1].coordinates.x)/2,y:  (linkedList[linkedList.count-1].parent[0].coordinates.y+linkedList[linkedList.count-1].parent[1].coordinates.y)/2))
                    clearAllPotentials()
                }
            }
            break
        default:
            print("touchesEnded: \(location)")
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
            let temp=clickedList[0]
            clickedList.removeFirst()
            clickedList.append(temp)
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
        if clickedList.count==2 {
            if clickedIndex[0]==clickedIndex[1] {
                clearLastPotential()
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
        } else if let temp = object as? LineIntLine {
            temp.update()
        } else if let temp = object as? CircIntCirc0 {
            temp.update()
        } else if let temp = object as? CircIntCirc1 {
            temp.update()
        } else if let temp = object as? PointOnCircle {
            temp.update(point: point)
        } else if let temp = object as? Point {
            temp.update(point: point)
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
        print("share pressed")
    }
    @IBAction func clearLastButtonPressed() {
        if linkedList.count-1 == unitIndex {
            unitChosen=false
            unitIndex=0
        }
        if linkedList.count>0 {
            if linkedList[linkedList.count-1].type==CIRCintCIRC1 {
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
