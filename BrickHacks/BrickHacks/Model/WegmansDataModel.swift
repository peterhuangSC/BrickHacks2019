//
//  WegmansDataModel.swift
//  BrickHacks
//
//  Created by Peter Huang on 2019-02-16.
//  Copyright © 2019 Peter Huang. All rights reserved.
//

//import Foundation
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

struct CellData {
    //var opened = false
    var recipeName: String
    var ingredientSKUList: [Int]
    //var sectionData: [String]
    var ingredientPrices: [Double]
}


class WegmansDataModel {
    
    //private final var podLicensesArrayKey = "PreferenceSpecifiers"
    //private final var titleKey = "Title"
    //private final var licenseNotesKey = "FooterText"
    //private final var licenseTypeKey = "License"
    
    public var recipeTableData = [CellData]()
    
    final let wegmensURL = "https://api.wegmans.io" //change this I forgot what it was
    final let APIVersion = "2018-10-18"
    final let hrefGetMeals = "/meals/recipes"
    
    let APP_ID = "6c3c6cfe694a4bda9b529d0ebc9497dd"
    
    
    init() {
        if let externalPath = Bundle.main.path(forResource: "EzMeals", ofType: "plist") {
            generateRecipes(from: externalPath)
        }
    }
    
    
    func getLicenseTableData() -> [CellData] {
        return recipeTableData
    }
    
    
    
    func getLicenseCellTitle(forRow number: Int) -> String {
        if number < recipeTableData.count {
            return recipeTableData[number].recipeName
        }
        return ""
    }
    
    
    //This function adds the licenses, both internal and external, to the tableViewData, which will be refreshed to display in the controller
    //  class is passed in as a reference
    func generateRecipes(from plistFilePath: String) {
        //
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
        //recipeTableData [] is updated
    }
    
    
    func getRecipeData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                //print("Success: Got the recipe data!")
                let recipeJSON : JSON = JSON(response.result.value!)
                print(recipeJSON)
                if let recipeStringJSON = recipeJSON.rawString() {
                    if let ezRecipeItem = self.convertToDictionary(text: recipeStringJSON) {
                        let myRecipeName = ezRecipeItem["name"] as! String
                        var currentSKUList = [Int]()
                        
                        if let currentIngredientList : [NSDictionary] = (ezRecipeItem["ingredients"] as! [NSDictionary]) {
                            for myIngredients in currentIngredientList {
                                guard let currentSKU : Int = (myIngredients["sku"] as? Int) else {
                                    continue
                                }
                                
                                currentSKUList.append(currentSKU)
                            }
                        }
                        
                        let currentRecipe = CellData.init(recipeName: myRecipeName, ingredientSKUList: currentSKUList, ingredientPrices: [Double]())
                        self.recipeTableData.append(currentRecipe)
                    }
                }
            } else {
                print("Error: \(String(describing: response.result.error))")
                //self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    
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
    
    
}
