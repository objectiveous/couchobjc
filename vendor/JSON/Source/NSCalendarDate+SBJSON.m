

#import "NSCalendarDate+SBJSON.h"
#import <JSON/JSON.h>
//#import <JSON/SBJSONScanner.h>
//#import <JSON/SBJSONScanner.h>
//#import "SBJSONScanner.h";

@implementation NSCalendarDate (NSCalendarDate_SBJSON)

- (id)JSONFragment{
    
}
- (id)JSONValue
{
    return [self JSONValueWithOptions:nil];
}

- (id)JSONValueWithOptions:(NSDictionary *)opts
{
    return [@"hello" JSONValueWithOptions:opts];
}

- (id)JSONFragmentValue
{
    
    id o;
    //NSString *stringValue = [NSString stringWithFormat:@"%@", [self description]];
    //NSString *stringValue = [NSString stringWithFormat:@"%@", @"I dont get it"];
    
    return [@"hello" JSONFragmentValue];
    /*
    SBJSONScanner *scanner = [[SBJSONScanner alloc] initWithString:stringValue];
    BOOL success = [scanner scanValue:&o] && [scanner isAtEnd];
    [scanner release];

    if (success)
        return o;
    
    [NSException raise:@"enofragment"
                format:@"Failed to parse '%@' as a JSON fragment", self];
     */
}

@end
