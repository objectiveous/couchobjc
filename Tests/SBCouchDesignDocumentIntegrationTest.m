#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchDesignDocument.h"
#import "AbstractDatabaseTest.h"
#import "SBCouchQueryOptions.h"
#import "SBCouchView.h"

static NSString *DESIGN_NAME      = @"someDesignDoc";
static NSString *MAP_FUNCTION     = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *REDUCE_FUNCTION  = @"function(k, v, rereduce) { return sum(v);}";


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
    allDesignDocumentsView.queryOptions.revs_info = YES;
    
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[allDesignDocumentsView viewEnumerator];
    
    SBCouchDesignDocument *designDoc;
    while (designDoc = [resultEnumerator nextObject]) {
        NSArray *revs = [designDoc revisions];
        STAssertNotNil(revs, @"[%@]", revs);
        
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

- (void)testCreateView{
    // TODO DesignDomain needs to go away makes no real sense. 
    SBCouchDesignDocument *designDocument = [[SBCouchDesignDocument alloc] initWithName:DESIGN_NAME 
                                                                          couchDatabase:self.couchDatabase];
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"Franks" couchDatabase:self.couchDatabase];
    view.map = MAP_FUNCTION;
    view.reduce = REDUCE_FUNCTION;
    
    STAssertNotNil(designDocument, nil);
    STAssertNotNil(view, nil);
    STAssertTrue([view.map isEqualToString:MAP_FUNCTION], nil);
    
    [designDocument addView:view withName:@"franks"];
    [designDocument addView:view withName:@"summary"];
    
    SBCouchResponse *response = [couchDatabase createDocument:designDocument];
    if(! response.ok)
        STFail(@"Failed Response", nil);
    STAssertNotNil(response.name, @"response path is missing", response.name);
    
    SBCouchDesignDocument *newlyFetchedDesignDoc = [couchDatabase getDesignDocument:response.name];
    
    
    STAssertNotNil(newlyFetchedDesignDoc,nil);
    STAssertNotNil(newlyFetchedDesignDoc.identity,@"identity %@",newlyFetchedDesignDoc.identity );
    
    
    STAssertTrue([newlyFetchedDesignDoc.identity isEqualToString:designDocument.identity], @"design docs are not the same. %@, %@" , newlyFetchedDesignDoc.identity, designDocument.identity );
    
    NSEnumerator *designDocs = [couchDatabase getDesignDocuments];
    STAssertNotNil(designDocs, nil);
    
    id dict; 
    BOOL pass = NO;
    while(( dict = [designDocs nextObject] )){
        pass = YES;
    }
    
    STAssertTrue(pass, @"never got a design doc. ");
    [designDocument release];
    [view release];
}

@end
