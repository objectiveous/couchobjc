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
    self.numberOfDocumentsToCreate = 10; 
    [super provisionViews];
    [self provisionDocuments];    
}

-(void)tearDown{
    [super tearDown];
}
#pragma mark -


-(void)testSavingChangesToViews{
    SBCouchView *allDesignDocumentsView = [self.couchDatabase designDocumentsView];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[allDesignDocumentsView viewEnumerator];
    
    SBCouchDesignDocument *designDoc;
    while (designDoc = [resultEnumerator nextObject]) {
        
    }
}

-(void)testSavingAdditionsToDesignDocs{
    SBCouchView *allDesignDocumentsView = [self.couchDatabase designDocumentsView];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[allDesignDocumentsView viewEnumerator];
    
    SBCouchDesignDocument *designDoc;
    while (designDoc = [resultEnumerator nextObject]) {
        STAssertNotNil([designDoc identity], nil);
        
        //SBCouchDesignDocument *designDoc = [SBCouchDesignDocument designDocumentFromDocument:couchDocument];
        SBCouchView *aNewView = [SBCouchView new];
        aNewView.map = @"function(doc){emit(doc._id, doc.id);}";
        NSLog(@"identity %@", [designDoc identity]);
        [designDoc addView:aNewView withName:@"someName"];


        id rev = [designDoc revision];
        NSLog(@"first rev :  %@", rev);
        STAssertNotNil(rev, @"Design document should have had its revision set");
        SBCouchResponse *response = [designDoc put];
        STAssertTrue(response.ok, @"Failed to get put design doc.");
        NSLog(@"rev after post :  %@", rev);
        NSLog(@"rev from the couchDocument %@", [designDoc revision]);
        NSLog(@"rev from the couchDocument %@", [designDoc revision]);

        STAssertFalse([[designDoc revision] isEqualToString:rev], @"%@ %@", rev, [designDoc revision]);
    }
}

-(void)testSimpleDesignDocsEnumerator{
    SBCouchView *viewFromTheDocument = [self.couchDatabase designDocumentsView];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[viewFromTheDocument viewEnumerator];

    SBCouchDocument *object;
    while (object = [resultEnumerator nextObject]) {
        NSLog(@"%@", object);
        SBCouchDesignDocument *designDoc = [SBCouchDesignDocument designDocumentFromDocument:object];
        
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
            
            SBCouchEnumerator *viewResults = (SBCouchEnumerator*) [viewFromTheDocument viewEnumerator];
            NSArray *allDocs = [viewResults allObjects];
            NSInteger count = [allDocs count]; 
            NSLog(@"%i",count);
            STAssertTrue(count > 0, nil);
        }
        
    }

}



@end
