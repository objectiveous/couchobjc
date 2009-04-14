#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchDesignDocument.h"
#import "AbstractDatabaseTest.h"


@interface SBEnumeratorIntegrationTest : AbstractDatabaseTest{
}

- (void)simpleAllDocsEnumeration;
- (void)simplestThingThatWillWork;
- (void)simpleDesignDocsEnumerator;
- (void)ensureSkipIsWorkingAndThereAreNoDuplicates;
- (void)itemAtIndexCallsWorkProperly;
- (void)noLimitInQueryOptionsMeansFetchEveryThing;
- (void)previousAndNextKnowledge;
- (void)indexforPageNumber;
- (void)startAndEndPageNumbers;
- (void)numberOfRowsForPage;
- (void)resetLimit;

@end

@implementation SBEnumeratorIntegrationTest


#pragma mark - 
-(void)setUp{
    [super setUp];
    self.numberOfViewsToCreate = 10;
    self.numberOfDocumentsToCreate = 57;
    [super provisionViews];
    [self provisionDocuments];    
}

-(void)tearDown{
    [super tearDown];
}
#pragma mark -[NSString stringWithFormat:@"%i", i]



-(void)testANumberOfThingsWithASingleSetup{
    // We're doing this because we want to setup a single database for testing. 
    // We could add support for this to AbstractDatabaseTest at some point but 
    // doing it this way makes it really clear what's going on. 

    [self resetLimit];
    /*
    [self numberOfRowsForPage];
    [self startAndEndPageNumbers];
    [self previousAndNextKnowledge];

    [self simplestThingThatWillWork];
    [self simpleAllDocsEnumeration];
    [self simpleDesignDocsEnumerator];
    [self ensureSkipIsWorkingAndThereAreNoDuplicates];
    [self itemAtIndexCallsWorkProperly];
    [self noLimitInQueryOptionsMeansFetchEveryThing];
    */
}

-(void)resetLimit{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 5;
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];
    SBCouchEnumerator *viewEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    
    NSInteger count = [viewEnumerator count];
    [viewEnumerator itemAtIndex:4];
    
    [viewEnumerator resetLimit:1000];
    
    STAssertTrue(viewEnumerator.currentIndex == 0, @" %i ", viewEnumerator.currentIndex);
    
    count = [viewEnumerator count];
    STAssertTrue(count == 67, @"count = [%i]", count);
    
    [view release];
    [queryOptions release]; 
}

-(void) numberOfRowsForPage{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 5;
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];
    SBCouchEnumerator *viewEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    
    STAssertTrue([viewEnumerator numberOfRowsForPage:1] == 5, nil);
    STAssertTrue([viewEnumerator numberOfRowsForPage:14] == 2, @" %i ", [viewEnumerator numberOfRowsForPage:14]);
    
    [view release];
    [queryOptions release];
}

-(void)startAndEndPageNumbers{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 5;
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    
    STAssertTrue([resultEnumerator startIndexOfPage:1] == 1, @"start idex = %i", [resultEnumerator startIndexOfPage:1]);
    STAssertTrue([resultEnumerator startIndexOfPage:2] == 6, @"start idex = %i", [resultEnumerator startIndexOfPage:2]);
    
    STAssertTrue([resultEnumerator endIndexOfPage:1] == 5, @"start idex = %i", [resultEnumerator endIndexOfPage:1]);
    STAssertTrue([resultEnumerator endIndexOfPage:2] == 10, @"start idex = %i", [resultEnumerator endIndexOfPage:2]);
    STAssertTrue([resultEnumerator endIndexOfPage:14] == 67, @"start idex = %i", [resultEnumerator endIndexOfPage:14]);
    
    [view release];
}
-(void)indexforPageNumber{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 5;
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    
    id object = [resultEnumerator objectAtIndex:4 ofPage:4];
    STAssertNotNil(object, nil);
    
    STAssertNotNil([resultEnumerator objectAtIndex:1 ofPage:1], nil);
    STAssertNotNil([resultEnumerator objectAtIndex:5 ofPage:1], nil);
    // The indexes start at 1 not 0. 
    STAssertNil([resultEnumerator objectAtIndex:0 ofPage:1], nil);
    STAssertNil([resultEnumerator objectAtIndex:100 ofPage:100], nil);
    
    
    [view release];
}

-(void)previousAndNextKnowledge{

    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = 2;
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self.couchDatabase queryOptions:queryOptions ];
    SBCouchEnumerator *resultEnumerator = (SBCouchEnumerator*)[view viewEnumerator];
    
    STAssertFalse([resultEnumerator hasPreviousBatch],nil);
    STAssertTrue([resultEnumerator hasNextBatch], @"There should be a next batch available");

    [resultEnumerator nextObject];
    [resultEnumerator nextObject];
    [resultEnumerator nextObject];
    
    STAssertTrue([resultEnumerator hasPreviousBatch],nil);
    
    STAssertTrue([resultEnumerator hasNextBatch], @"There should be a next batch available");
    [resultEnumerator fetchNextPage];
    
    [view release];
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
