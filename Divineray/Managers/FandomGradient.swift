
import UIKit

// Gradient color direction
public enum Direction {
    case vertical
    case horizontal
}

public class FandomGradient: NSObject {
    public override init() {
        super.init()
    }
    
    public func setGradientColorOnNavigationBar(bar: UINavigationBar, direction: Direction) {
        let image = generateGradientImage(direction: direction, startColor: kGradintStartColor, endColor: kGradintEndColor)
            bar.setBackgroundImage(image, for: .default)
            UINavigationBar.appearance().isTranslucent = false
    }

    private func generateGradientImage(direction: Direction, startColor: UIColor, endColor: UIColor) -> UIImage {
        let gradientLayer = CAGradientLayer()
        let sizeLength = UIScreen.main.bounds.size.height * 2
        let navBarFrame = CGRect(x: 0, y: 0, width: sizeLength, height: 64)
        gradientLayer.frame = navBarFrame
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]

        if direction == .horizontal {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.3, y: 0.5)
        }

        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    static func gradientImage() -> UIImage {
        let gradientLayer = CAGradientLayer()
        let sizeLength = UIScreen.main.bounds.size.height * 2
        let navBarFrame = CGRect(x: 0, y: 0, width: sizeLength, height: 64)
        gradientLayer.frame = navBarFrame
        gradientLayer.colors = [kGradintStartColor.cgColor, kGradintEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.3, y: 0.5)

        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
}



