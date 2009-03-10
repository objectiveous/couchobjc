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
    SBCouchView *couchView = [[SBCouchView alloc] initWithQueryOptions:queryOptions];
    couchView.name = @"_all_docs";
    couchView.couchDatabase = self.couchDatabase;
        
    SBCouchEnumerator *viewResults = (SBCouchEnumerator*) [couchView getEnumerator];
    
    STAssertNotNil(viewResults,nil);
    [viewResults totalRows];    

    STAssertTrue([viewResults totalRows] > 0, @"No rows");

    
    BOOL pass = FALSE;
    id doc;
    while (doc = [viewResults nextObject]) {
        pass = TRUE;
    }
    
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
