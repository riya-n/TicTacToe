//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import AVFoundation

class MyViewController : UIViewController {
    
    // TODO: to change it you could make it a 4x4 grid but still need 3 in a row to win
    
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
            case .x: button.setImage(UIImage(named: "mark-x.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
            case .o: button.setImage(UIImage(named: "mark-o.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
            case .blank: button.setImage(UIImage(named: "mark-none.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    func didUpdate(state: GameState, button: UIButton, comb: [UIButton]) {
        switch state {
            case .playing: turn.text = currPlayer == .x ? "Your Turn" : ""; turn.textColor = .label
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
        
//        let score = UILabel()
        score.frame = CGRect(x: 0, y: title.frame.maxY + 25, width: 150, height: 25)
        score.center.x = view.center.x
        score.textAlignment = .center
        score.text = "Your Score: 0"
        score.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.thin)
        
        view.addSubview(score)
        
//        let turn = UILabel()
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
            button.tag = (3 * i) + 1
            button.tintColor = .systemBlue
            view.addSubview(button)

            let buttonL = UIButton(type: .custom)
            buttonL.setImage(UIImage(named: "mark-none.png"), for: .normal)
            buttonL.addTarget(self, action: #selector(self.onClickButton), for: .touchUpInside)
            let xL = Int(button.frame.minX) - 70
            buttonL.frame = CGRect(x: xL, y: y, width: 60, height: 60)
            buttonL.tag = (3 * i)
            buttonL.tintColor = .systemBlue
            view.addSubview(buttonL)

            let buttonR = UIButton(type: .custom)
            buttonR.setImage(UIImage(named: "mark-none.png"), for: .normal)
            buttonR.addTarget(self, action: #selector(self.onClickButton), for: .touchUpInside)
            let xR = Int(button.frame.maxX) + 10
            buttonR.frame = CGRect(x: xR, y: y, width: 60, height: 60)
            buttonR.tag = (3 * i) + 2
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
        if (blocks[sender.tag] == .blank && gameState == .playing) {
            hapticEngine.impactOccurred()
            blocks[sender.tag] = currPlayer
            self.didUpdate(state: currPlayer, button: sender)
            let endGame = self.checkStatus(sender)
            if (!endGame) {
                self.onComputerTurn()
                
            }
            
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
    
    func onComputerTurn() {
        
        // also need to check that the player isnt about to win
        
        var computerTags = [Int]()
        var playerTags = [Int]()
        var emptyTags = [Int]()
        var possibleMoves = [Int]()
        
        for (i, block) in blocks.enumerated() {
            if (block == .o) {
                computerTags.append(i)
            } else if (block == .x) {
                playerTags.append(i)
            } else {
                emptyTags.append(i)
            }
        }
        
        for comb in winComb {
            if ((comb.filter{ playerTags.contains($0) }).count == 0) {
                possibleMoves += comb.filter{ !computerTags.contains($0) }
            }
        }
        
        if (possibleMoves.count == 0) {
            possibleMoves = emptyTags
        }
        
        let i = possibleMoves.randomElement()!
        blocks[i] = currPlayer
        let seconds = 2.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.didUpdate(state: self.currPlayer, button: self.view.viewWithTag(i) as! UIButton)
            self.checkStatus(self.view.viewWithTag(i) as! UIButton)
        }
        
    }

}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
