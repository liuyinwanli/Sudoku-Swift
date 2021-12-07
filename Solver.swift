import Foundation

class Solver{
    private var rowDict: [Int:[Int]]!
    private var colDict: [Int:[Int]]!
    private var sudoku: [[Int]]!
    private var ans: [Int]
    init(){
        self.rowDict = [Int:[Int]]()
        self.colDict = [Int:[Int]]()
        self.sudoku = Array(repeating:Array(repeating: 0,count: 9),count: 9)
        self.ans = [Int]()
    }
    public func solve(){
        self.initSudoku()
        self.displaySudoku()
        self.initDL()
        if self.solveDancingLink(RD: self.rowDict,CD: self.colDict){
            print("-----------------------成功----------------------")
            self.solveSudoku()
            self.displaySudoku()
        }
    }
    private func solveSudoku(){
        var locs: [Int]!
        var x: Int!
        var y: Int!
        var num: Int!
        for answer in self.ans{
            locs = self.rowDict[answer]
            x = locs[0] / 9
            y = locs[0] % 9
            num = answer % 9
            self.sudoku[x][y] = num + 1
        }
    }
    private func initColDict(){
        for x in 0..<(4 * self.sudoku.count * self.sudoku.count){
            self.colDict[x] = [Int]()
		}
    }
    private func calLocation(x: Int ,y: Int,num: Int)->[Int]{
        return [(x * 9 + y) * 9 + num,y + x * 9,81 * 1 + x * 9 + num,81 * 2 + y * 9 + num,81 * 3 + ((y / 3)  + (x / 3) * 3 ) * 9 + num,]
    }
    private func initDL(){
        self.initColDict()
        for x in 0..<9{
            for y in 0..<9{
                if self.sudoku[x][y] == 0 {
                    for num in 1...9{
                        self.addRow(x: x,y: y,num: num)
                    }
                }else{
                    self.addRow(x: x,y: y,num: self.sudoku[x][y])
                }
            }
        }
    }
    private func addRow(x: Int,y: Int,num: Int){
        let locs = self.calLocation(x: x,y: y,num: num-1)
        self.rowDict[locs[0]] = Array<Int>(locs[1..<locs.count])
        for loc in locs[1..<locs.count]{
            self.colDict[loc]!.append(locs[0])
        }
    }
    private func displaySudoku(){//////////////////////////////////////
        for i in 0..<self.sudoku.count{
            if (i == 3) || (i == 6) {
                print("- ----------------- -")
            }
            for n in 0..<self.sudoku[i].count{
                if (n == 3) || (n == 6) {
                    print("|",terminator: " ")
                }
                print(self.sudoku[i][n],terminator: " ")
            }
            print()
        }
    }
    private func initSudoku(){////////////////////////////////////////
        let manager = FileManager.default
        let pathAndName = "/home/ll/文档/Swift/data.txt"
        if  manager.fileExists(atPath: pathAndName) && manager.isReadableFile(atPath: pathAndName){
            let handler: FileHandle! = try! FileHandle(forReadingAtPath: pathAndName)
            //print(try! handler.offset())
            let data: Data! = try! handler.readToEnd()

            let str: String! = String(data: data!, encoding: String.Encoding.utf8)
            var nowInt: Int!
            let row = str.split(separator: "\n")
            var col:[Substring]
            for r in 0..<row.count{
				col = row[r].split(separator: " ")
                for c in 0..<col.count {
                    nowInt = Int(col[c])
                    self.sudoku[r][c] = nowInt
                }
            }
            try! handler.close()
        }
    }
    private func theBest(CC:[Int:[Int]])->Int{
        var less = 81 * 9
        var row = 0
        for (key,val) in CC{
            if val.count < less{
                less = val.count
                row = key
            }
        }
        return row
    }
    private func catchRowsByRow(row: Int, RC: [Int:[Int]], CC: [Int:[Int]])->Set<Int>{
        var ret: Set<Int>! = Set<Int>()
        for col_index in RC[row]!
        {
            for r_index in CC[col_index]!
            {
                ret.insert(r_index)
            }
        }
        return ret
    }
    private func solveDancingLink(RD: [Int:[Int]],CD: [Int:[Int]])-> Bool {
        var exit = false
        var RC: [Int:[Int]]! = RD
        var CC: [Int:[Int]]! = CD
        var best: Int!
        var rows:Set<Int>!
        if RC.isEmpty && CC.isEmpty {
            exit = true
        } else if self.isNULL(CC: CC) {
            exit =  false
            print("错误，有空列",RC.count,CC.count)
        }else{
            best = self.theBest(CC: CD)
            for row_index in CC[best]!
            {
                RC = RD
                CC = CD
                rows = self.catchRowsByRow(row: row_index,RC: RC,CC: CC)
                for row in rows
                {
                    for c_index in RC[row]!
                    {
                        CC[c_index]!.removeAll(where: {$0 == row})
                    }
                }
                for col_index in RC[row_index]!
                {
                    CC.removeValue(forKey: col_index)
                }
                for row in rows
                {
                    RC.removeValue(forKey: row)
                }
                exit = self.solveDancingLink(RD: RC,CD: CC)
                if exit
                {
                    self.ans.append(row_index)
                    //print("- 成功--")
                    break
                }
            }

        }
        return exit
    }
    public func isNULL(CC: [Int:[Int]])-> Bool {
		var ret = false
		if !CC.isEmpty {
            for head in CC.values{
                if head.isEmpty {
                    ret = !ret
                    break
                }
            }
        }
		return ret
	}
}


var sudoku = Solver()
sudoku.solve()
