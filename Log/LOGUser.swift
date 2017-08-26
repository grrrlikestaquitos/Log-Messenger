//
//  User.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import UIKit


class LOGUser {
    
    private var handle: String?;
    private var email: String?;
    private var firstName: String?;
    private var lastName: String?;
    private var picture: UIImage?;

    init(handle: String?, email: String?, firstName: String?, lastName: String?, picture: UIImage?) {
        guard let _ = handle else {
            //No handle was passed
            return;
        }
        guard let _ = email else {
            //No email was passed
            return;
        }
        guard let _ = firstName else {
            //No first name was passed
            return;
        }
        guard let _ = lastName else {
            //No last name was passed
            return;
        }
        
        self.handle = handle;
        self.email = email;
        self.firstName = firstName;
        self.lastName = lastName;
        self.picture = picture;
    }
    
    func getHandle() -> String? {
        return self.handle;
    }
    
    func getEmail() -> String? {
        return self.email;
    }
    
    func getFullName() -> String? {
        return "\(self.firstName!) \(self.lastName!)";
    }
    
    func getPicture() -> UIImage? {
        return self.picture;
    }
    
}
    
