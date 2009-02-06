#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchDesignDocument.h"
#import "SBCouchView.h"
#import "SBCouchResponse.h"
#import "CouchObjC.h"

static NSString *MAP_FUNCTION     = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *REDUCE_FUNCTION  = @"function(k, v, rereduce) { return sum(v);}";

@interface SBCouchDesignDocumentTest : SenTestCase {
}
@end


@implementation SBCouchDesignDocumentTest

-(void)testDesignDocumentCreation{
    SBCouchDesignDocument *designDocument = [[SBCouchDesignDocument alloc] init];    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"franks" andMap:MAP_FUNCTION andReduce:REDUCE_FUNCTION]; 
    
    STAssertNotNil(designDocument, nil);
    STAssertNotNil(view, nil);
    STAssertTrue([view.map isEqualToString:MAP_FUNCTION], nil);
    
    [designDocument addView:view withName:@"franks"];
    
    STIGDebug(@"description %@", designDocument);
    
    [designDocument release];
    [view release];
            
}

@end
