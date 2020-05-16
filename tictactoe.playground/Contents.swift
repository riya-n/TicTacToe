//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import AVFoundation

class MyViewController : UIViewController {

    let hapticEngine = UIImpactFeedbackGenerator()
    var score = UILabel()
    var turn = UILabel()
    var buttons = [UIButton]()
    let winComb = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [2, 4, 6], [0, 4, 8]]
    var winSoundEffect: AVAudioPlayer?
    var loseSoundEffect: AVAudioPlayer?

    enum BlockState {
        case x, o, blank
    }

    enum GameState {
        case playing, win, lose, draw
    }

    var blocks: [BlockState] = Array.init(repeating: .blank, count: 9)
    var currPlayer: BlockState = .x
    var gameState: GameState = .playing

    var scoreCount = 0 {
        didSet {
            score.text = "Your Score: \(scoreCount)"
        }
    }
    
    func didUpdate(state: BlockState, button: UIButton) {
        switch state {
            case .x: button.setImage(UIImage(named: "mark-x.png")?.withRenderingMode(.alwaysTemplate), for: .normal); self.checkStatus(button)
            //; self.onComputerTurn()
            case .o: button.setImage(UIImage(named: "mark-o.png")?.withRenderingMode(.alwaysTemplate), for: .normal); self.checkStatus(button)
            case .blank: button.setImage(UIImage(named: "mark-none.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    func didUpdate(state: GameState, button: UIButton, comb: [UIButton]) {
        switch state {
            case .playing: turn.text = currPlayer == .x ? "Your Turn" : ""; turn.textColor = .label; currPlayer == .o ? self.onComputerTurn() : nil
            case .win: turn.text = "You Win!"; turn.textColor = .systemGreen; scoreCount = scoreCount + 1; comb.forEach { block in block.tintColor = .systemGreen}
            case .lose: turn.text = "You lose :("; turn.textColor = .systemRed; comb.forEach { block in block.tintColor = .systemRed}
            case .draw: turn.text = "Draw"; turn.textColor = .systemGray; buttons.forEach { block in block.tintColor = .systemGray}
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let title = UILabel()
        title.frame = CGRect(x: 0, y: 50, width: 240, height: 60)
        title.center.x = view.center.x
        title.textAlignment = .center
        title.text = "Tic Tac Toe"
        title.font = UIFont.systemFont(ofSize: 50, weight: UIFont.Weight.thin)
        
        view.addSubview(title)
        
        score.frame = CGRect(x: 0, y: title.frame.maxY + 25, width: 150, height: 25)
        score.center.x = view.center.x
        score.textAlignment = .center
        score.text = "Your Score: 0"
        score.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.thin)
        
        view.addSubview(score)
        
        turn.frame = CGRect(x: 0, y: score.frame.maxY + 100, width: 250, height: 35)
        turn.center.x = view.center.x
        turn.textAlignment = .center
        turn.text = "Your Turn"
        turn.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.semibold)
        
        view.addSubview(turn)
        
        for i in 0...2 {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "mark-none.png"), for: .normal)
            button.addTarget(self, action: #selector(self.onClickButton), for: .touchUpInside)
            let y = Int(turn.frame.maxY) + 30 + (70 * i)
            button.frame = CGRect(x: 0, y: y, width: 60, height: 60)
            button.center.x = view.center.x
            button.tag = (3 * i) + 2
            button.tintColor = .systemBlue
            view.addSubview(button)

            let buttonL = UIButton(type: .custom)
            buttonL.setImage(UIImage(named: "mark-none.png"), for: .normal)
            buttonL.addTarget(self, action: #selector(self.onClickButton), for: .touchUpInside)
            let xL = Int(button.frame.minX) - 70
            buttonL.frame = CGRect(x: xL, y: y, width: 60, height: 60)
            buttonL.tag = (3 * i) + 1
            buttonL.tintColor = .systemBlue
            view.addSubview(buttonL)

            let buttonR = UIButton(type: .custom)
            buttonR.setImage(UIImage(named: "mark-none.png"), for: .normal)
            buttonR.addTarget(self, action: #selector(self.onClickButton), for: .touchUpInside)
            let xR = Int(button.frame.maxX) + 10
            buttonR.frame = CGRect(x: xR, y: y, width: 60, height: 60)
            buttonR.tag = (3 * i) + 3
            buttonR.tintColor = .systemBlue
            view.addSubview(buttonR)
            
            buttons.append(buttonL)
            buttons.append(button)
            buttons.append(buttonR)
        }
        
        let clear = UIButton()
        clear.frame = CGRect(x: 0, y: turn.frame.maxY + 280, width: 250, height: 35)
        clear.addTarget(self, action: #selector(self.onClickClear), for: .touchUpInside)
        clear.center.x = view.center.x
        clear.setTitle("Clear", for: .normal)
        clear.setTitleColor(.systemBlue, for: .normal)
        
        view.addSubview(clear)
    }
    
    @objc func onClickClear(sender: UIButton) {
        for button in buttons {
            button.setImage(UIImage(named: "mark-none"), for: .normal)
            button.tintColor = .systemBlue
        }
        blocks = Array.init(repeating: .blank, count: 9)
        currPlayer = .x
        gameState = .playing
        self.didUpdate(state: gameState, button: buttons[0], comb: [])
    }
    
    @objc func onClickButton(sender: UIButton) {
        if (blocks[sender.tag - 1] == .blank && gameState == .playing) {
//            print(currPlayer)
//            print(self.currPlayer)
            hapticEngine.impactOccurred()
            blocks[sender.tag - 1] = currPlayer
//            print(blocks)
//            var endGame = false
            DispatchQueue.main.async {
//                print(self.currPlayer)
                self.didUpdate(state: self.currPlayer, button: sender)
//                endGame =
            }
//            self.checkStatus(sender)

//            if (!endGame) {
//                self.onComputerTurn()
//                print("here")
//
//            }
            
        } else if (gameState == .playing) {
            turn.text = "Invalid Move"
            turn.textColor = .systemRed
        }
    }
    
    // returns true if end game and false otherwise
    func checkStatus(_ sender: UIButton) -> Bool {
        var endGame = false
        var winningComb: [UIButton] = []
        for comb in winComb {
            endGame = (blocks[comb[0]] == blocks[comb[1]] && blocks[comb[0]] == blocks[comb[2]] && blocks[comb[0]] != .blank)
            if (endGame) {
                winningComb = [buttons[comb[0]], buttons[comb[1]], buttons[comb[2]]]
                break
            }
        }
        gameState = endGame ? (currPlayer == .x ? .win : .lose) : .playing
        if (!blocks.contains(.blank) && gameState == .playing) {
            gameState = .draw
        }
        if (gameState == .playing) {
            currPlayer = currPlayer == .x ? .o : .x
            self.didUpdate(state: .playing, button: sender, comb: [])
        } else {
            self.didUpdate(state: gameState, button: sender, comb: winningComb)

            let pathWin = Bundle.main.path(forResource: "win.wav", ofType:nil)!
            let urlWin = URL(fileURLWithPath: pathWin)
            let pathLose = Bundle.main.path(forResource: "lose.wav", ofType:nil)!
            let urlLose = URL(fileURLWithPath: pathLose)

            do {
                if (gameState == .win) {
                winSoundEffect = try AVAudioPlayer(contentsOf: urlWin)
                winSoundEffect?.play()
                } else if (gameState == .lose) {
                    loseSoundEffect = try AVAudioPlayer(contentsOf: urlLose)
                    loseSoundEffect?.play()
                }
            } catch {}
        }
        return endGame
    }
    
//    func onComputerTurn() {
////        var bestScore = Int.min;
////        var move = -1
////        for i in 0...8 {
////            if (blocks[i] == .blank) {
////                blocks[i] = .o
////                let score = minimax(blocks, 0, false)
////                blocks[i] = .blank
////                if (score > bestScore) {
////                  bestScore = score;
////                  move = i;
////                }
////            }
////        }
//        let move = anotherMinimax(blocks, .o)
//
//        blocks[move] = .o;
//        DispatchQueue.main.async {
//            print(self.blocks)
//            self.didUpdate(state: self.currPlayer, button: self.buttons[move])
//        }
//    }
    // This will return the best possible move for the player
    
        func winning(_ board: [BlockState], _ player: BlockState) -> Bool {
         if (
         (board[0] == player && board[1] == player && board[2] == player) ||
         (board[3] == player && board[4] == player && board[5] == player) ||
         (board[6] == player && board[7] == player && board[8] == player) ||
         (board[0] == player && board[3] == player && board[6] == player) ||
         (board[1] == player && board[4] == player && board[7] == player) ||
         (board[2] == player && board[5] == player && board[8] == player) ||
         (board[0] == player && board[4] == player && board[8] == player) ||
         (board[2] == player && board[4] == player && board[6] == player)
         ) {
         return true;
         } else {
         return false;
         }
        }
        
        
        func onComputerTurn() {
           // AI to make its turn
            var bestScore = Int.min;
                   var move = -1;
            for i in 0...8 {
                if (blocks[i] == .blank) {
                    blocks[i] = .o;
                  let score = minimax(&blocks, 0, false);
                    blocks[i] = .blank;
                  if (score > bestScore) {
                    bestScore = score;
                    move = i;
                  }
                }
            }
            
            print(move)
            blocks[move] = .o;
            DispatchQueue.main.async {
//                            print(self.blocks)
                            self.didUpdate(state: self.currPlayer, button: self.buttons[move])
                        }
//            printBoard(board)
//            print("your turn")
        }

        func minimax(_ board: inout [BlockState], _ depth: Int, _ isMaximizing: Bool) -> Int {
    //        if let score = checkWin(board) {
    //            return score
    //        }
            if (winning(board, .x)) {
                return -1
            } else if (winning(board, .o)) {
                return 1
            } else if (!board.contains(.blank)) {
                return 0
            }
            
            
//            print("----nonrealupper----")
//            printBoard(board)
//            print("----nonreallower----")
          if (isMaximizing) {
//            print("max true")
            var bestScore = Int.min;
            for i in 0...8 {
                if (board[i] == .blank) {
                    board[i] = .o;
                  let score = minimax(&board, depth + 1, false);
                    board[i] = .blank;
//                print("\(i) score \(score)")
//                print("\(i) bestscore \(bestScore)")
                  bestScore = max(score, bestScore);
//                print("\(i) newbestscore \(bestScore)")
                }
            }
            return bestScore;
          } else {
//            print("max false")
            var bestScore = Int.max;
            for i in 0...8 {
                if (board[i] == .blank) {
                    board[i] = .x;
                  let score = minimax(&board, depth + 1, true);
                    board[i] = .blank;
//                print("\(i) score \(score)")
//                print("\(i) bestscore \(bestScore)")
                  bestScore = min(score, bestScore);
//                print("\(i) newbestscore \(bestScore)")
                }
            }
            return bestScore;
          }
        }

    
    
    
//        func onComputerTurn() {
//
//        var bestVal = -1000;
//        var bestMove = -1;
//
//        // Traverse all cells, evaluate minimax function for
//        // all empty cells. And return the cell with optimal
//        // value.
//            for i in 0...8 {
//                // Check if cell is empty
//                if (blocks[i] == .blank)
//                {
//                    // Make the move
//                    blocks[i] = .o;
//
//                    // compute evaluation function for this
//                    // move.
//                    var moveVal = minimax(&blocks, 0, false);
//
//                    // Undo the move
//                    blocks[i] = .blank;
//
//                    // If the value of the current move is
//                    // more than the best value, then update
//                    // best/
//                    if (moveVal > bestVal)
//                    {
//                        bestMove = i
//                        bestVal = moveVal;
//                    }
//            }
//        }
//
////        return bestMove;
//            let move = bestMove
//
//            blocks[move] = .o;
//            DispatchQueue.main.async {
//                print(self.blocks)
//                self.didUpdate(state: self.currPlayer, button: self.buttons[move])
//            }
//    }
//
//    func minimax(_ board : inout [BlockState], _ depth:Int ,_ isMax: Bool) -> Int
//    {
//        if let score = checkWin(board) {
//            return score
//        }
//
//        // If this maximizer's move
//        if (isMax)
//        {
//        var best = -1000;
//
//            // Traverse all cells
//            for i in 0...8 {
//                    // Check if cell is empty
//                if (board[i] == .blank)
//                    {
//                        // Make the move
//                        board[i] = .o;
//
//                        // Call minimax recursively and choose
//                        // the maximum value
//                        best = max( best,
//                            minimax(&board, depth+1, !isMax) );
//
//                        // Undo the move
//                        board[i] = .blank;
//                    }
//
//            }
//            return best;
//        }
//
//        // If this minimizer's move
//        else
//        {
//            var best = 1000;
//
//            // Traverse all cells
//            for i in 0...8 {
//                    // Check if cell is empty
//                if (board[i] == .blank)
//                    {
//                        // Make the move
//                        board[i] = .x;
//
//                        // Call minimax recursively and choose
//                        // the minimum value
//                        best = min(best,
//                               minimax(&board, depth+1, !isMax));
//
//                        // Undo the move
//                        board[i] = .blank;
//                    }
//
//            }
//            return best;
//        }
//    }
//
//
//
//    func getOppositePlayer(_ curr: BlockState) -> BlockState {
//        return curr == .o ? .x : .o
//    }
//
//
//
//
//    func checkWin (_ board: [BlockState]) -> Int? {
//        var endGame = false
//        var player: BlockState = .blank
//                for comb in winComb {
//                    endGame = (board[comb[0]] == board[comb[1]] && board[comb[0]] == board[comb[2]] && board[comb[0]] != .blank)
//                    if (endGame) {
//                        player = board[comb[0]]
//                    }
//                }
//
////        return player
//
//                if (endGame) {
////                    print(board)
//                    if (player == .x) {
//                        return -1
//                    } else if (player == .o) {
//                        return 1
//                    }
//                } else if (!board.contains(.blank)) {
//                    return 0
//                }
//        return nil
//    }

}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
