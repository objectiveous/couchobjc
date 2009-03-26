#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchDesignDocument.h"
#import "AbstractDatabaseTest.h"


@interface SBEnumeratorIntegrationTest : AbstractDatabaseTest{
}
-(void)simpleAllDocsEnumeration;
-(void)simplestThingThatWillWork;
-(void)simpleDesignDocsEnumerator;
-(void)ensureSkipIsWorkingAndThereAreNoDuplicates;
-(void)itemAtIndexCallsWorkProperly;
-(void)noLimitInQueryOptionsMeansFetchEveryThing;
@end

@implementation SBEnumeratorIntegrationTest


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
-(void)testANumberOfThingsWithASingleSetup{
    // We're doing this because we want to setup a single database for testing. 
    // We could add support for this to AbstractDatabaseTest at some point but 
    // doing it this way makes it really clear what's going on. 
    [self simplestThingThatWillWork];
    [self simpleAllDocsEnumeration];
    [self simpleDesignDocsEnumerator];
    [self ensureSkipIsWorkingAndThereAreNoDuplicates];
    [self itemAtIndexCallsWorkProperly];
    [self noLimitInQueryOptionsMeansFetchEveryThing];
}

-(void)noLimitInQueryOptionsMeansFetchEveryThing{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];

    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[view viewEnumerator];

    NSInteger totalNumberOfDocsCreated = (self.numberOfViewsToCreate + self.numberOfDocumentsToCreate);
    NSInteger count = [resultEnumerator count];
    STAssertTrue(count == totalNumberOfDocsCreated, @"count %i. Expected %i", count, totalNumberOfDocsCreated);
}


-(void)itemAtIndexCallsWorkProperly{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 6;
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];
    // subtract 1 becuase the index is 0th based. 
    NSInteger totalNumberOfDocs = (self.numberOfViewsToCreate + self.numberOfDocumentsToCreate) -1 ;
    
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    id object = [resultEnumerator itemAtIndex:0];    
    STAssertNotNil(object, @"Jumping ahead several windows is not working");
    object = [resultEnumerator itemAtIndex:totalNumberOfDocs];
    STAssertNotNil(object, @"Jumping ahead several windows is not working");
}

-(void)ensureSkipIsWorkingAndThereAreNoDuplicates{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 5;
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];
    
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    int count = 0;
    NSMutableDictionary *seenDocuments = [[NSMutableDictionary alloc] init];
    SBCouchDocument *doc;
    while (doc = [resultEnumerator nextObject]) {
        count++;
        STAssertNotNil(doc.identity, @"Document is missing an identity");
        SBCouchDocument *object = (SBCouchDocument*) [seenDocuments objectForKey:doc.identity];
        if(object){
            NSLog(@"Enumerator for _all_doc returned a duplicate document. %@", doc.identity);
            STFail(@"Enumerator for _all_doc returned a duplicate document. %@", doc.identity);
        }
        [seenDocuments setObject:doc forKey:doc.identity];
    }
    STAssertTrue(count == resultEnumerator.currentIndex, nil);    
    
}

-(void)simpleDesignDocsEnumerator{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit    = 5;
        
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];

        
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    int count = 0;
    SBCouchDocument *object;
    while (object = [resultEnumerator nextObject]) {
        count++;        
    }
    STAssertTrue(count == resultEnumerator.currentIndex, nil);    
}

-(void)simpleAllDocsEnumeration{
    // Look at all the docs in the database, 5 at a time. 
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 5;
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];
  
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    int count = 0;
    id object;
    
    while (object = [resultEnumerator nextObject]) {
        count++;
    }
    int totalNumberOfDocs = self.numberOfViewsToCreate + self.numberOfDocumentsToCreate;
    
    STAssertTrue(totalNumberOfDocs == resultEnumerator.currentIndex, @"Enumerator number %i, should be %i ", resultEnumerator.currentIndex, totalNumberOfDocs);     
}

-(void)simplestThingThatWillWork{
    NSEnumerator *designDocs = [self.couchDatabase getDesignDocuments];        
    
    /// XXX Here we should be storing the document in the descriptor. After all, we've already fetched the 
    //      darn thing. Later we can use HTTP STATUS CODE 304 to determin if the doc has changed in order 
    //      to keep things snappy. 
    SBCouchDocument *couchDesignDocument;
    while((couchDesignDocument = [designDocs nextObject])){  
        STAssertNotNil(couchDesignDocument, @"SBCouchEnumerator failed to return a proper object");       
    }    
}



@end
