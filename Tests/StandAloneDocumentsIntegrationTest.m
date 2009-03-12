#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchDesignDocument.h"
#import "AbstractDatabaseTest.h"


@interface StandAloneDocumentsIntegrationTest : AbstractDatabaseTest {
    SBCouchDesignDocument *designDocument;
}
@property (retain) SBCouchDesignDocument *designDocument;
@end

@implementation StandAloneDocumentsIntegrationTest
@synthesize designDocument;

#pragma mark -


-(void)testCallingGetOnSBCouchDocument{
    /*
    SBCouchDocument *couchDoc = [couchDBDocument getWithRevisionCount:YES 
                                                              andInfo:YES 
                                                             revision:nil];
     */
    
    NSEnumerator *viewResults = [self.couchDatabase allDocsInBatchesOf:100];
    SBCouchDocument *couchDocument;
    while (couchDocument = [viewResults nextObject]) {
        NSLog(@"%@", couchDocument);
        
        SBCouchDocument *fetchedDoc = [couchDocument getWithRevisionCount:YES 
                                                                  andInfo:YES 
                                                                 revision:nil];
        STAssertNotNil(fetchedDoc, nil);
        
    }
    
}

-(void)testGetViewEnumerator{
    STAssertNotNil(TEST_DESIGN_NAME, nil);
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.startkey = @"_design";
    queryOptions.endkey = @"_design0";
    SBCouchView *couchView = [[SBCouchView alloc] initWithName:@"_all_docs" andQueryOptions:queryOptions couchDatabase:self.couchDatabase]; 
    
    NSEnumerator *queryResults = [couchView getEnumerator];
    STAssertNotNil(queryResults, nil);    
}

#pragma mark - 
-(void)setUp{
    [super setUp];
    [super provisionViews];
    [self provisionDocuments];    
}

-(void)tearDown{
    [designDocument release];
    [super tearDown];
}

@end
