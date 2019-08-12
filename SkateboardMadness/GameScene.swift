//
//  GameScene.swift
//  SkateboardMadness
//
//  Created by alekseykolesnik on 28/02/2019.
//  Copyright © 2019 User. All rights reserved.
//

import SpriteKit
import GameplayKit

//  Структура содержит разные физические категории
//  с помощью которых определяется столкновения и контакт обьектов друг с другом
struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum GameState {
        case notRunning
        case running
    }
    
    //  Enum содержащий положение секций по у
    enum BrickLevel: CGFloat {
        case low = 0.0
        case hight = 100.0
    }
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    //  Свойства для отслеживания результатов
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    
    // Создание секций тротуара
    var bricks = [SKSpriteNode]()
    
    // Массив алмазов
    var gems = [SKSpriteNode]()
    
    // Размер секций тротуара
    var bricksSize = CGSize.zero
    
    //  Текущий уровень определяет положение по оси у новых секций
    var brickLevel = BrickLevel.low
    
    //  Состояние игры
    var gameState = GameState.notRunning
    
    // Скорость движения секций тротуара
    var scrollSpeed: CGFloat = 5.0
    
    // Скорость героя на старте игры
    var startingScrollSpeed: CGFloat = 5.0
    
    //  Константа для гравитации
    let gravitySpeed: CGFloat = 1.5
    
    // Время последнего вызова для метода обновдения
    var lastUpdateTime: TimeInterval?
    
    // Спрайт героя
    let skater = Hero(imageNamed: "skater")
    
    
    /////////
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
     
        // Точка привязки в левом нижнем углу
        anchorPoint = CGPoint.zero
        
        // Загрузка и настройка положения фонового изображения
        let background = SKSpriteNode(imageNamed: "background")
        let midX = frame.midX
        let midY = frame.midY
        background.position = CGPoint(x: midX, y: midY)
        addChild(background)
        
        //  Добавляем текстовые поля с очками
        setupLabels()
        
        //MARK: - Добавление и настройка игрока на экран
        //  Создаем физическое тело персонажа и добавляем его к сцене
        skater.setupPhysicsBody()
        addChild(skater)
        
        //Добавляем распознователь нажатия что бы знать когда пользователь нажимает на экран
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        //  Добавляем слой меню с текстом "Нажмите что бы играть"
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLaeyr = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLaeyr.anchorPoint = CGPoint.zero
        menuLaeyr.position = CGPoint.zero
        menuLaeyr.zPosition = 30
        menuLaeyr.name = "menuLayer"
        menuLaeyr.display(message: "Нажмите, чтобы играть", score: nil)
        addChild(menuLaeyr)
        
    }
    ////////
    
    //MARK: - Сброс первоначальных настроек героя
    func resetHero() {
        
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    
    func setupLabels() {
        
        //  Надпись "очки" в верхнем левом углу
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "очки")
        scoreTextLabel.position = CGPoint(x: 40.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left  // выравнивание текстовых полей по левому краю
        scoreTextLabel.fontName = "Courier - Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        //  Надпись с количеством очков в левом верхнем углу под надписью очки
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 40.0, y: frame.size.height - 40)
        scoreLabel.horizontalAlignmentMode = .left  // выравнивание текстовых полей по левому краю
        scoreLabel.fontName = "Courier - Bold"
        scoreLabel.name = "scoreLabel"
        scoreLabel.fontSize = 18.0
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        //  Надпись "лучший результат" в правом верхнем углу
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "лучший результат")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 40.0, y: frame.size.height - 20)
        highScoreTextLabel.horizontalAlignmentMode = .right  // выравнивание текстовых полей по левому краю
        highScoreTextLabel.fontName = "Courier - Bold"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        //  Надпись с максимумом очков в правом верхнем углу
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 40.0, y: frame.size.height - 40)
        highScoreLabel.horizontalAlignmentMode = .right  // выравнивание текстовых полей по левому краю
        highScoreLabel.fontName = "Courier - Bold"
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    //  Обновление очков
    func updateScoreLableText() {
        
        if let scoreLable = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLable.text = String(format: "%04d", score)
        }
    }
    
    func updateHighScoreLabelText() {
        
        if let highScoreLabelText = childNode(withName: "highScoreLabel") as? SKLabelNode {
            
            highScoreLabelText.text = String(format: "%04d", highScore)
        }
    }
    
    //MARK: - Функция создания секций тротуара
    func spawnBrick(atPosition position: CGPoint) -> SKSpriteNode {
        
        // Создаем спрайт секции и возвращаем его к сцене
        let  brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        
        // Обновляем свойство brickSize реальным размерами секций
        bricksSize = brick.size
        
        // Добавляем секцию к массиву секций
        bricks.append(brick)
        
        //  Настройка физического тела секции
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        // Возвразаем секцию вызывающему коду
        return brick
    }
    
    // MARK: - Добавление алмазов
    func spawnGem(atPosition position: CGPoint) {
        
        //  Создаем спрайт для алмаза и добавляем его к сцене
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        //  Добавляем новый гем к массиву гемов
        gems.append(gem)
    }
    
    //  Удаление алмазов
    func removeGems(_ gem: SKSpriteNode) {
        
        gem.removeFromParent()
        
        if let gemIndex = gems.firstIndex(of: gem) {
            gems.remove(at: gemIndex)
        }
    }
    
    //MARK: - Метод обновления положений секций
    func updateBrick(withScrollAmount currentScrollAmount: CGFloat) {
        
        // Отслеживаем самое большое положение секций по оси x для всех существующих секций
        var farthestRightBrickX: CGFloat = 0.0
        
        for brick in bricks {
            
            let newX = brick.position.x - currentScrollAmount
            
            // Если секция сместилась за экран слева то удалить ее
            if newX < -bricksSize.width {
                brick.removeFromParent()
                
                if let brickIndex = bricks.firstIndex(of: brick) {
                    bricks.remove(at: brickIndex)
                }
            } else {
                
                // Для секции оставшийся на экране обновляем положение
                brick.position = CGPoint(x: newX, y: brick.position.y)
                
                // Обновляем значение для крайней правой секции
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        
        // Цикл while обеспечивает непрерывное наполение экрана новыми секциями
        while farthestRightBrickX < frame.width {
            
            var brickX = farthestRightBrickX + bricksSize.width + 1.0
            let brickY = (bricksSize.height / 2) + brickLevel.rawValue
            
            // Иногда вставляем разрывы в секции, что бы было через что герою перепрыгивать
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 2 && score > 10 {
                
                // шанс на возникновение разрыва 5%
                let gap = 20.0 * scrollSpeed
                brickX += gap
                
                //  На каждом разрыве добавляем алмаз
                let randomGemYAMount = CGFloat(arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAMount
                let newGemX = brickX - gap / 2
                
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
                
            } else if randomNumber < 4 && score > 20 {
                
                //  В игре имеется 5% шанс на изменения высоты секции
                if brickLevel == .hight {
                    brickLevel = .low
                } else if brickLevel == .low {
                    brickLevel = .hight
                }
            }
            
            
            // Добавляем новую секцию и обновляем положение самой правой
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    func updateGems(withScrollAmoint currentScrollAmount: CGFloat) {
        
        for gem in gems {
            
            //  Обновляем положение каждого алмаза
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            
            //  Удаляем алмазы ушедшие с экрана
            if gem.position.x < 0.0 {
                removeGems(gem)
            }
        }
    }
    
    func updateHero() {
        
        //  Определяем находиться ли герой на земле
        if let velocityY = skater.physicsBody?.velocity.dy {
            
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        
        // Check if the game should end
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
        
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        
        if isOffScreen || isTippedOver {
            gameOver()
        }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        
        // Увеличение очков при беспройгрышном прохождении
        // Обновлятся каждую секунду
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 1.0 {
            
            // Увеличиваем количество очков
            score += Int(scrollSpeed)
            
            //  Писваиваем свойству lastScoreUpdateTime значение текущего времени
            lastScoreUpdateTime = currentTime
            
            updateScoreLableText()
        }
    }
    
    //MARK: - Начало игры
    func startGame() {
        
        gameState = .running
        
        // Возвращение к начальным условиям при старте новой игры
        resetHero()
        
        score = 0
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        
        for brick in bricks {
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGems(gem)
        }
    }
    
    //  Конец игры
    func gameOver() {
        
        gameState = .notRunning
        
        if score > highScore {
            
            highScore = score
            updateHighScoreLabelText()
        }
        
        //  Показываем надпись "игра окончена"
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint.zero
        menuLayer.position = CGPoint.zero
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Game Over!", score: score)
        addChild(menuLayer)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameState != .running {
            return
        }

        // Определяем время прошедшее с последнего момента вызова update
        var elapsedTime: TimeInterval = 0.0
        
        //  Увеличиваем скорость героя со временем
        scrollSpeed += 0.006
        
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
        
        // Расчитываем на сколько далеко должны сдвинуться обьекты при данном обновлении
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        // Обновление положения секций и алмазов и обновляем очки
        updateBrick(withScrollAmount: currentScrollAmount)
        updateGems(withScrollAmoint: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
        
        updateHero()
    }
    
    //  Метод для распознования жестов
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        
        if gameState == .running {
            
            //  Скейтбордистка прыгает если происходит нажатие на экран пока персонаж на земле
            if skater.isOnGround {
                
                skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
                run(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
            }
        } else {
            
            //  Если игра не запущена по тапу начнется новая игра
            if let menuLayer: SKSpriteNode = childNode(withName: "menuLayer") as? SKSpriteNode {
                
                menuLayer.removeFromParent()
            }
            
            startGame()
        }
    }
    
    //MARK: -  SKPhysicsContactDelegate Methods
    func didBegin(_ contact: SKPhysicsContact) {
        
        //Проверяем есть ли контакт между героем и секцией
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            
            skater.isOnGround = true
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            
            //  Герой коснулся алмаза и мы его убираем
            if let gem = contact.bodyB.node as? SKSpriteNode {
                removeGems(gem)
                
                //  Очки за сбор алмазов
                score += 50
                updateScoreLableText()
                run(SKAction.playSoundFileNamed("gem.wav", waitForCompletion: false))
            }
        }
    }
}
