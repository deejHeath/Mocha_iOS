import UIKit

class MainViewController: UIViewController {
    

    @IBOutlet weak var infoLabel: UILabel!
    var potentialClick: Construction?
    var linkedList: [Construction] = []
    let canvas = Canvas()
    var clickedList: [Construction] = []
    var futureList: [Construction] = []
    var clickedIndex: [Int] = []
    let actionText=["Draw or move POINTS.", "Draw line on two POINTS.", "Draw segment on two POINTS.","Draw ray on two POINTS.","Draw circle with center POINT and POINT on."]
    let measureText=["Measure the distance between POINTS."]
    let makePoints=0, makeLines=1, makeSegments=2, makeRays=3, makeCircles=4
    let measureDistance=10
    let POINT = 1, PTonLINE0 = 2, IntPT = 3, PTonLINE = 4
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
        canvas.isMultipleTouchEnabled = false // if we want to add dilation functionality thiw will need to be true
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
                    // append line on CIRCLE
                }
            }
            break
        case makeLines,measureDistance,makeCircles:
            getPoint(location)
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
                        // its a point on circle
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
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if !activeConstruct {
                getPoint(location)
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
                    update(object: clickedList[0], point: location)
                } else if clickedList[0].type<0 {
                    let temp = PointOnLine(ancestor: clickedList, point: location, number: linkedList.count)
                    update(object: temp, point: location)
                    linkedList.removeLast()
                    linkedList.append(temp)
                } else if clickedList[0].type==0 {
                    // append point on Circle
                }
            } else {
                linkedList.append(Point(point: location, number: linkedList.count))
            }
            clearAllPotentials()
            break
        case makeLines:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==2 {
                if clickedIndex[0]==clickedIndex[1] {
                    clearLastPotential()
                }
            }
            if clickedList.count==2 {
                if clickedIndex[0]>clickedIndex[1] {
                    let temp=clickedList[0]
                    clickedList.removeFirst()
                    clickedList.append(temp)
                }
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==LINE {
                        if let temp=linkedList[i] as? Line {
                            if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                                alreadyExists=true
                                linkedList[i].isShown=true
                                clearAllPotentials()
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
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==2 {
                if clickedIndex[0]==clickedIndex[1] {
                    clearLastPotential()
                }
            }
            if clickedList.count==2 {
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if linkedList[i].type==CIRCLE {
                        if let temp=linkedList[i] as? Circle {
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
                    linkedList[linkedList.count-1].update(width: canvas.frame.width)
                    clearAllPotentials()
                }
            }
            break
        case measureDistance:
            if activeConstruct {
                if let temp = potentialClick as? Point {
                    if distance(temp,location)>touchSense {
                        clearLastPotential()
                    }
                }
            }
            if activeConstruct {
                potentialClick=nil
                activeConstruct=false
            }
            if clickedList.count==2 {
                if clickedIndex[0]==clickedIndex[1] {
                    clearLastPotential()
                }
            }
            if clickedList.count==2 {
                if clickedIndex[0]>clickedIndex[1] {
                    let temp=clickedList[0]
                    clickedList.removeFirst()
                    clickedList.append(temp)
                }
                var alreadyExists=false
                for i in 0..<linkedList.count {
                    if let temp=linkedList[i] as? Distance {
                        if temp.parent[0].index == clickedList[0].index && temp.parent[1].index == clickedList[1].index {
                            alreadyExists=true
                            linkedList[i].isShown=true
                            clearAllPotentials()
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
        } else {
            return 1000.0
        }
    }
    func getPointOrMeasure(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown && linkedList[i].isReal {
                if linkedList[i].type>0 && linkedList[i].type<DISTANCE {
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
                if linkedList[i].type<=0 {
                    setActiveConstruct(i)
                }
            }
        }
    }
    
    func clearLastPotential() {
        activeConstruct=false
        potentialClick=nil
        clickedList.removeLast()
        clickedIndex.removeLast()
    }
    
    func clearAllPotentials() {
        activeConstruct=false
        potentialClick=nil
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
        } else if let temp = object as? Point {
            temp.update(point: point)
        } else if let temp = object as? Line {
            temp.update()
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let actionController = storyboard.instantiateViewController(withIdentifier: "action_VC") as! ActionViewController
        actionController.view.backgroundColor = .clear
        //settingsController.modalPresentationStyle = .fullScreen
        actionController.completionHandler = {tag in
            self.whatToDo=tag
            self.infoLabel.text = self.actionText[self.whatToDo]
        }
        self.present(actionController, animated: true, completion: nil)
        clearAllPotentials()
    }
    @IBAction func measureButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let measureController = storyboard.instantiateViewController(withIdentifier: "measure_VC") as! MeasureViewController
        measureController.view.backgroundColor = .clear
        //settingsController.modalPresentationStyle = .fullScreen
        measureController.completionHandler = {tag in
            self.whatToDo=tag
            self.infoLabel.text = self.measureText[self.whatToDo-10]
        }
        self.present(measureController, animated: true, completion: nil)
        clearAllPotentials()
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
