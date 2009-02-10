#import "AbstractDatabaseTest.h"
#import "SBCouchDesignDocument.h"
#import "SBCouchView.h"

static NSString *MAP_FUNCTION = @"function(doc){emit(doc.type, 10);}";

@interface SBSlowViewIntegrationTest : AbstractDatabaseTest{
}
-(void)loadTestDocuments;
@end

@implementation SBSlowViewIntegrationTest

-(void)setUp{
    [super setUp];
    [self loadTestDocuments];
}

-(void)testSimplestThingThatWillWork{
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"franks" andMap:MAP_FUNCTION andReduce:nil];
    
   SBCouchEnumerator *enumerator = (SBCouchEnumerator*) [[self couchDatabase] slowViewEnumerator:view];
    STAssertTrue(enumerator.totalRows > 0, @"No results returned %@", enumerator.totalRows);
    
    BOOL pass = NO;
    SBCouchDocument *object;
    while((object = [enumerator nextObject])){
        SBDebug(@"*** %@", object);   
        pass = YES;
    }
    STAssertTrue(pass, @"Could not loop through the enumerator");
    

    [view release];
}

-(void)loadTestDocuments{
    SBCouchDocument *document = [[SBCouchDocument alloc] init];     
    [document setObject:@"jazz" forKey:@"type"];
    
    SBCouchResponse *response = [self.couchDatabase postDocument:document];
    if(!response.ok)
        STFail(@"Never got a ok response from the document post");
   
    [document setObject:@"funk" forKey:@"type"];
    response = [self.couchDatabase postDocument:document];
        
    [document release];
}

@end
