//
//  NavButton.swift
//  BuildAR
//
//  Created by Deon Lee on 18/6/19.
//  Copyright © 2019 Tay Jin Wen. All rights reserved.
//

import UIKit

class NavButtonCustom: UIButton {
    
    override func didMoveToWindow() {
        self.backgroundColor = UIColor.darkGray
        self.layer.cornerRadius = self.frame.height / 2
        //self.setTitleColor(UIColor.white, for: .normal)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.7
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
