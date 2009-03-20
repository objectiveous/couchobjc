#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchView.h"
#import "CouchObjC.h"
#import "SBCouchDesignDocument.h"
#import "AbstractDatabaseTest.h"

static NSString *MAP_FUNCTION     = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *REDUCE_FUNCTION  = @"function(k, v, rereduce) { return sum(v);}";

static NSString *DESIGN_DOC_NAME  = @"datacenter";
static NSString *VIEW_1           = @"hardware";
static NSString *VIEW_2           = @"software";
static NSString *VIEW_3           = @"wonderousThings";

@interface SBCouchDesignDocumentTest : AbstractDatabaseTest {
    SBCouchDesignDocument *designDocument;
}
@property (retain) SBCouchDesignDocument *designDocument;
@end

@implementation SBCouchDesignDocumentTest
@synthesize designDocument;

#pragma mark - 

-(void)testCopy{
    SBCouchDesignDocument *designDocCopy = [self.designDocument copy];
    NSDictionary *originalViews = [self.designDocument views];
    
    BOOL isDesignDocument = [designDocCopy isKindOfClass:[SBCouchDesignDocument class]];
    STAssertTrue(isDesignDocument, @"Class didn't work. %@", [designDocCopy class]);
    
    NSDictionary *copyViews = [designDocCopy views];
    STAssertFalse(&originalViews == &copyViews, @"View Dictionary is the same: %p %p", &originalViews, &copyViews);

    for(id key in originalViews){
        SBCouchView *view = [originalViews objectForKey:key]; 
        view.map = @"Some Bullshit";
    }
    
    for(id key in copyViews){
        SBCouchView *view = [originalViews objectForKey:key]; 
        SBCouchView *viewCopy = [copyViews objectForKey:key];
        NSLog(@"%@", view.map);
        STAssertFalse([viewCopy.map isEqualToString:@"Some Bullshit"], @"Map pointers are the same" );
        STAssertTrue(viewCopy.map != view.map, @"Map pointers are the same" );
        STAssertFalse([viewCopy.map isEqualToString:view.map], @"Map pointers are the same" );
    }
}

/*
 Here's what a typical view might look like: 
 
 {"_id":"_design/datacenter",
 "_rev":"1508484904",
 "language":"javascript",
 "views":{"hardware":{"map":"function(doc) {\n  emit(\"datacenter\", doc);\n  // More changes\n}"},
 "software":{"map":"function(doc) {\n  emit(\"software\", doc);\n  // More changes\n}"}}
 }
 */
-(void)testViewRetrieval{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"_design/datacenter" forKey:@"_id"];
    [dict setObject:@"1508484904" forKey:@"_rev"];
    [dict setObject:@"javascript" forKey:@"language"];    
    
    
    NSMutableDictionary *view1Dict = [[NSMutableDictionary alloc] init];
    [view1Dict setObject:MAP_FUNCTION forKey:@"map"];    
    [view1Dict setObject:REDUCE_FUNCTION forKey:@"reduce"];    

            
    NSMutableDictionary *views = [[NSMutableDictionary alloc] init];
    [views setObject:view1Dict forKey:VIEW_1];
    [views setObject:view1Dict forKey:VIEW_2];
    
    [dict setObject:views forKey:@"views"];
    
    SBCouchDesignDocument *designDoc = [[SBCouchDesignDocument alloc] initWithDictionary:dict couchDatabase:self.couchDatabase];
    
    
    NSDictionary *returnedViews = [designDoc views];
    STAssertNotNil(returnedViews, @"Views were not returned");
    STAssertTrue([[returnedViews allKeys] count] == 2, @"Missing views [%i]", [[returnedViews allKeys] count]);
    
    [dict release];
    [designDoc release];
    
}

-(void)testRetrievingViewsMapsAndWhatNot{
    SBCouchView *view = [self.designDocument view:VIEW_1];   
    STAssertNotNil(view,@"Did not recieve view. [%@]", view);
}

-(void)testSimplestThingThatWillWork{
    STAssertTrue([designDocument.language isEqualToString:COUCH_KEY_LANGUAGE_DEFAULT], nil);
    
    //SBDebug(@"identity %@", designDocument.identity);
    
    id views = [designDocument views];
    STAssertNotNil(views, nil);
    
    NSString *v = [designDocument JSONRepresentation];
    NSDictionary *dict = [v JSONValue];
    STAssertNotNil(dict, nil);
    SBCouchDesignDocument *newDesignDoc = [[SBCouchDesignDocument alloc] initWithDictionary:dict];
    STAssertNotNil(newDesignDoc, nil);
    NSDictionary *newViews = [newDesignDoc views];
    STAssertNotNil(newViews, nil);
    
    NSArray *keys = [newViews allKeys];
    STAssertTrue([keys count] == 3, @"Missing views %i", [newViews allKeys]);
    
}

-(void)testGetDesignDocUsingId{    
    [designDocument setIdentity:@"_design/features"];    
    [self.couchDatabase putDocument:designDocument];
    
    SBCouchDesignDocument *freshDesignDocument = [self.couchDatabase getDesignDocument:[designDocument identity]];
    STAssertNotNil(freshDesignDocument, nil);
    NSDictionary *views = [freshDesignDocument views];
    for(id key in [views allKeys]){
        id object = [views objectForKey:key];
        
        STAssertTrue([object isKindOfClass:[SBCouchView class]], @"We are not getting acttual objects from retrieved design doc.");
    }
}


#pragma mark - 
-(void)setUp{
    [super setUp];
    SBCouchView *view = [[[SBCouchView alloc] initWithName:@"totals" couchDatabase:self.couchDatabase] autorelease];    
    view.map = MAP_FUNCTION;
    view.reduce = REDUCE_FUNCTION;
    
    designDocument = [[SBCouchDesignDocument alloc] initWithName:DESIGN_DOC_NAME couchDatabase:self.couchDatabase];
    [designDocument addView:view withName:VIEW_1];
    [designDocument addView:view withName:VIEW_2];
    [designDocument addView:view withName:VIEW_3];

    [self.couchDatabase putDocument:designDocument];
    NSString *expectedID = [NSString stringWithFormat:@"_design/%@", DESIGN_DOC_NAME];
    STAssertTrue([designDocument.identity isEqualToString:expectedID], @"%@ : %@", designDocument.identity , expectedID);
}
-(void)tearDown{
    [designDocument release];
    [super tearDown];
}

@end
