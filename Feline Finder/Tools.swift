//
//  DetailCellList.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/21/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import Foundation

class Tool {
    var pet: Pet?
    var icon = ""
    var visible = true
    var cellType: CellType = .tool
    func isVisible(mode: Mode) -> Bool {
        return visible
    }
    func performAction() {
        print (icon)
    }
    init(pet: Pet) {
        self.pet = pet
    }
}

class directionsTool: Tool {
    override init(pet: Pet) {
        super.init(pet: pet)
        icon = "🌎"
        cellType = .tool
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .tools
    }
    override func performAction() {
        super.performAction()
    }
}

class descriptionTool: Tool {
    var description = ""
    override init(pet: Pet) {
        super.init(pet: pet)
        icon = "📄"
        cellType = .tool
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .tools
    }
    override func performAction() {
        super.performAction()
    }
}

class emailTool: Tool {
    var emailAddress = ""
    override init(pet: Pet) {
        super.init(pet: pet)
        icon = "📧"
        cellType = .tool
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .tools
    }
    override func performAction() {
        super.performAction()
    }
}

class telephoneTool: Tool {
    var phoneNumber = ""
    override init(pet: Pet) {
        super.init(pet: pet)
        icon = "☎️"
        cellType = .tool
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .tools
    }
    override func performAction() {
        super.performAction()
    }
}

class shareTool: Tool {
    var description = ""
    override init(pet: Pet) {
        super.init(pet: pet)
        icon = "🔗"
        cellType = .tool
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .tools
    }
    override func performAction() {
        super.performAction()
    }
}

class statsTool: Tool {
    override init(pet: Pet) {
        super.init(pet: pet)
        icon = "📊"
        cellType = .tool
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .tools
    }
    override func performAction() {
        super.performAction()
    }
}

class imageTool: Tool {
    var thumbNail: picture2
    var photo: picture2
    init(pet: Pet, thumbNail: picture2, photo: picture2) {
        self.thumbNail = thumbNail
        self.photo = photo
        super.init(pet: pet)
        icon = "🖼️"
        cellType = .image
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .media
    }
    override func performAction() {
        super.performAction()
    }
}

class youTubeTool: Tool {
    var video: video
    init(pet: Pet,  video: video) {
        self.video = video
        super.init(pet: pet)
        icon = "🎞️"
        cellType = .video
    }
    override func isVisible(mode: Mode) -> Bool {
        visible = super.isVisible(mode: mode)
        return mode == .media
    }
    override func performAction() {
        super.performAction()
    }
}


enum Mode: String {
    case tools = "tools"
    case media = "media"
}

enum CellType: String {
    case tool = "tool"
    case image = "image"
    case video = "video"
}

class Tools: Sequence, IteratorProtocol {
    typealias Element = Tool
    
    private var list = [Tool]()
    private var tools = [Tool]()
    private var currentIndex: Int = 0

    var mode: Mode = .media
    
    init(pet: Pet) {
        list = []
        list.append(descriptionTool(pet: pet))
        list.append(emailTool(pet: pet))
        list.append(shareTool(pet: pet))
        list.append(directionsTool(pet: pet))
        list.append(telephoneTool(pet: pet))
        list.append(directionsTool(pet: pet))
        
        let thumbNails = pet.getAllImagesObjectsOfACertainSize("pnt")
        let photos = pet.getAllImagesObjectsOfACertainSize("x")
        for i in 0..<photos.count {
            list.append(imageTool(pet: pet,
                                  thumbNail: thumbNails[i],
                                  photo: photos[i]))
        }
        
        for video in pet.videos {
            list.append(youTubeTool(pet: pet,
                                  videoUrl: URL(string: video.videoUrl)!,
                                  thumbNailURL: URL(string: video.urlThumbnail)!,
                                  youTubeID: video.videoID))
        }
        
        tools = getTools()
    }
    
    func getTools() -> [Tool] {
        var tools = [Tool]()
        for item in list {
            if item.isVisible(mode: mode) {
                tools.append(item)
            }
        }
        return tools
    }
    
    func switchMode() {
        if mode == .media {
            mode = .tools
        } else {
            mode = .media
        }
        currentIndex = 0
        tools = getTools()
    }
    
    subscript(index: Int) -> Tool {
        return tools[index]
    }
    
    func count() -> Int {
        return tools.count
    }
    
    func images() -> [imageTool] {
        var images = [imageTool]()
        for tool in tools {
            if tool.cellType == .image {
                images.append(tool as! imageTool)
            }
        }
        return images
    }
    
    func next() -> Tool? {
        if currentIndex >= tools.count {return nil}
        currentIndex += 1
        return tools[currentIndex]
    }
}
