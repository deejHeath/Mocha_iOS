import UIKit

class MainViewController: UIViewController {
    

    @IBOutlet weak var infoLabel: UILabel!
    var potentialClick: Construction?
    var linkedList: [Construction] = []
    let canvas = Canvas()
    var clickedList: [Construction] = []
    var futureList: [Construction] = []
    var clickedIndex: [Int] = []
    let labelText=["Draw or move POINTS.", "Draw line on two POINTS.", "Draw segment on two POINTS.","Draw ray on two POINTS."]
    let makePoints=0, makeLines=1, makeSegments=2, makeRays=3, makeCircles=4
    let POINT = 1, PTonLINE0 = 2, IntPT = 3
    let CIRCLE = 0
    let LINE = -1, SEGMENT = -2, RAY = -3
    private var whatToDo=0
    var firstTouch: CGPoint?
    var activeConstruct = false
    let touchSense=16.0
    
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
        switch whatToDo {
        case makePoints:
            getPoint(location)
            if !activeConstruct {
                linkedList.append(Point(ancestor: [], point: location, number: linkedList.count))
                setActiveConstruct(linkedList.count-1)
            }
            break
        case makeLines:
            getPoint(location)
            if !activeConstruct {
                potentialClick=nil
            }
            break
        default:
            print("tB default")
        }
        canvas.update(constructions: linkedList)
        canvas.setNeedsDisplay()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: canvas)
        switch whatToDo {
        case makePoints:
            if activeConstruct {
                if clickedList[0].type>0                             {  // if the clickedList is
                    clickedList[0].update(point: location)              // moveable, move it about.
                    print("tM: \(clickedList[0].coordinates)")
                }
            }
            break
        case makeLines:
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
            print("tM: \(location)")
        }
        canvas.update(constructions: linkedList)
        canvas.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: canvas)
        switch whatToDo {
        case makePoints:
            if activeConstruct {
                if clickedList[0].type>0                             {  // if the clickedList is
                    clickedList[0].update(point: location)              // moveable, move it about.
                    print("tM: \(clickedList[0].coordinates)")
                }
            }
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
                    clearAllPotentials()
                }
            }
            break
        default:
            print("tE: \(location)")
        }
        clearAllPotentials()
        canvas.update(constructions: linkedList)
        canvas.setNeedsDisplay()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        let touch=touches.first!
        let location=touch.location(in: canvas)
        print("tC: \(location)")
        clearAllPotentials()
        canvas.update(constructions: linkedList)
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
    
    func getPoint(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown {
                setActiveConstruct(i)
            }
        }
    }
    func getLineOrCircle(_ location: CGPoint) {
        for i in 0..<linkedList.count {
            if distance(linkedList[i],location)<touchSense && !clickedIndex.contains(i) && !activeConstruct && linkedList[i].isShown {
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
        if let temp = object as? Point {
            temp.update(point: point)
        } else if let temp = object as? Line {
            temp.update()
        }
    }
    
    func drawConstructs() {
        // some method to clear the canvas
        for i in 0..<linkedList.count {
            if linkedList[i].isReal && linkedList[i].isShown {
                if clickedIndex.contains(i) {
                    linkedList[i].draw(canvas,true)
                } else {
                    linkedList[i].draw(canvas,false)
                }
            }
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        print("action pressed")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let actionController = storyboard.instantiateViewController(withIdentifier: "action_VC") as! ActionViewController
        actionController.view.backgroundColor = .clear
        //settingsController.modalPresentationStyle = .fullScreen
        actionController.completionHandler = {tag in
            self.whatToDo=tag
            self.infoLabel.text = self.labelText[self.whatToDo]
        }
        self.present(actionController, animated: true, completion: nil)
        clearAllPotentials()
        drawConstructs()
    }
    @IBAction func measureButtonPressed() {
        print("measure pressed")
    }
    @IBAction func shareButtonPressed() {
        print("share pressed")
    }
    @IBAction func clearLastButtonPressed() {
        print("clear last pressed")
    }
    @IBAction func clearAllButtonPressed(_ sender: UIButton) {
        print("clear all pressed")
        self.linkedList.removeAll()
        self.whatToDo=self.makePoints
        clearAllPotentials()
        canvas.update(constructions: linkedList)
        canvas.setNeedsDisplay()
    }
}
