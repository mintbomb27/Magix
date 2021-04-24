//
//  customPhoneTextField.swift
//  Magix
//
//  Created by Alok N on 24/04/21.
//

import UIKit
import PhoneNumberKit

class customPhoneTextField: PhoneNumberTextField {
    
    override var defaultRegion: String{
        get {
            return "IN"
        }
        set {}
    }
    
}
