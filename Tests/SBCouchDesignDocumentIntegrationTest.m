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
    self.numberOfViewsToCreate = 3;
    self.numberOfDocumentsToCreate = 4; 
    [super provisionViews];
    [self provisionDocuments];    
}

-(void)tearDown{
    [super tearDown];
}
#pragma mark -

-(void)testSavingAdditionsToDesignDocs{
    SBCouchView *allDesignDocumentsView = [self.couchDatabase designDocumentsView];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[allDesignDocumentsView viewEnumerator];
    
    SBCouchDesignDocument *designDoc;
    while (designDoc = [resultEnumerator nextObject]) {
        NSArray *revs = [designDoc revisions];
        STAssertNotNil(revs, nil);
        
        STAssertNotNil([designDoc identity], nil);
        
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

-(void)testNoExtraDataInTheDesignDoc{
    SBCouchView *allDesignDocumentsView = [self.couchDatabase designDocumentsView];
    NSEnumerator *resultEnumerator = [allDesignDocumentsView viewEnumerator];
    
    SBCouchDesignDocument *designDoc;
    while (designDoc = [resultEnumerator nextObject]) {
        //SBDebug(@"\n %@ \n", [designDoc description] );
        /*
        
        STAssertNotNil([designDoc identity], nil);        
        
        STAssertNotNil([designDoc objectForKey:@"_id"], @"_id is missing from DesignDoc");
        STAssertNotNil([designDoc objectForKey:@"_rev"], @"_rev is missing from DesignDoc");
        STAssertNil([designDoc objectForKey:@"doc"], nil);        
         */
    }    
}

-(void)testRenamingAndSavingDesignDocument{
    SBCouchView *allDesignDocumentsView = [self.couchDatabase designDocumentsView];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[allDesignDocumentsView viewEnumerator];
    
    SBCouchDesignDocument *designDoc;
    while (designDoc = [resultEnumerator nextObject]) {        
        [designDoc detach];
        designDoc.identity = [NSString stringWithFormat:@"%@-%i", @"_design/wow", random()];
        SBCouchResponse *response = [designDoc put];
        STAssertTrue(response.ok, nil);
    }
    NSLog(@"hrm",nil);
}



-(void)testSimpleDesignDocsEnumerator{
    SBCouchView *viewFromTheDocument = [self.couchDatabase designDocumentsView];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[viewFromTheDocument viewEnumerator];

    
    SBCouchDesignDocument *designDoc;
    while (designDoc = [resultEnumerator nextObject]) {

       NSDictionary *viewList = [designDoc views];
        STAssertNotNil(viewList, nil);
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
