#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchDesignDocument.h"


static NSString *MAP_FUNCTION     = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *REDUCE_FUNCTION  = @"function(k, v, rereduce) { return sum(v);}";


@interface SBCouchDesignDocumentTest : SenTestCase {
}
@end

@implementation SBCouchDesignDocumentTest

-(void)testSimplestThingThatWillWork{
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"totals" andMap:MAP_FUNCTION andReduce:REDUCE_FUNCTION];
    
    SBCouchDesignDocument *designDocument = [[SBCouchDesignDocument alloc] initWithDesignDomain:@"myViews"];
    [designDocument addView:view withName:@"smallThings"];
    [designDocument addView:view withName:@"allThings"];
    [designDocument addView:view withName:@"wonderousThings"];
    
    STAssertTrue([designDocument.language isEqualToString:COUCH_KEY_LANGUAGE_DEFAULT], nil);
    
    SBDebug(@"identity %@", designDocument.identity);
    
    id views = [designDocument views];
    STAssertNotNil(views, nil);
    
    NSString *v = [designDocument JSONRepresentation];
    NSDictionary *dict = [v JSONValue];
    STAssertNotNil(dict, nil);
    SBCouchDesignDocument *newDesignDoc = [[SBCouchDesignDocument alloc] initWithDictionary:dict];
    STAssertNotNil(newDesignDoc, nil);
    NSDictionary *newViews = [newDesignDoc views];
    STAssertNotNil(newViews, nil);
    
    NSArray *keys = [newViews allKeys];
    STAssertTrue([keys count] == 3, @"Missing views %i", [newViews allKeys]);
    
}

@end
