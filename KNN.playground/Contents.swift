//: A UIKit based Playground for presenting user interface
  
import Foundation

func readAndParse(fileName:String)-> [[Any]]{
    var result: [[Any]] = []
    if let filepath = Bundle.main.path(forResource: fileName, ofType: "") {
        do {
            let str = try String(contentsOfFile: filepath)
            let rows = str.components(separatedBy: "\n" )
            for row in rows {
                if row.trimmingCharacters(in: ["\n", "\r"]) == "" {
                    continue
                }
                let columns = row.components(separatedBy: ",")
                result.append(columns)
                
            }
        } catch {
        }
    } else {
    }

    if let str = result[0][0] as? String, let tmp = Float(str) {
        
    }
    else {
        result[0] != nil ?  result.remove(at: 0) : nil
    }
    return result
}

func prepareData(data: [[Any]], excludedCol: [Int], dataSetName: String) -> [[Any]] {
   
    var mData = [[Any]]()
    
    for i in 0 ... (data.count - 1) {
        var row = [Any]()
        for l in 0 ... (data[i].count - 1) {
            var column = ""
            if (excludedCol.lastIndex(of: l) != nil) {
                continue
            }
            else if l == (data[i].count - 1){
                column = "class"
            }
            
            column += data[i][l] as! String
            row.append(column)
        }
        mData.append(row)
    }
    
    return mData
}

func prepareData(data: [[Any]], excludedCol: [Int]) -> [[Any]] {
    
    return prepareData(data: data, excludedCol: excludedCol, dataSetName: "")
}

func normalize(data: [[Any]]) -> [[Any]] {
    var fieldsMax = [Float](repeating: -Float.greatestFiniteMagnitude, count: data.first?.count ?? 0)
    var fieldsMin = [Float](repeating: Float.greatestFiniteMagnitude, count: data.first?.count ?? 0)

    var normalizedData = data

///    Finding max and min values for each column
    
    for i in 0 ... (data.count - 1) {

        for l in 0 ... (data[0].count - 1) {
         
            if let str = data[i][l] as? String, let tmp = Float(str), fieldsMax[l] < tmp, l != (data.count - 1 )  {
                fieldsMax[l] = tmp
            }
           
            if let str = data[i][l] as? String, let tmp = Float(str), fieldsMin[l] > tmp, l != (data.count - 1 )  {
                fieldsMin[l] = tmp
            }
        }
    }
    
///     Normalization for all values

   for i in 0 ... (data.count - 1) {
        var tmpEl = [Any]()
        for l in 0 ... (data[0].count - 1) {
            if let str = data[i][l] as? String, let numericValue = Float(str){
                let normalized: Float = Float( numericValue - fieldsMin[l]) / Float(fieldsMax[l] - fieldsMin[l])
                tmpEl.append(normalized)
            }
            else {
                tmpEl.append(data[i][l])
            }
        }
        normalizedData[i] = tmpEl
    }

    return normalizedData
}

/// Calculation euclidean Distances
func euclideanDistances(test: [Any], neighbors: [[Any]]) -> [Float] {
    
    var distances = [Float]()

    for i in 0 ... (neighbors.count - 2) {
        var distance = Float()
        for l in 0 ... ((neighbors.first?.count ?? 0) - 1) {
            if let n = neighbors[i][l] as? Float, let t = test[l] as? Float, l != (neighbors[i].count - 1), l != 0 {
                distance += pow( (t - n), 2)
            }
        }
        distances.append(sqrt( distance ))
       
    }
    
    return distances
}

/// Predicating test data by nearest k neighbor
func predicate(testData: [Any], learnData: [[Any]], k: Int) -> String{
    let distances = euclideanDistances(test: testData, neighbors: learnData )
    let distancesWithClass = zip(distances, learnData).map{ [$0, $1[$1.count - 1]]}
    
    let kNN = Array( distancesWithClass.sorted { ($0[0] as? Float ?? 0 )  < ($1[0] as? Float ?? 0) }.prefix(k) )
    kNN.map(){$0[0]}
    
    var classCounts = [String: Int]()
    
    for i in kNN {
        guard let cls = i[1] as? String else {
            return ""
        }
        classCounts.updateValue((classCounts[cls] ?? 0) + 1, forKey: cls)
    }
    
    
    guard let greatest = classCounts.max(by: { a, b in a.1  < b.1 }) else  { return ""}

    return greatest.key
}


// calculating and evaluating total score for the model
func kNN(data: [[Any]], k: Int){
    let normalizedData = normalize(data: data)
    
    let shuffled = normalizedData.shuffled()
    let LearningDatarate: Double = 70 / 100
    let learnDataCount = Int(LearningDatarate * Double(normalizedData.count))
    let learnData = Array(shuffled.prefix(learnDataCount))
    let testData = Array(shuffled.suffix(from: Int(learnDataCount)))

    var pred = [String]()
    var truePred = 0
    
    for test in testData {
        let prediction = predicate(testData: test, learnData: learnData, k: k)
        pred.append(prediction)
        if let act = test.last as? String, prediction == act {
            truePred += 1
        }
    }
    
    let accuracy = (Float(truePred) / Float(testData.count)) * 100
    
    print("total accuracy is \(accuracy)")
    
}

//let heart = readAndParse(fileName: "processed.cleveland.csv")
//let heart = prepareData(data: readAndParse(fileName: "processed.cleveland.csv"), excludedCol: [])
let iris = readAndParse(fileName: "IRIS.csv")
//let data = prepareData(data: iris, excludedCol: [])
//let bcwData = readAndParse(fileName: "bcw100.csv")
//let data = prepareData(data: bcwData, excludedCol: [0])

kNN(data: iris, k: 5)

