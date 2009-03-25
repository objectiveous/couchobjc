#import "AbstractDatabaseTest.h"
#import "SBCouchDesignDocument.h"
#import "SBCouchView.h"

static NSString *MAP_FUNCTION = @"function(doc){emit(doc._id, doc);}";

@interface SBSlowViewIntegrationTest : AbstractDatabaseTest{
}

@end

@implementation SBSlowViewIntegrationTest

-(void)setUp{
    [super setUp];
    self.numberOfDocumentsToCreate = 20;
    [super provisionDocuments];
}

-(void)testPostingSlowView{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 2;
    //queryOptions.group = YES;
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"testViewSelectEverything" 
                                            couchDatabase:self.couchDatabase
                                             queryOptions:queryOptions];
    
    [view setMap:MAP_FUNCTION];
    
    NSEnumerator *viewResult = [view slowViewEnumerator];
    STAssertNotNil(viewResult, nil);
    
    
    id doc;
    while(doc = [viewResult nextObject]){
        NSLog(@"    %@", doc);
    }

    NSArray *allDocs = [viewResult allObjects];
    STAssertTrue([allDocs count] == self.numberOfDocumentsToCreate, @"%i : %i", [allDocs count], self.numberOfDocumentsToCreate);
    
    
}

-(void)testPostingView{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 2;
    //queryOptions.group = YES;
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"testViewSelectEverything" 
                                            couchDatabase:self.couchDatabase
                                             queryOptions:queryOptions];
    [view setMap:MAP_FUNCTION];    
    NSDictionary *response = [self.couchDatabase runSlowView:view];
    STAssertNotNil(response, nil);
    // We should be able to make the following call but SBCouchResponse makes some 
    // assumptions that it should not, like the existend of 'ok' in the result data. 
    //STAssertTrue(response.ok, nil);
    [view release];
}

@end
