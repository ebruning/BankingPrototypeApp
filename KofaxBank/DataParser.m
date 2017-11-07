
// This class acts as a parser to the app. It contains methods to parse any responses coming from webservice and also handles DL - Barcode parsing

#import "DataParser.h"
//#import "AamvaData.h"

@implementation DataParser

/*
-(void)parseBarcodeResult :(NSString*)metaData;
{
    if([metaData length] == 0)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(barcodeParsingFailed)])
            [self.delegate barcodeParsingFailed];
        
    }
    
    // This parser takes the decoded metadata and extracts fields like DLNumber, Name, Gender etc.
    // This parser is different from the parsing done by 'KMC SDK'.
    AamvaData * testBCParser = nil;
    if(metaData && [metaData length]){
        
        NSString *aamvaParserInput = [self decodeBase64:metaData];
        
        if([aamvaParserInput length]>19){
            
            NSRegularExpression *ansiSpaceRegEx = [NSRegularExpression regularExpressionWithPattern:@"ANSI\\s" options:NSRegularExpressionCaseInsensitive error:nil];
            NSTextCheckingResult *match = [ansiSpaceRegEx firstMatchInString:aamvaParserInput options:NSMatchingReportProgress range:NSMakeRange(0, [aamvaParserInput length])];
            BOOL isMatch = match != nil;
            
            if(!isMatch){
                ansiSpaceRegEx = [NSRegularExpression regularExpressionWithPattern:@"ANSI" options:NSRegularExpressionCaseInsensitive error:nil];
                
                aamvaParserInput = [ansiSpaceRegEx stringByReplacingMatchesInString:aamvaParserInput options:0 range:NSMakeRange(0, [aamvaParserInput length]) withTemplate:@"ANSI "];
            }
            
            testBCParser = [[AamvaData alloc] init:aamvaParserInput];
        }
    }
    
    
    
    // Formatting date of birth since the parser doesn't give a a proper format.
    NSDate *dobDate = [testBCParser parseDate:[testBCParser getElement:@"DBB"]];
    NSCalendar *currentCalender = [NSCalendar currentCalendar];
    
    NSDateComponents* components;
    NSString *dob;
    
    if(dobDate)
    {
        components = [currentCalender components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:dobDate];
        dob = [NSString stringWithFormat:@"%ld/%ld/%ld", (long)[components month],(long)[components day],(long)[components year]];
        
    }
    
    
    // Formatting zipcode since the parser doesn't give a proper format.
    NSString *zipCode = [testBCParser getElement:@"DAK"];
    //    if([zipCode length] > 5)
    //    {
    //        zipCode = [zipCode substringToIndex:5];
    //    }
    
    
    
    //Fill the information from here and pass it to another vc
    
    //    if(objData == nil)
    DLData* dlData = [[DLData alloc] init];
    

//     DAQ - driving license
//     DAA - customer full name
//     DAG - street
//     DAI - city
//     DAJ - address (two letters state code)
//     DAK - zipcode
//     DAR - driver license class code
//     DAS - driver license restriction code
//     DAT - driver license endorsement code
//     DAU - Customer height
//     DAW - customer weight (in lbs)
//     DAY - customer eye color
//     DAZ - customer hair color
//     DBA - driver license or id expiry date CCYYMMDD
//     DBB - customer date of birth
//     DBC - customer gender
//     DBD - DL or ID issue date
//     DBG - internal indicator codes (not used, for all records == 2)
//     DBH - organ Donor YES = 1, NO = 2
 
 
    dlData.dob = dob;
    dlData.zipCode = zipCode;
    
    dlData.drivinglicenseID = [testBCParser getElement:@"DAQ"];
    
    
    if([testBCParser getElement:@"DAA"]){
        dlData.name = [testBCParser getElement:@"DAA"];
        NSArray *nameArray;
        if([dlData.name rangeOfString:@","].location != NSNotFound) {
            nameArray = [dlData.name componentsSeparatedByString:@","];
            dlData.name = [nameArray componentsJoinedByString:@" "];
        }
        else if([dlData.name rangeOfString:@"@"].location != NSNotFound) {
            nameArray = [dlData.name componentsSeparatedByString:@"@"];
            dlData.name = [nameArray componentsJoinedByString:@" "];
        }
        else {
            dlData.name = [testBCParser getElement:@"DAA"];
        }
    }
    else if([testBCParser getElement:@"DCT"]){
        dlData.name = [testBCParser getElement:@"DCT"];
        NSArray *nameArray;
        if([dlData.name rangeOfString:@","].location != NSNotFound) {
            nameArray = [dlData.name componentsSeparatedByString:@","];
            dlData.name = [nameArray componentsJoinedByString:@" "];
        }
        else if([dlData.name rangeOfString:@"@"].location != NSNotFound) {
            nameArray = [dlData.name componentsSeparatedByString:@"@"];
            dlData.name = [nameArray componentsJoinedByString:@" "];
        }
        else {
            dlData.name = [testBCParser getElement:@"DCT"];
        }
        
    }
    else {
        
        if([[self decodeBase64:metaData] length]<19)
            dlData.name = @"";
        else if([testBCParser getElement:@"DAC"] && [testBCParser getElement:@"DCS"]){
            dlData.name = [NSString stringWithFormat:@"%@ %@",[testBCParser getElement:@"DAC"],[testBCParser getElement:@"DCS"]];
        }else if([testBCParser getElement:@"DAC"]){
            dlData.name = [NSString stringWithFormat:@"%@",[testBCParser getElement:@"DAC"]];
        }else if([testBCParser getElement:@"DCS"]){
            dlData.name = [NSString stringWithFormat:@"%@",[testBCParser getElement:@"DCS"]];
        }
    }
    
    dlData.street = [testBCParser getElement:@"DAG"];
    dlData.city = [testBCParser getElement:@"DAI"];
    dlData.state = [testBCParser getElement:@"DAJ"];
    dlData.gender = [testBCParser getElement:@"DBC"];
    
    
    // dlData.imageProcessed = [UIImage imageWithContentsOfFile:strLatestProcessedImagePath];
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(barcodeParsed:)])
        [self.delegate barcodeParsed:dlData];
}
*/

//TODO move it to App Utilities if any other class needs
/**
 Method to decode a base64 encoded string.
 */

/*
-(NSString*)decodeBase64:(NSString*)base64String
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedString = @"";
    if([data length] != 0){
        
        decodedString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    }
    
    return decodedString;
}
 */

/*
-(void)parseDLFrontWithODE:(NSArray*)dlFrontArray andVerificationConfidence:(NSString*)verificationConfidence {
    if([dlFrontArray count] == 0)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(dlFrontParsingFailed)])
            [self.delegate dlFrontParsingFailed];
    }
    else
    {
        //changing the way we parse the dl as the response has changed
        if(![dlFrontArray isKindOfClass:[NSArray class]])
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(dlFrontParsingFailed)])
                [self.delegate dlFrontParsingFailed];
            return;
        }
        
        
        DLData* dlData = [[DLData alloc] init];
        if(verificationConfidence && verificationConfidence.length>0){
            dlData.documentVerificationConfidenceRating = verificationConfidence;
        }
        NSString *strLabel;
        NSString *strValue;
        
        for (kfxKOEDataField *field in dlFrontArray)
        {
            
            strLabel = field.name;
            strValue = field.value;
            
            if(strLabel && [strLabel isEqualToString:@"IDNumber"]){
                dlData.drivinglicenseID = strValue;
            }else if(strLabel && [strLabel isEqualToString:@"License"]){
                dlData.drivingLicenseNumber = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"DateOfBirth"]){
                dlData.dob = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"FullName"]){
                dlData.name = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"MiddleName"]){
                dlData.middleName = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"FirstName"]){
                dlData.firstName = strValue;
                dlData.name = dlData.firstName;
                dlData.name = [dlData.name stringByAppendingString:@" "];
            }
            else if(strLabel && [strLabel isEqualToString:@"LastName"]){
                dlData.lastName = strValue;
                dlData.name = [dlData.name stringByAppendingString:dlData.lastName];
            }
            else if(strLabel && [strLabel isEqualToString:@"Address"]){
                dlData.street = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"Gender"]){
                if([strValue caseInsensitiveCompare:@"M"] == NSOrderedSame)
                    dlData.gender = @"MALE";
                else if ([strValue caseInsensitiveCompare:@"F"] == NSOrderedSame)
                    dlData.gender = @"FEMALE";
                else
                    dlData.gender = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"ZIP"]){
                dlData.zipCode = strValue;
            }else if(strLabel && [strLabel isEqualToString:@"ExpirationDate"]){
                dlData.expirationDate = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"State"]){
                dlData.state = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"City"]){
                dlData.city = strValue;
            }
            else if(strLabel && [strLabel isEqualToString:@"IssueDate"])
            {
                dlData.issueDate = strValue;
            }else if(strLabel && [strLabel isEqualToString:@"DocumentVerificationConfidenceRating"])
            {
                dlData.documentVerificationConfidenceRating = strValue;
                
            }else if(strLabel && [strLabel isEqualToString:@"IsIDVerified"])
            {
                dlData.documentIdVerified = strValue;
            }
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(dlFrontParsed:)])
            [self.delegate dlFrontParsed:dlData];
    }
}

//This method is used to parse the dl front details and sends a call back
-(void)parseDLFront : (NSData*)dlFrontData
{
    if([dlFrontData length] == 0)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(dlFrontParsingFailed)])
            [self.delegate dlFrontParsingFailed];
    }
    else
    {
        //changing the way we parse the dl as the response has changed
        
        NSDictionary *dlDict = nil;
        NSError *error;
        
        NSArray* dlDictArray = [NSJSONSerialization JSONObjectWithData:dlFrontData options:NSJSONReadingMutableContainers error:&error];
        if(![dlDictArray isKindOfClass:[NSArray class]])
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(dlFrontParsingFailed)])
                [self.delegate dlFrontParsingFailed];
            return;
        }
        
        dlDict = [dlDictArray objectAtIndex:0];
      
        
        NSArray *jsonArr = nil;
        
        if(dlDict && [[dlDict allKeys] containsObject:@"fields"])
        {
            
            jsonArr = [dlDict valueForKey:@"fields"];
        }
        DLData* dlData = [[DLData alloc] init];
        
        if(jsonArr && [jsonArr count] != 0)
        {
            
            NSString *strLabel;
            NSString *strValue;
            
            for (NSDictionary *dict in jsonArr)
            {
                
                strLabel = [dict valueForKey:@"name"];
                strValue = [dict valueForKey:@"text"];
                
                if(strLabel && [strLabel isEqualToString:@"IDNumber"]){
                    dlData.drivinglicenseID = strValue;
                }else if(strLabel && [strLabel isEqualToString:@"License"]){
                    dlData.drivingLicenseNumber = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"DateOfBirth"]){
                    dlData.dob = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"FullName"]){
                    dlData.name = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"MiddleName"]){
                    dlData.middleName = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"FirstName"]){
                    dlData.firstName = strValue;
                    dlData.name = dlData.firstName;
                    dlData.name = [dlData.name stringByAppendingString:@" "];
                }
                else if(strLabel && [strLabel isEqualToString:@"LastName"]){
                    dlData.lastName = strValue;
                    dlData.name = [dlData.name stringByAppendingString:dlData.lastName];
                }
                else if(strLabel && [strLabel isEqualToString:@"Address"]){
                    dlData.street = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"Gender"]){
                    if([strValue caseInsensitiveCompare:@"M"] == NSOrderedSame)
                        dlData.gender = @"MALE";
                    else if ([strValue caseInsensitiveCompare:@"F"] == NSOrderedSame)
                        dlData.gender = @"FEMALE";
                    else
                        dlData.gender = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"ZIP"]){
                    dlData.zipCode = strValue;
                }else if(strLabel && [strLabel isEqualToString:@"ExpirationDate"]){
                    dlData.expirationDate = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"State"]){
                    dlData.state = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"City"]){
                    dlData.city = strValue;
                }
                else if(strLabel && [strLabel isEqualToString:@"IssueDate"])
                {
                    dlData.issueDate = strValue;
                }
                else if (strLabel && [strLabel isEqualToString:@"FaceImage64"]){
                    
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:strValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    
                    dlData.imgDriverPhoto = [UIImage imageWithData:data];
                    data = nil;
                    
                }
                else if (strLabel && [strLabel isEqualToString:@"SignatureImage64"]){
                    
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:strValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    
                    dlData.imgDriverSignature = [UIImage imageWithData:data];
                    data = nil;
                    
                }else if(strLabel && [strLabel isEqualToString:@"DocumentVerificationConfidenceRating"])
                {
                    dlData.documentVerificationConfidenceRating = strValue;
                    
                }else if(strLabel && [strLabel isEqualToString:@"IsIDVerified"])
                {
                    dlData.documentIdVerified = strValue;
                }
            }
            
        }
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(dlFrontParsed:)])
            [self.delegate dlFrontParsed:dlData];
        
    }
}
*/


+ (NSMutableDictionary*)parseKTAResponseFields:(NSDictionary*)responseDictionary {
    
    NSMutableArray *fieldsArr = [[[[responseDictionary valueForKey:@"d"]valueForKey:@"ReturnedDocumentFields"] firstObject] valueForKey:@"ReturnedDocumentFields"];
    
    NSMutableDictionary *extractionOutput = [[NSMutableDictionary alloc]init];
    
    
    [extractionOutput setValue:[[NSArray alloc]init] forKey:@"words"];
    [extractionOutput setValue:[[NSArray alloc]init] forKey:@"classificationResult"];
    
    NSMutableArray *fieldArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in fieldsArr) {
        
        if([dict[@"Name"] isEqualToString:@"AuthenticationResponse"] || [dict[@"Name"] isEqualToString:@"HeadShot"]){
            continue;
        }
        
        NSMutableDictionary *fieldObj = [[NSMutableDictionary alloc]init];
        [fieldObj setValue:[[dict valueForKey:@"Id"] isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Id"] forKey:@"id"];
        [fieldObj setValue:[[dict valueForKey:@"Value"] isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Value"] forKey:@"text"];
        [fieldObj setValue:[[dict valueForKey:@"Name"] isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Name"] forKey:@"name"];
        [fieldObj setValue:[[dict valueForKey:@"Confidence"] isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Confidence"] forKey:@"confidence"];
        [fieldObj setValue:[[dict valueForKey:@"ErrorDescription"]isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"ErrorDescription"] forKey:@"errorDescription"];
        [fieldObj setValue:[[dict valueForKey:@"Valid"]isKindOfClass:[NSNull class]]?@"":[dict valueForKey:@"Valid"] forKey:@"valid"];
        
        [fieldArray addObject:fieldObj];
        fieldObj = nil;
    }
    
    [extractionOutput setValue:fieldArray forKey:@"fields"];
    
    fieldArray = nil;
    
    return extractionOutput;
}


// Get valid NSString instance from JSON

+(NSString*)getStringForKey:(NSString*)key withDictionary:(NSDictionary*)inputDictionary{
    
    NSString *stringValue = [[inputDictionary valueForKey:key] isKindOfClass:[NSNull class]]?nil:[[inputDictionary valueForKey:key] isKindOfClass:[NSString class]]?[inputDictionary valueForKey:key]:[[inputDictionary valueForKey:key] stringValue];
    
    return stringValue;
}
@end
