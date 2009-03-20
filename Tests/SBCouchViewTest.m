#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchQueryOptions.h"

static NSString *VIEW_NAME           = @"totals";
static NSString *MAP_FUNCTION        = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *MAP_FUNCTION_UPDATE = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *REDUCE_FUNCTION     = @"function(k, v, rereduce) { return sum(v);}";

@interface SBCouchViewTest : SenTestCase {
}
@end

@implementation SBCouchViewTest

-(void)testSupportForCopying{
    SBCouchView *view = [[SBCouchView alloc] initWithName:VIEW_NAME couchDatabase:nil];
    view.map = MAP_FUNCTION;
    view.reduce = REDUCE_FUNCTION;
    
    SBCouchView *viewCopy = [view copy];
    
    view.map = @"function(doc){return 1;}";
    
    STAssertTrue([viewCopy isKindOfClass:[SBCouchView class]], @"Copy is not of correct class: %@", [viewCopy class]);
    STAssertFalse(&view == &viewCopy, @"%p %p", &view, &viewCopy);
    
    STAssertTrue(view.map != viewCopy.map, @"Map is the same");
    
    NSLog(@" %@ : %@", view.map, viewCopy.map);

}

-(void)testCouchViewsCreatingSimpleURLs{
    NSString *shouldMatch = @"_all_docs?startkey=\"_design\"&endkey=\"_design0\"&limit=10";
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 10;
    queryOptions.startkey = @"_design";
    queryOptions.endkey = @"_design0";
    
    SBCouchView *couchView = [[SBCouchView alloc] initWithName:@"_all_docs" 
                                                     couchDatabase:nil  
                                                      queryOptions:queryOptions];
    
    STAssertNotNil([couchView urlString], nil);
    NSLog(@"--> %@",[couchView urlString]);
    STAssertTrue([shouldMatch isEqualToString:[couchView urlString]],@"%@", [couchView urlString]);
}

-(void)testSimplestThingThatWillWork{
    SBCouchView *view = [[SBCouchView alloc] initWithName:VIEW_NAME couchDatabase:nil];
    view.map = MAP_FUNCTION;
    view.reduce = REDUCE_FUNCTION;
    
    STAssertNotNil(view, nil);
    
    [view setMap:MAP_FUNCTION_UPDATE];
    
    STAssertTrue([[view map] isEqualToString:MAP_FUNCTION_UPDATE], @"map not being updated");
    [view release];
}   

@end
