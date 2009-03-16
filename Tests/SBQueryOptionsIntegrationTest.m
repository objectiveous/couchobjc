#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchDesignDocument.h"
#import "AbstractDatabaseTest.h"
#import "SBCouchQueryOptions.h"
#import "SBCouchView.h"


@interface SBQueryOptionsIntegrationTest : AbstractDatabaseTest{
}
@end

@implementation SBQueryOptionsIntegrationTest

-(void)testUsingQueryOptionsWithAView{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    SBCouchView *couchView = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions];
        
    SBCouchEnumerator *viewResults = (SBCouchEnumerator*) [couchView viewEnumerator];

    STAssertNotNil(viewResults,nil);
  
    BOOL pass = FALSE;
    id doc;
    while (doc = [viewResults nextObject]) {
        pass = TRUE;
    }
    [viewResults totalRows];  
    STAssertTrue([viewResults totalRows] > 0, @"No rows");
    STAssertTrue(pass,nil);
    
    [couchView release];
    [queryOptions release];
}

#pragma mark - 
-(void)setUp{
    [super setUp];
    [super provisionViews];
    [self provisionDocuments];    
}

-(void)tearDown{
    [super tearDown];
}

@end
