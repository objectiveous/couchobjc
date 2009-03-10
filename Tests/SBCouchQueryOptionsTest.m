#import <SenTestingKit/SenTestingKit.h>
#import "SBCouchQueryOptions.h"

@interface SBCouchQueryOptionsTest : SenTestCase {
}
@end

@implementation SBCouchQueryOptionsTest


-(void)testDesignDocsWithDocsIncluded{
  
    SBCouchQueryOptions *options = [SBCouchQueryOptions new];
    //options.group    = YES;
    options.limit    = 10;
    options.startkey = @"_design";
    options.endkey   = @"_design0";
    options.include_docs = YES;
    
    NSString *queryString = [options queryString];
  
    NSString *template = @"startkey=\"_design\"&endkey=\"_design0\"&limit=10&include_docs=true";
    BOOL matched = [queryString isEqualToString:template];
    STAssertTrue(matched, @"%@", queryString);
    [options release];
}

-(void)testLimits{
    NSString *template = @"startkey=\"_design\"&endkey=\"_design0\"&limit=10";
    SBCouchQueryOptions *options = [SBCouchQueryOptions new];
    //options.group    = YES;
    options.limit    = 10;
    options.startkey = @"_design";
    options.endkey   = @"_design0";
    
    NSString *queryString = [options queryString];
    
    BOOL matched = [queryString isEqualToString:template];
    STAssertTrue(matched, @"queryString did not match  %@", queryString);
    [options release];
}

@end
