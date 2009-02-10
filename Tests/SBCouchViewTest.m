#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"

static NSString *VIEW_NAME           = @"totals";
static NSString *MAP_FUNCTION        = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *MAP_FUNCTION_UPDATE = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *REDUCE_FUNCTION     = @"function(k, v, rereduce) { return sum(v);}";

@interface SBCouchViewTest : SenTestCase {
}
@end

@implementation SBCouchViewTest

-(void)testSimplestThingThatWillWork{
    SBCouchView *view = [[SBCouchView alloc] initWithName:VIEW_NAME andMap:MAP_FUNCTION andReduce:REDUCE_FUNCTION];
    STAssertNotNil(view, nil);
    
    [view setMap:MAP_FUNCTION_UPDATE];
    
    STAssertTrue([[view map] isEqualToString:MAP_FUNCTION_UPDATE], @"map not being updated");
    [view release];
}   

@end
