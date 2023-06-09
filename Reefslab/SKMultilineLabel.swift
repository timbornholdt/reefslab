//
//  SKMultilineLabel.swift
//
//  Created by Craig on 10/04/2015.
//  Copyright (c) 2015 Interactive Coconut.
//  MIT License, http://www.opensource.org/licenses/mit-license.php
//

/*   USE:
 (most component parameters have defaults)
 let multiLabel = SKMultilineLabel(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", labelWidth: 250, pos: CGPoint(x: size.width / 2, y: size.height / 2))
 self.addChild(multiLabel)
 */

import SpriteKit

class SKMultilineLabel: SKNode {

    var labelWidth: Int { didSet { update() } }
    var labelHeight: Int = 0
    var text: String { didSet { update() } }
    var fontName: String {didSet {update() } }
    var fontSize: CGFloat { didSet { update() } }
    var pos: CGPoint { didSet { update() } }
    var fontColor: UIColor { didSet { update() } }
    var leading: Int { didSet { update() } }
    var alignment: SKLabelHorizontalAlignmentMode { didSet { update() } }
    var dontUpdate = false
    var shouldShowBorder: Bool = false { didSet { update() } }

    var rect: SKShapeNode?
    var labels: [SKLabelNode] = []

    init(text: String, labelWidth: Int, pos: CGPoint, fontName: String = "ChalkboardSE-Regular",
         fontSize: CGFloat = 10, fontColor: UIColor = UIColor.white, leading: Int? = nil,
         alignment: SKLabelHorizontalAlignmentMode = .center, shouldShowBorder: Bool = false) {
        self.text = text
        self.labelWidth = labelWidth
        self.pos = pos
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.leading = leading ?? Int(fontSize)
        self.shouldShowBorder = shouldShowBorder
        self.alignment = alignment

        super.init()

        self.update()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    fileprivate func clearLabels() {
        if labels.count > 0 {
            for label in labels {
                label.removeFromParent()
            }
            labels = []
        }
    }

    fileprivate func createLabel(_ lineCount: Int) -> SKLabelNode {
        // creation of the SKLabelNode itself
        let label = SKLabelNode(fontNamed: fontName)
        // name each label node so you can animate it if u wish
        label.name = "line\(lineCount)"
        label.horizontalAlignmentMode = alignment
        label.fontSize = fontSize
        label.fontColor = fontColor
        return label
    }

    //if you want to change properties without updating the text field,
    //set dontUpdate to false and call the update method manually.
    // swiftlint:disable cyclomatic_complexity
    func update() {
        guard !dontUpdate else { return }

        clearLabels()
        let separators = NSCharacterSet.whitespacesAndNewlines
        let words = (text as NSString).components(separatedBy: separators)
        var finalLine = false
        var wordCount = -1
        var lineCount = 0
        while !finalLine {
            lineCount += 1
            var lineLength = CGFloat(0)
            var lineString = ""
            var lineStringBeforeAddingWord = ""

            let label = createLabel(lineCount)

            while lineLength < CGFloat(labelWidth) {
                wordCount += 1
                if wordCount > words.count - 1 {
                    finalLine = true
                    break
                } else {
                    lineStringBeforeAddingWord = lineString
                    lineString = "\(lineString) \(words[wordCount])"
                    label.text = lineString
                    lineLength = label.frame.width
                }
            }
            if lineLength > 0 {
                wordCount -= 1
                if !finalLine {
                    lineString = lineStringBeforeAddingWord
                }
                label.text = lineString
                var linePos = pos
                if alignment == .left {
                    linePos.x -= CGFloat(labelWidth / 2)
                } else if alignment == .right {
                    linePos.x += CGFloat(labelWidth / 2)
                }
                linePos.y += CGFloat(-leading * lineCount)
                label.position = CGPoint(x:linePos.x, y:linePos.y )
                addChild(label)
                labels.append(label)
            }

        }
        labelHeight = lineCount * leading
        showBorder()
    }

    func showBorder() {
        guard shouldShowBorder else { return }
        if let rect = rect {
            removeChildren(in: [rect])
        }
        rect = SKShapeNode(rectOf: CGSize(width: labelWidth, height: labelHeight))
        if let rect = rect {
            rect.strokeColor = UIColor.white
            rect.lineWidth = 1
            rect.position = CGPoint(x: pos.x, y: pos.y - (CGFloat(labelHeight) / 2.0))
            addChild(rect)
        }
    }
}
