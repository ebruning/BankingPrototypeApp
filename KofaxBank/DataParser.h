// This class acts as a parser to the app. It contains methods to parse any responses coming from webservice and also handles DL - Barcode parsing

//#import "DLData.h"
#import <Foundation/Foundation.h>


@protocol ParserProtocol <NSObject>
@optional
//-(void)barcodeParsed:(DLData*)dlBarcodeData;
//-(void)barcodeParsingFailed;

//-(void)dlFrontParsed:(DLData*)dlFrontData;
//-(void)dlFrontParsingFailed;

@end

@interface DataParser : NSObject
{
    
}

@property id<ParserProtocol>delegate;
//-(void)parseBarcodeResult :(NSString*)metaData;
//-(void)parseDLFront : (NSData*)dlFrontData;
//-(void)parseDLFrontWithODE:(NSArray*)dlFrontArray andVerificationConfidence:(NSString*)verificationConfidence;

//Method is used for changing KTA extracted response to RTTI response to display results in summary screen.

+ (NSMutableDictionary*)parseKTAResponseFields:(NSDictionary*)responseDictionary;

//+ (NSMutableArray*)parseODEPassportResponse:(NSArray*)odeResult;

// // Get valid NSString instance from JSON
+(NSString*)getStringForKey:(NSString*)key withDictionary:(NSDictionary*)inputDictionary;


@end
