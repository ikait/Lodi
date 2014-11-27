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
    private var title: String = ""
    var keyword: String = ""
    var endpointUri: String?
    
    let DefaultEndpointUri = "http://ja.dbpedia.org/sparql"
    let DefaultLimit: Int = 30
    let DefaultDistinct: Bool = true
    var limit: Int = 30
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
            return (false, "Compose conditions.")
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
            return (false, "Need a shown variable at least. Check at \(hasShownVariable.1 + 1).")
        }
        
        var allVariable = true
        for c in self.conditions {
            if !c.isAllVariable() {  // 1つでも該当すれば直ちにfalse
                allVariable = false
            }
        }
        if allVariable {
            return (false, "Need a condition not variable at least.")
        }
        
        return (true, "Ready for search!")
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
            return str1 < str2
        }
        return variableLabels
    }
    
    /// SPARQLクエリを組み立てて、返す
    func getQueryString(distinct: Bool? = nil, filter: String? = nil, limit: Int? = nil) -> String {
        
        var queryString = "select"
        
        if let distinct = distinct {
            if distinct {
                queryString = "\(queryString) distinct"
            }
        } else if self.distinct {
            queryString = "\(queryString) distinct"
        }
        
        for condition in self.conditions {
            var s = condition.subject
            var p = condition.predicate
            var o = condition.object
            
            if s.variable && s.show {
                queryString = "\(queryString) \(s.getVariableLabelWithPrefix())"
            }
            if p.variable && p.show {
                queryString = "\(queryString) \(p.getVariableLabelWithPrefix())"
            }
            if o.variable && o.show {
                queryString = "\(queryString) \(o.getVariableLabelWithPrefix())"
            }
        }
        
        queryString = "\(queryString) where {"
        
        for (index, condition) in enumerate(self.conditions) {
            
            var s = condition.subject.getVariableLabelOrValue(prefix: true)
            var p = condition.predicate.getVariableLabelOrValue(prefix: true)
            var o = condition.object.getVariableLabelOrValue(prefix: true)
            
            queryString = "\(queryString) \(s)"
            queryString = "\(queryString) \(p)"
            queryString = "\(queryString) \(o) ."

            
            if index == self.conditions.count - 1 {
                if let filter = filter {
                    queryString = "\(queryString) FILTER regex (\(s), \"\(filter)\")"
                }
            }
        }
        
        queryString = "\(queryString) }"
        
        if let limit = limit {
            queryString = "\(queryString) LIMIT \(limit)"
        } else if self.limit != 0 {
            queryString = "\(queryString) LIMIT \(self.limit)"
        }
    
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
    }
    
    init() {
        self.subject = SearchConditionElement()
        self.predicate = SearchConditionElement()
        self.object = SearchConditionElement()
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
            // return (false, "A condition needs a keyword at least.")
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
    
    /// デフォルト. isEmptyなどにも影響
    let defaultSetting = (variable: false, show: true)
    
    init() {
        self.value = ""
        self.variable = defaultSetting.variable
        self.show = defaultSetting.show
        self.variableLabel = ""
    }
    
    init(show: Bool, value: String, variable: Bool, variableLabel: String) {
        self.show = show
        self.value = value
        self.variable = variable
        self.variableLabel = variableLabel
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
            return (false, "Need to fill label if it's a variable.")
        }
        if !self.variable && self.value.isEmpty {
            return (false, "Need to fill keyword.")
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