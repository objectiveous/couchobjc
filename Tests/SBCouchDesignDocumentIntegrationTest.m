#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchDesignDocument.h"
#import "AbstractDatabaseTest.h"
#import "SBCouchQueryOptions.h"
#import "SBCouchView.h"

@interface SBCouchDesignDocumentIntegrationTest : AbstractDatabaseTest {
}
@end

@implementation SBCouchDesignDocumentIntegrationTest

#pragma mark - 
-(void)setUp{
    [super setUp];
    self.numberOfViewsToCreate = 10;
    self.numberOfDocumentsToCreate = 50; 
    [super provisionViews];
    [self provisionDocuments];    
}

-(void)tearDown{
    [super tearDown];
}
#pragma mark -

-(void)testSimpleDesignDocsEnumerator{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.startkey = @"_design";
    queryOptions.endkey = @"_design0";
    queryOptions.include_docs = YES;
    
    SBCouchView *viewFromTheDocument = [[SBCouchView alloc] initWithName:@"_all_docs" queryOptions:queryOptions couchDatabase:self.couchDatabase];
    
    
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[viewFromTheDocument getEnumerator];

    SBCouchDocument *object;
    while (object = [resultEnumerator nextObject]) {
        NSLog(@"%@", object);
       // SBCouchDesignDocument *designDoc = [SBCouchDesignDocument designDocumentFromDocument:object];
        SBCouchDesignDocument *designDoc = [[SBCouchDesignDocument alloc] initWithDictionary:object couchDatabase:self.couchDatabase];
        NSDictionary *viewList = [designDoc views];
        //STAssertNotNil(viewList, nil);
        for(id viewNameKey in viewList){
            NSLog(@"%@", viewNameKey);
            NSLog(@"%@", [viewList objectForKey:viewNameKey]);
            SBCouchView *viewFromTheDocument = [viewList objectForKey:viewNameKey];
            
            SBCouchQueryOptions *newQueryOptions = [SBCouchQueryOptions new];
            newQueryOptions.group = YES;
            viewFromTheDocument.queryOptions = newQueryOptions;
            
            STAssertTrue([viewFromTheDocument isKindOfClass:[SBCouchView class]], nil);
            STAssertNotNil(viewFromTheDocument.couchDatabase, @"View is missing a reference to a couchDatabase");
            STAssertNotNil(viewFromTheDocument.name, @"View is missing its name.");
            STAssertNotNil([viewFromTheDocument identity] , @"View is missing its identity.");
            NSLog(@"%@", [viewFromTheDocument identity]);
            
            SBCouchEnumerator *viewResults = (SBCouchEnumerator*) [viewFromTheDocument getEnumerator];
            NSArray *allDocs = [viewResults allObjects];
            NSInteger count = [allDocs count]; 
            NSLog(@"%i",count);
            STAssertTrue(count > 0, nil);
        }
        
    }

}
@end
