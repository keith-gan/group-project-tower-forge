//
//  GameMode.swift
//  TowerForge
//
//  Created by Vanessa Mae on 27/03/24.
//

import Foundation

struct GameResult {
    var variable: String
    var value: String
}

protocol GameMode {
    var modeName: String { get }
    static var modeDescription: String { get }
    var gameProps: [any GameProp] { get }
    var gameState: GameState { get set }
    var eventManager: EventManager { get set }
    func updateGame(deltaTime: TimeInterval)
    func getGameResults() -> [GameResult]
}
