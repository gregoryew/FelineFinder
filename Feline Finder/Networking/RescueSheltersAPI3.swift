import Foundation
/*
final class RescueGroupShelterListAPI3: ShelterList {
    private lazy var baseURL: URL = {
        return URL(string: "https://api.rescuegroups.org/http/v2.json")!
    }()
    
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    var isLoading = false
    
    var shelters = [shelter]()
    
    func loadSingleShelterAPI3(_ shelterID: String, completion: @escaping (Result<shelter, DataResponseError>) -> Void) {
        
        if let s = globalShelterCache[shelterID] {
            print("shelter in cache = |\(shelterID)|")
            //Supposed to refresh the PetFinder data every 24 hours
            let hoursSinceCreation = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: s.dateCreated as Date, to: Date(), options: []).hour
            if hoursSinceCreation! < 24 {
                print("returning cached shelter = |\(shelterID)|")
                completion(Result.success(s))
                return
            }
        }

        if (Utilities.isNetworkAvailable() == false) {
            isLoading = false
            return
        }
        
        let json = ["apikey":"0doJkmYU","objectType":"orgs","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":"1", "resultSort": "orgID", "resultOrder": "asc", "filters": [["fieldName": "orgID", "operation": "equals", "criteria": shelterID]], "fields": ["orgID","orgName","orgAddress","orgCity","orgState","orgLocation","orgCountry","orgPhone","orgFax","orgEmail"]]] as [String : Any]

        var urlRequest = URLRequest(url: baseURL)

        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        session.uploadTask(with: urlRequest, from: jsonData, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
            else {
                completion(Result.failure(DataResponseError.network))
                return
            }
            
            guard let decodedResponse = try? JSONDecoder().decode(RescueSheltersAPI2.self, from: data) else {
                    completion(Result.failure(DataResponseError.decoding))
                    return
                }
            
            let shelterData = (decodedResponse as RescueSheltersAPI2).data[0]
            
            let shelterObj = shelter(i: shelterData?.orgID ?? "", n: shelterData?.orgName ?? "", a1: shelterData?.orgAddress ?? "", a2: "", c: shelterData?.orgCity ?? "", s: shelterData?.orgState ?? "", z: shelterData?.orgLocation ?? "", lat: 0.0, lng: 0.0, c2: shelterData?.orgCountry ?? "", p: shelterData?.orgPhone ?? "", f: shelterData?.orgFax ?? "", e: shelterData?.orgEmail ?? "")

            self.isLoading = false
            
            globalShelterCache[shelterObj.id] = shelterObj
            
            completion(Result.success(shelterObj))
        }).resume()
    }
    
    func loadSheltersAPI3(_ shelterIDs: [String], completion: @escaping (Result<[String], DataResponseError>) -> Void) {
        
        var filteredShelterIDs = [String]()
        filteredShelterIDs.append(contentsOf: shelterIDs)

        filteredShelterIDs.removeAll { (id) -> Bool in
            if let s = globalShelterCache[id] {
                let hoursSinceCreation = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: s.dateCreated as Date, to: Date(), options: []).hour
                return hoursSinceCreation! < 24
            } else {
                return false
            }
        }

        if filteredShelterIDs.count == 0 {return}
        
        if (Utilities.isNetworkAvailable() == false) {
            isLoading = false
            return
        }
        
        let json = ["apikey":"0doJkmYU","objectType":"orgs","objectAction":"publicSearch", "search": ["resultStart": "0", "resultLimit":filteredShelterIDs.count, "resultSort": "orgID", "resultOrder": "asc", "filters": [["fieldName": "orgID", "operation": "equals", "criteria": filteredShelterIDs]], "fields": ["orgID","orgName","orgAddress","orgCity","orgState","orgLocation","orgCountry","orgPhone","orgFax","orgEmail"]]] as [String : Any]

        var urlRequest = URLRequest(url: baseURL)

        urlRequest.httpMethod = "POST"
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        session.uploadTask(with: urlRequest, from: jsonData, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
            else {
                completion(Result.failure(DataResponseError.network))
                return
            }
            
            guard let decodedResponse = try? JSONDecoder().decode(RescueSheltersAPI2.self, from: data) else {
                    completion(Result.failure(DataResponseError.decoding))
                    return
                }
            
            let shelterData = (decodedResponse as RescueSheltersAPI2)
            
            for (_, shelterAPI3) in shelterData.data {
                let shelterObj = shelter(i: shelterAPI3.orgID ?? "", n: shelterAPI3.orgName ?? "", a1: shelterAPI3.orgAddress ?? "", a2: "", c: shelterAPI3.orgCity ?? "", s: shelterAPI3.orgState ?? "", z: shelterAPI3.orgLocation ?? "", lat: 0.0, lng: 0.0, c2: shelterAPI3.orgCountry ?? "", p: shelterAPI3.orgPhone ?? "", f: shelterAPI3.orgFax ?? "", e: shelterAPI3.orgEmail ?? "")
                    globalShelterCache[shelterObj.id] = shelterObj
            }

            self.isLoading = false
            
            completion(Result.success(filteredShelterIDs))
        }).resume()
    }

}
 */
