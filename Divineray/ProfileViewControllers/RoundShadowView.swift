//
//  RoundShadowView.swift
//  Divineray
//
//  Created by Aravind Kumar on 24/07/20.
//  Copyright © 2020 Dharmani Apps. All rights reserved.
//

import UIKit

class RoundShadowView: UIView {
  
    let containerView = UIView()
  
    override init(frame: CGRect) {
        super.init(frame: frame)

        layoutView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutView()

    }

    func layoutView() {
      
      // set the shadow of the view's layer
      layer.backgroundColor = UIColor.clear.cgColor
      layer.shadowColor = UIColor.black.cgColor
      layer.shadowOffset = CGSize(width: 0, height: 1.0)
      layer.shadowOpacity = 0.2
      layer.shadowRadius = 4.0
        
      // set the cornerRadius of the containerView's layer
        containerView.layer.cornerRadius = 6.0
      containerView.layer.masksToBounds = true
      
      addSubview(containerView)
      
      //
      // add additional views to the containerView here
      //
      
      // add constraints
      containerView.translatesAutoresizingMaskIntoConstraints = false
      
      // pin the containerView to the edges to the view
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
      containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
