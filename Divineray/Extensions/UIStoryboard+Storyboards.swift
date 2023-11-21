//
//  UIStoryboard+Storyboards.swift
import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIStoryboard {
    
    enum Storyboard: String {
        case main
        case signup
        case sharedBoard
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    // MARK: - Convenience Initializers
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }
    
    // MARK: - Class Functions
    class func storyboard(_ storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.filename, bundle: bundle)
    }
    
    // MARK: - View Controller Instantiation from Generics
    func instantiateViewController<T: UIViewController>() -> T where T: StoryboardIdentifiable {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        
        return viewController
    }
}

/*
 class ViewController: UIViewController, SegueHandlerType {
 
 enum SegueIdentifier: String {
 case TheRedPillExperience
 case TheBluePillExperience
 }
 
 override func viewDidLoad() {
 super.viewDidLoad()
 }
 
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
 switch segueIdentifierForSegue(segue) {
 
 case .TheRedPillExperience:
 let redPillVC = segue.destination as? RedPillViewController
 redPillVC?.inject("😈")
 case .TheBluePillExperience:
 let bluePillVC = segue.destination as? BluePillViewController
 bluePillVC?.inject("👼")
 }
 }
 
 @IBAction func onRedPillButtonTap(_ sender: AnyObject) {
 performSegueWithIdentifier(.TheRedPillExperience, sender: self)
 }
 
 @IBAction func onBluePillButtonTap(_ sender: AnyObject) {
 performSegueWithIdentifier(.TheBluePillExperience, sender: self)
 }
 }
 
 
 */
