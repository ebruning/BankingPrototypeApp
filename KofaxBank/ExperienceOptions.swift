//
//  ExperienceOptions.swift
//  KofaxBank
//
//  Created by Rupali on 03/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import CoreFoundation

enum CaptureExperienceType: Int {
    case DOCUMENT_CAPTURE = 0,
    CHECK_CAPTURE,
    PASSPORT_CAPTURE
}

class ExperienceOptions: NSObject {
    var zoomMinFillFraction: CGFloat = 0.0
    var zoomMaxFillFraction: CGFloat = 0.0
    var movementTolerance: CGFloat = 0.0
    
    var edgeDetection: Int?
    
    
    var messages: ExperienceMessages?
    
    var stabilityThresholdEnabled: Bool?
    var pitchThresholdEnabled: Bool?
    var rollThresholdEnabled: Bool?
    var focusConstraintEnabled: Bool?

    var stabilityThreshold: Int = 0
    var pitchThreshold: Int = 0
    var rollThreshold: Int = 0
    var longAxisThreshold: Int = 0
    var shortAxisThreshold: Int = 0

    var staticFrameAspectRatio: Float = 0.0
    
    var doShowGuidingDemo: Bool?
    
    var tutorialSampleImage: UIImage?
    
    var documentSide: DocumentSide?
    
    var portraitMode: Bool?
    
    var captureExperienceType: CaptureExperienceType = CaptureExperienceType.DOCUMENT_CAPTURE

}
