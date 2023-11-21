//
//  NoDataLabel.swift
//  ipad_quote_tool
//
//  Created by SIGMA.
//

import UIKit

// This is custom NoDataLabel class which is a subclass of UILabel and intend to show a static message when something is not avilable.

class NoDataLabel: UILabel {
    
    convenience init(bounds: CGRect, title: String) {
		self.init()
        self.frame = bounds
        self.frame.origin.x = 10
        self.frame.size.width = self.frame.size.width - 20
        numberOfLines = 2
		text = title
        
        self.adjustsFontSizeToFitWidth = true
		textAlignment = .center
        textColor = UIColor.black
	}
}
