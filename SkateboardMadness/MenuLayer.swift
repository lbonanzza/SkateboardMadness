//
//  MenuLayer.swift
//  SkateboardMadness
//
//  Created by alekseykolesnik on 10/03/2019.
//  Copyright © 2019 User. All rights reserved.
//

import SpriteKit

class MenuLayer: SKSpriteNode {

    //  Отоброжает сообщение и иногда текущий счет
    func display(message: String, score: Int?) {
        
        //  Создаем надпись сообшения используя передаваемое сообщение
        let messageLabel: SKLabelNode = SKLabelNode(text: message)
        
        //  Устанавливаем начальное положение надписи в левой стороне слоя меню
        let messageX = -frame.width
        let messageY = frame.height / 2.0
        messageLabel.position = CGPoint(x: messageX, y: messageY)
        
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Courier - Bold"
        messageLabel.fontSize = 48.0
        messageLabel.zPosition = 20
        addChild(messageLabel)
        
        //  Анимируем движения надписи сообщения к центру экрана
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLabel.run(messageAction)
        
        //  Если количество очков было переданно в метод, то показываем очки на экране
        if let scoreToDisplay = score {
            
            //  Создаем текст с количеством очков из score
            let scoreString = String(format: "Очки:%04d", scoreToDisplay)
            let scoreLable: SKLabelNode = SKLabelNode(text: scoreString)
            
            //  Задаем начальное положение надписи справа от слоя меню
            let scoreLableX = frame.width
            let scoreLableY = messageLabel.position.y - messageLabel.frame.height
            scoreLable.position = CGPoint(x: scoreLableX, y: scoreLableY)
            scoreLable.horizontalAlignmentMode = .center
            scoreLable.fontName = "Courier - Bold"
            scoreLable.fontSize = 32.0
            scoreLable.zPosition = 20
            addChild(scoreLable)
            
            //  Анимируем движение надписи в центр экрана
            let scoreAction = SKAction.moveTo(x: finalX, duration: 0.3)
            scoreLable.run(scoreAction)
        }
    }
}
