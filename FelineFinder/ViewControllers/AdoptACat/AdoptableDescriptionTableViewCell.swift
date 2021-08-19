//
//  AdoptDescriptionTableViewCell.swift
//  FelineFinder
//
//  Created by Gregory Williams on 1/3/21.
//

import UIKit
import WebKit
import SafariServices
import MessageUI

var webViewHeight:CGFloat = 0 // WKWEbview height

class AdoptableDescriptionTableViewCell: UITableViewCell, WKNavigationDelegate, UIScrollViewDelegate {
    @IBOutlet weak var descriptionWK: WKWebView!
    
    var pet: Pet!
    var shelter: shelter!
    var isWebViewAdded:Bool = false
    
    func setup(pet: Pet, shelter: shelter) {
        self.pet = pet
        self.shelter = shelter
        let path = Bundle.main.bundlePath;
        let sBaseURL = URL(fileURLWithPath: path);
        
        descriptionWK.scrollView.isScrollEnabled = true
        descriptionWK.scrollView.bounces = false
        //descriptionWK.isUserInteractionEnabled = true
        //descriptionWK.contentMode = .scaleToFill
        descriptionWK.navigationDelegate = self
        
        descriptionWK.scrollView.isScrollEnabled = true
        descriptionWK.scrollView.bounces = false
        descriptionWK.allowsBackForwardNavigationGestures = false
        descriptionWK.contentMode = .scaleAspectFit
//  Set the WKWebView scroll view delegate
        descriptionWK.scrollView.delegate = self
        
        selectionStyle = .none
        
        descriptionWK.loadHTMLString(generatePetDescription(pet: pet, shelter: shelter), baseURL: sBaseURL)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self
    }
    
    private func sendEmail(address: String?) {
        guard let vc = findViewController() as? AdoptableCatsDetailViewController else {return}
        if MFMailComposeViewController.canSendMail() {
            let email = MFMailComposeViewController()
            email.mailComposeDelegate = vc
            email.setSubject("Requesting Adoption Information For \(pet.name)")
            email.setToRecipients([address ?? self.shelter.email])
            vc.present(email, animated: true)
        } else {
            // show failure alert
            let alertController = UIAlertController(title: "No email account",
                                                    message: "Please configure email account first.",
                                                    preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil)
            alertController.addAction(actionOk)
            vc.present(alertController, animated: true, completion: nil)
        }
    }
        
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else {
                print("Link is not a url")
                decisionHandler(.allow)
                return
            }
            if url.absoluteString.hasPrefix("file:") {
                print("Open link locally")
                decisionHandler(.allow)
            } else if let url = navigationAction.request.url, let _ = navigationAction.request.url?.host, let vc = findViewController(), UIApplication.shared.canOpenURL(url) {
                    decisionHandler(.cancel)
                    let safariViewController = SFSafariViewController(url: url)
                    vc.present(safariViewController, animated: true, completion: nil)
                    return
            } else if url.absoluteString.hasPrefix("mailto:") {
                print("Send email locally")
                sendEmail(address: url.absoluteString.chopPrefix("mailto:".count))
                decisionHandler(.allow)
            } else if url.absoluteString.hasPrefix("tel:") {
                let actionSheetController: UIAlertController = UIAlertController(title: "Call \(shelter!.name)?", message: "Do you want to call \(shelter!.name) at \(shelter!.phone) now?", preferredStyle: .actionSheet)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                    //Just dismiss the action sheet
                }
                actionSheetController.addAction(cancelAction)
                //Create and add first option action
                let callAction: UIAlertAction = UIAlertAction(title: "Call", style: .default) { action -> Void in
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                actionSheetController.addAction(callAction)
                               
                //Present the AlertController
                self.findViewController()!.present(actionSheetController, animated: true, completion: nil)

                decisionHandler(.allow)
            } else {
                print("Open link locally")
                decisionHandler(.allow)
            }
        } else {
            print("not a user click")
            decisionHandler(.allow)
        }
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
        
            htmlString =
                """
                <html>
                <head>
                      <meta name="viewport" content="width=device-width, initial-scale=1.0">
                      <style>
                          @media {
                              body {
                                  font-size: 5px;
                                  max-width: 520px;
                                  margin: 20px auto;
                              }
                              h1 {color: black;
                                  FONT-FAMILY:Arial,Helvetica,sans-serif;
                                  font-size: 18px;
                              }
                              h2 {color: blue;
                                  FONT-FAMILY:Arial,Helvetica,sans-serif;
                                  font-size: 18px;
                              }
                              h3 {color: blue;
                                  FONT-FAMILY:Arial,Helvetica,sans-serif;
                                  font-size: 18px;}
                              h4 {color: black;
                                  FONT-FAMILY:Arial,Helvetica,sans-serif;
                                  font-size: 12px;}
                              a { color: blue}
                              a.visited {color: grey;}
                          }
                      </style>
                </head>
                <body>
                    <center>
                        <table>
                            <tr>
                                <td width="100%">
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <center>
                                                    <b>
                                                        <h2><b>GENERAL INFORMATION</h2>
                                                    </b>
                                                </center>
                                            </td>
                                        </tr>
                                    </table>
                                    <h1>
                                        \(options)\(o)
                                    </h1>
                                    </br>
                                    <table>
                                        <tr>
                                            <td>
                                                <center>
                                                    <h2>CONTACT</h2>
                                                </center>
                                                <h1>
                                                    \(shelter.name)
                                                    </br>
                                                    \(shelter.address1)
                                                    </br>
                                                    \(c), \(shelter.state) \(shelter.zipCode)
                                                </h1>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <h2>
                                                    <center>
                                                        DESCRIPTION
                                                    </center>
                                                </h2>
                                                <h1>
                                                    <p style=\"word-wrap: break-word;\">
                                                        \(pet.descriptionHtml)
                                                    </p>
                                                </h1>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <h2>
                                                    <center>DISCLAIMER</center>
                                                </h2>
                                                <h4>PLEASE READ: Information regarding adoptable pets is provided by the adoption organization and is neither checked for accuracy or completeness nor guaranteed to be accurate or complete.  The health or status and behavior of any pet found, adopted through, or listed on the Feline Finder app are the sole responsibility of the adoption organization listing the same and/or the adopting party, and by using this service, the adopting party releases Feline Finder and Gregory Edward Williams, from any and all liability arising out of or in any way connected with the adoption of a pet listed on the Feline Finder app.
                                                </h4>
                                            </td>
                                        </tr>
                                    </table>
                                </center>
                            </body>
                    </html>
                """
                //"<!DOCTYPE html><html><header><style>li {margin-top: 30px;border:1px solid grey;} li:first-child {margin-top:0;} h1 {color: black; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:40px;} h2 {color: blue; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:40px;} h3 {color: blue; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:28px;} h4 {color: black; FONT-FAMILY:Arial,Helvetica,sans-serif; FONT-SIZE:20px;} a { color: blue} a.visited {color: grey;} </style></header><body><center><table width=\"\(self.tableWidth())\"><tr><td width=\"100%\"><table width=\"100%\"><tr><td><center><b><h2>GENERAL INFORMATION</b></h3></center><h2></td></tr></table><h1>\(options)\(o)</br></h1><table><tr><td><center><h2>CONTACT</h2></center><h1>\(shelter.name)</br>\(shelter.address1)</br>\(c), \(shelter.state) \(shelter.zipCode)</h1></td></tr><tr><td><h2><center>DESCRIPTION</center></h2><div style='overflow-y:visible; overflow-x:scroll; width:\(self.width())'><h1><p style=\"word-wrap: break-word;\">\(pet.descriptionHtml)</p></h1></div></td></tr><tr><td></td></tr><tr><td><h2><center>DISCLAIMER</center></h2><h4>PLEASE READ: Information regarding adoptable pets is provided by the adoption organization and is neither checked for accuracy or completeness nor guaranteed to be accurate or complete.  The health or status and behavior of any pet found, adopted through, or listed on the Feline Finder app are the sole responsibility of the adoption organization listing the same and/or the adopting party, and by using this service, the adopting party releases Feline Finder and Gregory Edward Williams, from any and all liability arising out of or in any way connected with the adoption of a pet listed on the Feline Finder app.</h4></td></tr></table></center></body></html>"
        return htmlString
    }
    
    func width() -> String {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "900px"
        } else {
            return "640px"
        }
    }
    
    func tableWidth() -> Int {
        var tableWidth = 0
        
        if ( UIDevice.current.model.range(of: "iPad") != nil){
            tableWidth = 900 //360
        } else {
            tableWidth = 700
        }

        return tableWidth
    }
}
