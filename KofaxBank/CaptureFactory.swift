//
//  CaptureFactory.swift
//  KofaxBank
//
//  Created by Rupali on 03/08/17.
//  Copyright © 2017 kofax. All rights reserved.
//

import UIKit

class CaptureFactory: NSObject {

    class func getImageCaptureControl(frame: CGRect) -> kfxKUIImageCaptureControl {
        kfxKUIImageCaptureControl.initializeControl()
        let captureController: kfxKUIImageCaptureControl = kfxKUIImageCaptureControl.init(frame: frame)
        return captureController
    }
    
    class func getCaptureExperience(captureControl: kfxKUIImageCaptureControl, experienceOptions: ExperienceOptions) -> kfxKUIDocumentBaseCaptureExperience {
        
        switch experienceOptions.captureExperienceType {
        
        case CaptureExperienceType.CHECK_CAPTURE:

            let checkCaptureExperience: kfxKUICheckCaptureExperience = kfxKUICheckCaptureExperience.init(captureControl: captureControl, criteria: CaptureFactory.createCheckCaptureExperienceCriteria(experienceOptions: experienceOptions))
            return checkCaptureExperience
            
        default:
            let documentCaptureExperience: kfxKUIDocumentCaptureExperience = kfxKUIDocumentCaptureExperience.init(captureControl: captureControl, criteria: CaptureFactory.createDocumentCaptureExperienceCriteria(experienceOptions: experienceOptions))
            return documentCaptureExperience
        }
    }

    
    //MARK: - CheckCaptureExperience Methods
    
    class func createCheckCaptureExperienceCriteria(experienceOptions: ExperienceOptions) -> kfxKUICheckCaptureExperienceCriteriaHolder {

        let checkCaptureExperienceCriteria: kfxKUICheckCaptureExperienceCriteriaHolder = kfxKUICheckCaptureExperienceCriteriaHolder.init()
        
        checkCaptureExperienceCriteria.stabilityThreshold = Int32(experienceOptions.stabilityThreshold)
        checkCaptureExperienceCriteria.stabilityThresholdEnabled = experienceOptions.stabilityThresholdEnabled!
        checkCaptureExperienceCriteria.rollThreshold = Int32(experienceOptions.rollThreshold)
        checkCaptureExperienceCriteria.pitchThreshold = Int32(experienceOptions.pitchThreshold)
        checkCaptureExperienceCriteria.pitchThresholdEnabled = experienceOptions.pitchThresholdEnabled!
        checkCaptureExperienceCriteria.rollThresholdEnabled = experienceOptions.rollThresholdEnabled!
        checkCaptureExperienceCriteria.focusConstraintEnabled = experienceOptions.focusConstraintEnabled!
        
        checkCaptureExperienceCriteria.checkDetectionSettings = CaptureFactory.createCheckDetectionSettings(experienceOptions: experienceOptions)

        return checkCaptureExperienceCriteria;
    }
    
    
    private class func createCheckDetectionSettings(experienceOptions: ExperienceOptions) -> kfxKEDCheckDetectionSettings {
        let checkDetectionSettings: kfxKEDCheckDetectionSettings = kfxKEDCheckDetectionSettings.init()
        checkDetectionSettings.zoomMinFillFraction = experienceOptions.documentSide == DocumentSide.BACK ? 0.75 : 0.70
        checkDetectionSettings.zoomMaxFillFraction = 1.1;
        checkDetectionSettings.checkSide = experienceOptions.documentSide == DocumentSide.BACK ? KED_CHECK_SIDE_BACK : KED_CHECK_SIDE_FRONT;
        checkDetectionSettings.targetFramePaddingPercent = 9.0;
        checkDetectionSettings.targetFrameAspectRatio = CGFloat(experienceOptions.staticFrameAspectRatio);
        return checkDetectionSettings;
    }


    //MARK: - DocumentCaptureExperience Methods

    class func createDocumentCaptureExperienceCriteria(experienceOptions: ExperienceOptions) -> kfxKUIDocumentCaptureExperienceCriteriaHolder {
        
        let documentCaptureExperienceCriteria: kfxKUIDocumentCaptureExperienceCriteriaHolder = kfxKUIDocumentCaptureExperienceCriteriaHolder.init()
        documentCaptureExperienceCriteria.stabilityThreshold = Int32(experienceOptions.stabilityThreshold)
        documentCaptureExperienceCriteria.stabilityThresholdEnabled = experienceOptions.stabilityThresholdEnabled!
        documentCaptureExperienceCriteria.rollThreshold = Int32(experienceOptions.rollThreshold)
        documentCaptureExperienceCriteria.rollThresholdEnabled = experienceOptions.rollThresholdEnabled!
        documentCaptureExperienceCriteria.pitchThreshold = Int32(experienceOptions.pitchThreshold)
        documentCaptureExperienceCriteria.pitchThresholdEnabled = experienceOptions.pitchThresholdEnabled!
        documentCaptureExperienceCriteria.focusConstraintEnabled = experienceOptions.focusConstraintEnabled!
        documentCaptureExperienceCriteria.documentDetectionSettings = self.createDocumentDetectionSettings(experienceOptions: experienceOptions)
        
        return documentCaptureExperienceCriteria
    }


    class func createDocumentDetectionSettings(experienceOptions: ExperienceOptions) -> kfxKEDDocumentDetectionSettings {
        let documentDetectionSettings: kfxKEDDocumentDetectionSettings = kfxKEDDocumentDetectionSettings.init()
        
        documentDetectionSettings.longAxisThreshold = Int32(experienceOptions.longAxisThreshold)
        documentDetectionSettings.shortAxisThreshold = Int32(experienceOptions.shortAxisThreshold)
        
        var aspectRatio: CGFloat = 0.0
        
        if experienceOptions.portraitMode! {
            aspectRatio = CGFloat((experienceOptions.staticFrameAspectRatio > 1) ? 1.0/experienceOptions.staticFrameAspectRatio : experienceOptions.staticFrameAspectRatio)
        }
            else {
            aspectRatio = CGFloat((experienceOptions.staticFrameAspectRatio < 1 && experienceOptions.staticFrameAspectRatio != 0) ? 1.0/experienceOptions.staticFrameAspectRatio : experienceOptions.staticFrameAspectRatio)
            }
        
        documentDetectionSettings.targetFrameAspectRatio = aspectRatio
        documentDetectionSettings.edgeDetection = kfxKEDDocumentEdgeDetection.init(rawValue: experienceOptions.edgeDetection!)!
        
        documentDetectionSettings.targetFramePaddingPercent = 9.0
        
        documentDetectionSettings.zoomMinFillFraction = experienceOptions.zoomMinFillFraction
        documentDetectionSettings.zoomMaxFillFraction = experienceOptions.zoomMaxFillFraction
        
        if experienceOptions.movementTolerance != 0 {
            documentDetectionSettings.horizontalMovementTolerance = experienceOptions.movementTolerance
            documentDetectionSettings.verticalMovementTolerance = experienceOptions.movementTolerance
        }
        
        return documentDetectionSettings
    }
    
}
