/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import UserNotifications

var queryID: String = ""

final class NotificationDelegate: NSObject,
                                  UNUserNotificationCenterDelegate,
                                  AdoptionDelegate {
    
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "AdoptList") as! AdoptableCatsCollectionViewViewController
    vc.delegate = self
    queryID = notification.request.content.userInfo["queryID"] as! String
    vc.modalPresentationStyle = .formSheet
    UIApplication.topViewController()!.present(vc, animated: false, completion: nil)
    if #available(iOS 14.0, *) {
        completionHandler([.banner, .sound, .badge])
    } else {
        completionHandler([.sound, .badge])
    }
  }
    
    func Dismiss(vc: UIViewController) {
        vc.dismiss(animated: false, completion: nil)
    }

    func Download(reset: Bool) {
        DownloadManager.loadOfflineSearch(reset: reset, queryID: queryID)
    }

    func GetTitle(totalRows: Int) -> String {
        return String(totalRows) + " cats found"
    }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void) {
    defer {
        completionHandler()
    }

    guard
      response.actionIdentifier == UNNotificationDefaultActionIdentifier
    else {
      return
    }

    // Perform actions here
    let payload = response.notification.request.content
    queryID = payload.userInfo["queryID"].value as! String
    
    displayResults = true
  }
}
