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
    SBCouchDesignDocument *designDoc = [self.couchDatabase getDesignDocument:@"_design/test-views"];
    STAssertNotNil(designDoc, nil);
    STAssertNotNil(designDoc.couchDatabase, @"A design doc fetched from the server MUST know where it came from");
    
    for(id key in [designDoc views]){
        SBCouchView *view = [designDoc view:key];
        STAssertNotNil(view.couchDatabase, @"A view fetched from the server MUST know of where it came. ");
        STAssertNotNil(view.identity, nil );
                
        NSEnumerator *viewResults = [view getEnumerator];
        STAssertNotNil(viewResults,nil);
        
        SBCouchDocument *document;
        BOOL pass = NO;
        while (document = [viewResults nextObject]) {
            pass = YES;
        }
        //STAssertTrue(pass, nil);
    }    
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
