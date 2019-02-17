//
//  ViewController.swift
//  BrickHacks
//
//  Created by Peter Huang on 2019-02-16.
//  Copyright © 2019 Peter Huang. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class RecipeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    

    @IBOutlet weak var recipeTableView: UITableView!
    
    final let wegmensURL = "https://api.wegmans.io" //change this I forgot what it was
    final let APIVersion = "2018-10-18"
    final let hrefGetMeals = "/meals/recipes"
    
    let APP_ID = "6c3c6cfe694a4bda9b529d0ebc9497dd"
    
    //TO DO: Declare instance variables here
    let locationManager = CLLocationManager()
    
    //TO DO: link your IBOutlets here
    
    
    //globals
    var ezRecipes : NSMutableDictionary = [:] //[Int : [String : Any]]()
    var ezRecipeKeys = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let externalPath = Bundle.main.path(forResource: "EzMeals", ofType: "plist") {
            generatePlist(from: externalPath)
        }
        
        recipeTableView.reloadData()
        //locations
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation() //async background call
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func generatePlist(from plistFilePath: String) {
        guard let ezMealsDictionary: NSDictionary = NSDictionary(contentsOfFile: plistFilePath) else {
            return
        }
        
        var plist = [String : Int]()
        for (key, value) in ezMealsDictionary {
            if let index = key as? String {
                if let value = value as? Int {
                    plist[index] = value
                }
            }
        }
        
        let params : [String : String] = ["api-version" : APIVersion, "subscription-key" : APP_ID]
        
        for ezMeal in plist {
            let configURL = wegmensURL + hrefGetMeals + "/\(ezMeal.value)"
            getRecipeData(url: configURL, parameters: params) //prints out things
        }
        //ezRecipes NSMutable is donezo
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getRecipeData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                //print("Success: Got the recipe data!")
                let recipeJSON : JSON = JSON(response.result.value!)
                print(recipeJSON)
                if let recipeStringJSON = recipeJSON.rawString() {
                    if let ezRecipeItem = self.convertToDictionary(text: recipeStringJSON) {
                        self.ezRecipes.setObject(ezRecipeItem, forKey: ezRecipeItem["id"] as! NSCopying)
                        self.ezRecipeKeys.append(ezRecipeItem["id"] as! Int)
                        print("ez recipes count \(self.ezRecipes.count)")
                    }
                }
                //self.updateRecipeData(json: recipeJSON)
            } else {
                print("Error: \(String(describing: response.result.error))")
                //self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //Write the updateWeatherData method here:
//    func updateWeatherData(json: JSON) {
//        if let tempResult = json["main"]["temp"].double {
//            weatherDataModel.temperature = Int(tempResult - 273.15)
//            weatherDataModel.city = json["name"].stringValue
//            weatherDataModel.condition = json["weather"][0]["id"].intValue
//            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
//
//            updateUIWithWeatherData()
//        } else {
//            cityLabel.text = "Weather Unavailable"
//        }
//
//    }
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
//    func updateUIWithWeatherData() {
//        cityLabel.text = weatherDataModel.city
//        temperatureLabel.text = String(weatherDataModel.temperature)
//        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
//    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        //stop fetching location as soon as it's valid, prevents battery consumption
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil //avoid multiple data repeats
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")

            //let latitude = String(location.coordinate.latitude)
            //let longitude = String(location.coordinate.longitude)

            //id
            //let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            let params : [String : String] = ["api-version" : APIVersion, "subscription-key" : APP_ID]

            let configURL = wegmensURL + hrefGetMeals
            //getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        //cityLabel.text = "Location Unavailable"
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipeCell = tableView.dequeueReusableCell(withIdentifier: "recipe cell") ??
            UITableViewCell(style: .default, reuseIdentifier: "recipe cell")
        
        let ezRecipeList = ezRecipes.allKeys
        recipeCell.textLabel?.text = "yoyoyo" //ezRecipeList["\(ezRecipeKeys[indexPath.section])"]
        
        return recipeCell
    }
}

