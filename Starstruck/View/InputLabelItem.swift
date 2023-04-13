//
//  InputLabelItem.swift
//  Starstruck
//
//  Created by Arhan Busam on 16/3/2023.
//

import UIKit
import InputBarAccessoryView
import QuartzCore

class InputLabelItem: UILabel, InputItem {
    init(text: String, backgroundColor: CGColor, frame: CGRect) {
        super.init(frame: frame)
        self.text = text
        self.layer.backgroundColor = backgroundColor
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var inputBarAccessoryView: InputBarAccessoryView?
    
    var parentStackViewPosition: InputStackView.Position?
    
    func textViewDidChangeAction(with textView: InputTextView) {}
    
    func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) {}
    
    func keyboardEditingEndsAction() {}
    
    func keyboardEditingBeginsAction() {}
}
