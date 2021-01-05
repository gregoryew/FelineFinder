//
//  AdoptDescriptionTableViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/3/21.
//

import UIKit
import WebKit

protocol descriptionChanged {
    func heightChanged(heigth: Int)
}

class AdoptableDescriptionTableViewCell: UITableViewCell {
    @IBOutlet var descriptionWK: WKWebView!
    
    var delegate: descriptionChanged!
    
    func setup(pet: Pet, shelter: shelter) {
        let path = Bundle.main.bundlePath;
        let sBaseURL = URL(fileURLWithPath: path);
        descriptionWK.navigationDelegate = self
        descriptionWK.loadHTMLString(generatePetDescription(pet: pet, shelter: shelter), baseURL: sBaseURL)
    }
    
    func generatePetDescription(pet: Pet, shelter: shelter) -> String {
        var htmlString = ""
        var b: String = ""
        for b2 in pet.breeds {
            if (b == "") {
                b = "\(b2)"
            }
            else {
                b = "\(b) & \(b2)"
            }
        }

        var o: String = ""
        for o2 in pet.options {
            if o2 == "" {
                continue
            }
            if (o == "") {
                o = "<IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">&nbsp;\(o2)</br></br>"
            }
            else {
                o = "\(o) <IMG SRC=\"catpaws.png\" width=\"30\" valign=\"middle\">&nbsp;\(o2)</br></br>"
            }
        }

        var html: String = ""
        html = "\(html)<tr><td><b>Address:</b></td></tr>"
        if (shelter.name != "") {
            html = "\(html)<tr><td>\(shelter.name)</td></tr>"
        }
            if (shelter.address1 != "") {
            html = "\(html)<tr><td>\(shelter.address1)</td></tr>"
        }
        if (shelter.address2 != "") {
            html = "\(html)<tr><td>\(shelter.address2)</td></tr>"
        }
        var c: String = ""
        var st: String = ""
        var z: String = ""
        if (shelter.city != "") {
            c = shelter.city
        }
        if (shelter.state != "") {
            st = shelter.state
        }
        if (shelter.zipCode != "") {
            z = shelter.zipCode
        }
        if (z != "" || c != "" || st != "") {
            html = "\(html)<tr><td>\(c), \(st) \(z)</td></tr>"
        }
        html = "\(html)<tr><td><a href=\"launchLocation\">Driving Directions</a></td></tr>"
        html = "\(html)<tr><td>&nbsp;</td></tr><tr><td><b>Contact Info</b></td></tr>"
        if (shelter.email != "") {
            if (shelter.phone != "") {
                html = "\(html)<tr><td>&nbsp;</td></tr>"
            }
            html = "\(html)<tr><td><a href=\"mailto:\(shelter.email)\">E-Mail: \(shelter.email)</a></td></tr>"
        }
        if (shelter.phone != "") {
            if (shelter.email != "") {
                html = "\(html)<tr><td>&nbsp;</td></tr>"
            }
            html = "\(html)<tr><td><a href=\"tel:\(shelter.phone)\">Call: \(shelter.phone)</a></td></tr>"
            html = "\(html)<tr><td>&nbsp;</td></tr>"
        }
        html = "\(html)<tr><td><a href=\"Share\">Share</a></td></tr>"
        
        var headerContent: String = "<tr><td style=\"background-color:#8AC007\">Basics:</td><td>\(b) • \(pet.age) • \(pet.sex) • \(pet.size)</td></tr>"
        headerContent = "\(headerContent)<tr><td style=\"background-color:#8AC007\">Options:</td><td>\(o)</td></tr>"
        
        /*
        var born = ""
        if p.birthdate != "" {
            born = "<h1>Born \(p.birthdate)</h1>"
        }
        */
        
        var options = ""
        if b != "" {
            options += "<span style='color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:30px;'>😺</span>&nbsp;\(b)</br></br>"
        }
        if pet.age != "" {
            options += "<span style='color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:30px;'>😺</span>&nbsp;\(pet.age)</br></br>"
        }
        if pet.sex != "" {
            options += "<span style='color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:30px;'>😺</span>&nbsp;\(pet.sex)</br></br>"
        }
        if pet.size != "" {
            options += "<span style='color: white; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:30px;'>😺</span>&nbsp;\(pet.size)</br></br>"
        }
        
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "MM/dd/yyyy"
        //let d = dateFormatter.string(from: p.lastUpdated)
        
            htmlString = "<!DOCTYPE html><html><header><style> li {margin-top: 30px;border:1px solid grey;} li:first-child {margin-top:0;} h1 {color: black; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:24px;} h2 {color: blue; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:36px;} h3 {color: blue; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:28px;} h4 {color: black; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:20px;} a { color: #66ff33} a.visited, a.hover {color: blue;} </style></header><body><center><table width=\"\(self.tableWidth())\"><tr><td width=\"100%\"><table width=\"100%\"><tr><td><h3><center><b>GENERAL INFORMATION</b></h3></center><h2></td></tr></table><h1>\(options)\(o)</br></h1><table><tr><td><center><h2>CONTACT</h2></center><h1>\(shelter.name)</br>\(shelter.address1)</br>\(c), \(shelter.state) \(shelter.zipCode)</h1></td></tr><tr><td><h2><center>DESCRIPTION</center></h2><div style='overflow-y:visible; overflow-x:scroll; width:\(self.width())'><h1><p style=\"word-wrap: break-word;\">\(pet.descriptionHtml)</p></h1></div></td></tr><tr><td></td></tr><tr><td><h2><center>DISCLAIMER</center></h2><h4>PLEASE READ: Information regarding adoptable pets is provided by the adoption organization and is neither checked for accuracy or completeness nor guaranteed to be accurate or complete.  The health or status and behavior of any pet found, adopted through, or listed on the Feline Finder app are the sole responsibility of the adoption organization listing the same and/or the adopting party, and by using this service, the adopting party releases Feline Finder and Gregory Edward Williams, from any and all liability arising out of or in any way connected with the adoption of a pet listed on the Feline Finder app.</h4></td></tr></table></center></body></html>"
        return htmlString
    }
    
    func width() -> String {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "640px"
        } else {
            return "900px"
        }
    }
    
    func tableWidth() -> Int {
        var tableWidth = 0
        if UIDevice().type == Model.iPhone5 || UIDevice().type == Model.iPhone5C || UIDevice().type == Model.iPhone5S {
            tableWidth = 300
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            tableWidth = 900 //360
        } else {
            tableWidth = 700
        }
        return tableWidth
    }
}

extension AdoptableDescriptionTableViewCell : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
           if complete != nil {
            self.delegate.heightChanged(heigth: Int(webView.scrollView.contentSize.height))
            self.contentView.setNeedsLayout()
           }
        })
    }
}
