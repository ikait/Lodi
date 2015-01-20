//
//  AutomaticQuerySearchController.swift
//  Lodi
//
//  Created by Taishi Ikai on 2014/11/15.
//  Copyright (c) 2014年 Taishi Ikai. All rights reserved.
//

import Foundation

class SearchConditionControllerSet {
    private var controllers: [SearchConditionController]
    
    init(controllers: [SearchConditionController]) {
        self.controllers = controllers
    }
    
    init() {
        self.controllers = []
    }
    
    func appendController(controller: SearchConditionController) {
        self.controllers.append(controller)
    }
    
    func insertController(controller: SearchConditionController, atIndex: Int) {
        self.controllers.insert(controller, atIndex: atIndex)
    }
    
    func removeController(controller: SearchConditionController) {
        var removeTargetIndex: [Int] = []
        for (index, alreadySavedController) in enumerate(self.controllers) {
            if alreadySavedController.isEqualTo(controller) {
                removeTargetIndex.append(index)
            }
        }
        for index in removeTargetIndex {
            self.controllers.removeAtIndex(index)
        }
    }
    
    func removeControllerAtIndex(index: Int) -> SearchConditionController {
        return self.controllers.removeAtIndex(index)
    }
    
    func getControllers() -> [SearchConditionController] {
        return self.controllers
    }
    
    func getControllerAtIndex(index: Int) -> SearchConditionController {
        return self.controllers[index]
    }
    
    func hasController(controller: SearchConditionController) -> Bool {
        for alreadySavedController in self.controllers {
            if alreadySavedController.isEqualTo(controller) {
                return true
            }
        }
        return false
    }
    
    func countControllers() -> Int {
        return self.controllers.count
    }
    
}

class SearchConditionController {
    private var conditions: [SearchCondition]
    private var dateCreated = NSDate()
    var title: String = ""
    var keyword: String = ""
    var endpointUri: String?  // TODO: dbpedia 以外にも対応
    
    //let DefaultEndpointUri = "http://dbpedia.org/sparql"
    let DefaultEndpointUri = "http://www.wikipediaontology.org/query/"
    let DefaultLimit: Int = 80
    let DefaultDistinct: Bool = true
    var limit: Int = 80
    var distinct: Bool = true
    
    //var offset: Int = 0
    //var sortCriteria: SearchConditionElement
    
    init(title: String, conditions: [SearchCondition]) {
        self.conditions = conditions
        self.title = title
    }
    
    init(title: String, keyword: String) {
        self.conditions = []
        self.keyword = keyword
        self.title = title
    }
    
    init(title: String) {
        self.conditions = []
        self.title = title
    }
    
    init() {
        self.conditions = []
    }
    
    func addCondition(condition: SearchCondition) {
        self.conditions.append(condition)
    }
    
    func addEmptyCondition() {
        self.conditions.append(SearchCondition())
    }
    
    func getCondition(index: Int) -> SearchCondition {
        return self.conditions[index]
    }
    
    func getConditions() -> [SearchCondition] {
        return self.conditions
    }
    
    func removeCondition(index: Int) -> SearchCondition {
        return self.conditions.removeAtIndex(index)
    }
    
    func countContidions() -> Int {
        return self.conditions.count
    }
    
    func getDateCreated() -> NSDate {
        return self.dateCreated
    }
    
    func getEndpointUri() -> NSURL? {
        if let url = self.endpointUri {
            return NSURL(string: url)
        } else {
            return NSURL(string: self.DefaultEndpointUri)
        }
    }
    
    /// 与えられたコントローラとこのコントローラが等しいか？（生成日時で比較）
    func isEqualTo(controller: SearchConditionController) -> Bool {
        return self.getDateCreated().description == controller.getDateCreated().description
    }

    /// 初期生成時から変更が加えられたか？
    func isChangedFromInitialState() -> Bool {
        if self.limit != self.DefaultLimit &&
        self.distinct != self.DefaultDistinct {
            return true
        }
        if !self.isEmpty() {
            return true
        }
        return false
    }
    
    /// コントローラ下が空かどうか？
    func isEmpty() -> Bool {
        if !self.title.isEmpty {
            return false
        }
        if !self.keyword.isEmpty {
            return false
        }
        if self.countContidions() > 0 {
            for c in self.conditions {
                if !c.isEmpty() {
                    return false // immidiatety false, if not empty
                }
            }
        }
        return true
    }
    
    /// コントローラ下の条件が全て正しいか確認して、正否とコメントを返す
    func isValid() -> (valid: Bool, comment: String) {
        if self.isEmpty() {
            return (false, NSLocalizedString("Compose conditions.", comment: ""))
        }
        var hasShownVariable = (true, 0)
        for (index, c) in enumerate(self.conditions) {
            if !c.isValid().valid {
                return (false, c.isValid().comment)
            }
            if !c.hasShownVariable() {
                hasShownVariable = (false, index)
            }
        }
        if !hasShownVariable.0 {
            // return (false, "Need a shown variable at least. Check at \(hasShownVariable.1 + 1).")
            var v = String(hasShownVariable.1 + 1)
            
            return (false, NSString(format: NSLocalizedString("Need a shown variable at least. Check at %1$@", comment: ""), v))
        }
        
        var allVariable = true
        for c in self.conditions {
            if !c.isAllVariable() {  // 1つでも該当すれば直ちにfalse
                allVariable = false
            }
        }
        if allVariable {
            return (false, NSLocalizedString("Need a condition not variable at least.", comment: ""))
        }
        
        return (true, NSLocalizedString("Ready for search!", comment: ""))
    }
    
    /// タイトルを返す。設定されていなければ日付を返す
    func getTitle() -> String {
        if !self.title.isEmpty {
            return title
        } else {
            return self.dateCreated.description
        }
    }
    
    /// コントローラ下にある変数ラベルを全て取得する
    func getVariableLabels() -> [String] {
        var variableLabels: [String] = []
        for condition in self.getConditions() {
            var svl = condition.subject.variableLabel
            var pvl = condition.predicate.variableLabel
            var ovl = condition.object.variableLabel
            if !svl.isEmpty {
                if !contains(variableLabels, svl) {
                    variableLabels.append(svl)
                }
            }
            if !pvl.isEmpty {
                if !contains(variableLabels, pvl) {
                    variableLabels.append(pvl)
                }
            }
            if !ovl.isEmpty {
                if !contains(variableLabels, ovl) {
                    variableLabels.append(ovl)
                }
            }
        }
        sort(&variableLabels){ (str1, str2) in
            return str1 > str2
        }
        return variableLabels
    }
    
    /// コントローラ下にある変数ラベルとorderを全て取得する
    func getVariableLabelsAndOrders() -> [String: SearchConditionVariableOrder] {
        var variableLabelsAndOrders: [String: SearchConditionVariableOrder] = [:]
        for condition in self.getConditions() {
            var svl = condition.subject.variableLabel
            var pvl = condition.predicate.variableLabel
            var ovl = condition.object.variableLabel
            if !svl.isEmpty {
                variableLabelsAndOrders[svl] = condition.subject.orderBy
            }
            if !pvl.isEmpty {
                variableLabelsAndOrders[pvl] = condition.predicate.orderBy
            }
            if !ovl.isEmpty {
                variableLabelsAndOrders[ovl] = condition.object.orderBy
            }
        }
        return variableLabelsAndOrders
    }
    
    /// コントローラ下にある、指定したlabelの変数のorderを設定する
    func setVariableOrder(label: String, order: SearchConditionVariableOrder) {
        for condition in self.getConditions() {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            if s.variableLabel == label {
                s.orderBy = order
            }
            if p.variableLabel == label {
                p.orderBy = order
            }
            if o.variableLabel == label {
                o.orderBy = order
            }
        }
    }
    
    /// コントローラ下にある、指定したlabelの変数のorderを取得する
    func getVariableOrder(label: String) -> SearchConditionVariableOrder {
        for condition in self.getConditions() {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            if s.variableLabel == label {
                return s.orderBy
            }
            if p.variableLabel == label {
                return p.orderBy
            }
            if o.variableLabel == label {
                return o.orderBy
            }
        }
        return SearchConditionVariableOrder.None
    }
    
    
    /// 指定したラベルの変数は表示されるか?
    func isVariableShown(label: String) -> Bool {
        var isShown = false
        
        for condition in self.getConditions() {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            // when true, immediately true
            if s.variableLabel == label && s.variable && s.show {
                isShown = true
            }
            if p.variableLabel == label && p.variable && p.show {
                isShown = true
            }
            if o.variableLabel == label && o.variable && o.show {
                isShown = true
            }
        }
        return isShown
    }
    
    /// コントローラ下にある、指定したlabelの変数の表示を設定する
    func setVariableShown(label: String, show: Bool) {
        for condition in self.getConditions() {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            if s.variableLabel == label {
                s.show = show
            }
            if p.variableLabel == label {
                p.show = show
            }
            if o.variableLabel == label {
                o.show = show
            }
        }
    }
    
    /// コントローラ下にある、指定したlabelの変数の表示を設定する
    func setVariableFilterString(label: String, filterString: String) {
        for condition in self.getConditions() {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            if s.variableLabel == label {
                s.filterString = filterString
            }
            if p.variableLabel == label {
                p.filterString = filterString
            }
            if o.variableLabel == label {
                o.filterString = filterString
            }
        }
    }
    
    func getVariableFilterString(label: String) -> String {
        for condition in self.getConditions() {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            if s.variableLabel == label {
                return s.filterString
            }
            if p.variableLabel == label {
                return p.filterString
            }
            if o.variableLabel == label {
                return o.filterString
            }
        }
        return ""
    }
    
    /// 変数とフィルター文字列を得る
    func getVariablesWithFilterString() -> [String: String] {
        var variablesWithFilterString: [String: String] = [:]
        
        for condition in self.getConditions() {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            if s.isValid().valid && s.variable && !s.filterString.isEmpty {
                variablesWithFilterString[s.variableLabel] = s.filterString
            }
            if p.isValid().valid && p.variable && !p.filterString.isEmpty {
                variablesWithFilterString[p.variableLabel] = p.filterString
            }
            if o.isValid().valid && o.variable && !o.filterString.isEmpty {
                variablesWithFilterString[o.variableLabel] = o.filterString
            }
        }
        return variablesWithFilterString
    }
    
    func getUnderstandable() -> String {
        var understandable = ""
        for (index, condition) in enumerate(self.conditions) {
            
            understandable += NSString(format: NSLocalizedString(
                "%1$@ %2$@ %3$@",
                comment: "understandable on SCController. 1:s, 2:p, 3:o"),
                condition.subject.getVariableLabelOrShortValue(prefix: true),
                condition.predicate.getVariableLabelOrShortValue(prefix: true),
                condition.object.getVariableLabelOrShortValue(prefix: true)
            )
            
            if index == self.conditions.count - 1 {
                understandable += NSLocalizedString(".", comment: "understandable period on SCController")
            } else {
                understandable += NSLocalizedString(",\n", comment: "understandable comma on SCController")
            }
        }
        
        return understandable
    }
    
    /// SPARQLクエリを組み立てて、返す
    func getQueryString(distinct: Bool? = nil, filter: String? = nil, limit: Int? = nil) -> String {
        
        var queryString = "select"
        
        if let distinct = distinct {
            if distinct {
                queryString += " distinct"
            }
        } else if self.distinct {
            queryString += " distinct"
        }
        
        var addedVariableLabelSet = NSMutableSet()
        for condition in self.conditions {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            if s.variable && s.show {
                var labelWithPrefix = s.getVariableLabelWithPrefix()
                
                if !addedVariableLabelSet.containsObject(labelWithPrefix) {
                    queryString = "\(queryString) \(labelWithPrefix)"
                    addedVariableLabelSet.addObject(labelWithPrefix)
                }
            }
            if p.variable && p.show {
                var labelWithPrefix = p.getVariableLabelWithPrefix()
                
                if !addedVariableLabelSet.containsObject(labelWithPrefix) {
                    queryString = "\(queryString) \(labelWithPrefix)"
                    addedVariableLabelSet.addObject(labelWithPrefix)
                }
            }
            if o.variable && o.show {
                var labelWithPrefix = o.getVariableLabelWithPrefix()
                
                if !addedVariableLabelSet.containsObject(labelWithPrefix) {
                    queryString = "\(queryString) \(labelWithPrefix)"
                    addedVariableLabelSet.addObject(labelWithPrefix)
                }
            }
        }
        
        queryString += " where {\n"  // where句付け足し
        
        for (index, condition) in enumerate(self.conditions) {
            
            var s = condition.subject.getVariableLabelOrValue(prefix: true)
            var p = condition.predicate.getVariableLabelOrValue(prefix: true)
            var o = condition.object.getVariableLabelOrValue(prefix: true)
            
            queryString += "\t\(s)"
            queryString += " \(p)"
            queryString += " \(o) .\n"
            
            //==================================================================
            //queryString += "\tMINUS { \(s) owl:sameAs \(o) }\n"
            //queryString += "\tMINUS { \(s) dbpedia-owl:wikiPageWikiLink \(o) }\n"
            //==================================================================
            
            if index == self.conditions.count - 1 {
                
                if let filter = filter {
                    queryString += "\tFILTER regex (\(s), \"\(filter)\")\n"
                }
                
                for variableAndFilterString in self.getVariablesWithFilterString() {
                    queryString += "\tFILTER regex (?\(variableAndFilterString.0), \"\(variableAndFilterString.1)\")\n"
                }
            }
        }
        
        
        queryString += "}"
        
        var sortCriteria: [String: SearchConditionVariableOrder] = [:]
        for condition in self.conditions {
            if condition.subject.variable && condition.subject.orderBy != SearchConditionVariableOrder.None {
                sortCriteria[condition.subject.variableLabel] = condition.subject.orderBy
            }
            if condition.predicate.variable && condition.predicate.orderBy != SearchConditionVariableOrder.None {
                sortCriteria[condition.predicate.variableLabel] = condition.predicate.orderBy
            }
            if condition.object.variable && condition.object.orderBy != SearchConditionVariableOrder.None {
                sortCriteria[condition.object.variableLabel] = condition.object.orderBy
            }
        }
        if sortCriteria.count > 0 {
            queryString += "\nORDER BY"
            for c in sortCriteria {
                if c.1 == SearchConditionVariableOrder.Ascend {
                    queryString += " ?\(c.0)"
                } else {
                    queryString += " DESC(?\(c.0))"
                }
            }
        }
        
        /*
        if let limit = limit {
            queryString += "\nLIMIT \(limit)"
        } else if self.limit != 0 {
            queryString += "\nLIMIT \(self.limit)"
        }*/
    
        println(queryString)
        return queryString
    }
}

class SearchCondition {
    var subject: SearchConditionElement
    var predicate: SearchConditionElement
    var object: SearchConditionElement
    
    init(subject: SearchConditionElement, predicate: SearchConditionElement, object: SearchConditionElement) {
        self.subject = subject
        self.predicate = predicate
        self.object = object
        
        self.subject.position = SearchConditionPosition.Subject
        self.predicate.position = SearchConditionPosition.Predicate
        self.object.position = SearchConditionPosition.Object
    }
    
    init() {
        self.subject = SearchConditionElement()
        self.predicate = SearchConditionElement()
        self.object = SearchConditionElement()
        
        self.subject.position = SearchConditionPosition.Subject
        self.predicate.position = SearchConditionPosition.Predicate
        self.object.position = SearchConditionPosition.Object
    }
    
    /// 条件が空かどうか？
    func isEmpty() -> Bool {
        if self.subject.isEmpty() &&
            self.predicate.isEmpty() &&
            self.object.isEmpty() {
                return true
        }
        return false
    }
    
    /// 正当な条件になっているか？正否とコメントを返す
    func isValid() -> (valid: Bool, comment: String) {
        if self.isAllVariable() {
            // return (false, NSLocalizedString("A condition needs a keyword at least.", comment: ""))
        }
        if !self.subject.isValid().valid {
            return (false, self.subject.isValid().comment)
        }
        if !self.predicate.isValid().valid {
            return (false, self.predicate.isValid().comment)
        }
        if !self.object.isValid().valid {
            return (false, self.object.isValid().comment)
        }
        return (true, "")
    }
    
    /// 表示設定の変数をもっているか？
    func hasShownVariable() -> Bool {
        if (self.subject.show && self.subject.variable) ||
            (self.predicate.show && self.predicate.variable) ||
            (self.object.show && self.object.variable) {
                return true
        }
        return false
    }
    
    /// 条件が全て変数になってしまっているか？
    private func isAllVariable() -> Bool {
        if self.subject.variable &&
            self.predicate.variable &&
            self.object.variable {
                return true
        }
        return false
    }
    
}

class SearchConditionElement {
    var show: Bool
    var value: String
    var variable: Bool
    var variableLabel: String
    
    var position: SearchConditionPosition!
    
    var orderBy: SearchConditionVariableOrder = SearchConditionVariableOrder.None
    var filterString: String = ""
    
    /// デフォルト. isEmptyなどにも影響
    let defaultSetting = (variable: false, show: true)
    
    init() {
        self.value = ""
        self.variable = defaultSetting.variable
        self.show = defaultSetting.show
        self.variableLabel = ""
    }
    
    init(show: Bool, value: String, variable: Bool, variableLabel: String, filterString: String) {
        self.show = show
        self.value = value
        self.variable = variable
        self.variableLabel = variableLabel
        self.filterString = filterString
    }
    
    /// 非表示設定の変数かどうか？
    func isHidden() -> Bool {
        if self.variable && !self.show {
            return true
        }
        return false
    }
    
    /// 空かどうか？
    func isEmpty() -> Bool {
        if self.value.isEmpty && self.variableLabel.isEmpty &&
            self.show == self.defaultSetting.show &&
            self.variable == self.defaultSetting.variable {
                return true
        }
        return false
    }
    
    /// 正当な要素であるか？正否とコメントを返す
    func isValid() -> (valid: Bool, comment: String) {
        if self.variable && self.variableLabel.isEmpty {
            return (false, NSLocalizedString("Need to fill label if it's a variable.", comment: ""))
        }
        if !self.variable && self.value.isEmpty {
            return (false, NSLocalizedString("Need to fill keyword.", comment: ""))
        }
        return (true, "")
    }
    
    /// Prefix("?") がついた変数ラベルを返す
    func getVariableLabelWithPrefix() -> String {
        return "?\(self.variableLabel)"
    }
    
    func getVariableLabelOrValue(prefix: Bool? = false) -> String {
        var str = ""
        if self.variable {
            if prefix! {
                str = self.getVariableLabelWithPrefix()
            } else {
                str = self.variableLabel
            }
        } else {
            str = self.value
        }
        return str
    }
    
    /// 変数ラベルか、短い値を返す。UI表示用
    func getVariableLabelOrShortValue(prefix: Bool? = false) -> String {
        var str = self.getVariableLabelOrValue(prefix: prefix)
        if self.variable {
            return str
        }
        if self.value.utf16Count < 1 {
            return self.value
        }
        if str.hasPrefix("<") && str.hasSuffix(">") {
            str = str.substringWithRange(Range<String.Index>(
                start: advance(self.value.startIndex, 0),
                end: advance(self.value.endIndex, -1)))
        }
        let c = str.substringWithRange(Range<String.Index>(
            start: advance(self.value.startIndex, 0),
            end: advance(self.value.endIndex, -1)))
            .componentsSeparatedByCharactersInSet(
                NSCharacterSet(charactersInString: "#/"))
        return c.last!
    }
}

enum SearchConditionVariableOrder: String {
    case None = "None",
    Ascend = "Ascending",
    Descend = "Descending"
    
    func toString() -> String {
        switch self {
        case SearchConditionVariableOrder.Ascend:
            return NSLocalizedString("Ascending", comment: "SearchConditionVariableOrder.Ascend")
        case SearchConditionVariableOrder.Descend:
            return NSLocalizedString("Descending", comment: "SearchConditionVariableOrder.Descend")
        case SearchConditionVariableOrder.None:
            return NSLocalizedString("None", comment: "SearchConditionVariableOrder.None")
        default:
            return ""
        }
    }
    
    static let allValues = [None, Ascend, Descend]
}

enum SearchConditionPosition {
    case Subject, Predicate, Object
}