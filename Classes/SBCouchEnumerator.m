//
//  SBCouchEnumerator.m
//  CouchObjC
//
//  Created by Robert Evans on 1/10/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchEnumerator.h"
#import "SBCouchDatabase.h"
#import "CouchObjC.h"

@implementation SBCouchEnumerator

@synthesize db;
@synthesize totalRows;
@synthesize batchSize;
@synthesize viewPath;
@synthesize rows;
@synthesize currentIndex;
@synthesize startKey;
@synthesize viewName;


// XXX This is so horrible I can barley stand to look at it. Calls to the database ought to live in the database class. 
// use a callback or something if necissary. 
-(id)initWithBatchesOf:(NSInteger)count database:(SBCouchDatabase*)database couchView:(SBCouchView*)couchView{
    NSString *tempView = [couchView JSONRepresentation];
    NSData *body = [tempView dataUsingEncoding:NSUTF8StringEncoding];
    SBCouchServer *server = [database server];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@", server.host, server.port, couchView.couchDatabase, @"_temp_view?limit=10&group=true"];
    NSURL *url = [NSURL URLWithString:urlString];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; 
    
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    NSLog(@"status code %i", [response statusCode]);
    NSLog(@"headers %@", [[response allHeaderFields] JSONRepresentation]);

    NSDictionary *etf;
    if (200 == [response statusCode]) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        etf = [json JSONValue];
        NSLog(@"--> %@", [etf JSONRepresentation]);
    }
    
    self = [super init];
    if(self != nil){
        [self setViewName:couchView.name];
        [self setCurrentIndex:0];
     
        [self setBatchSize:-1]; 
        [self setDb:database];
        [self setViewPath:couchView.name];
        if(etf != nil){
            NSArray *arrayOfRows = [etf objectForKey:@"rows"];
            [self setTotalRows:[arrayOfRows count]];        
            [self setRows:[etf objectForKey:@"rows"]];
        }
    }
    return self;            
}
// a count 0f 0 or less means fetch everything. That is, use not limit expression
-(id)initWithBatchesOf:(NSInteger)count database:(SBCouchDatabase*)database view:(NSString*)view{
    NSString *url;
    if(count > 0)
        url = [NSString stringWithFormat:@"%@?limit=%i&group=true", view, count];        
     else
         url = view;
    

    NSDictionary *etf = [database get:url];

    self = [super init];
    if(self != nil){
        [self setViewName:view];
        [self setCurrentIndex:0];
        [self setTotalRows:[[etf objectForKey:@"total_rows"] integerValue]]; //{"total_rows":7,"offset":3 TODO need to subtract the offset
        [self setBatchSize:count]; 
        [self setDb:database];
        [self setViewPath:view];
        [self setRows:[etf objectForKey:@"rows"]];
    }
    return self;    
}



-(void) dealloc{
    [startKey release], startKey = nil;
    [viewPath release], viewName = nil;
    [db release];
    [super dealloc];

}
-(id)itemAtIndex:(NSInteger)idx{
    // trying to access something outside our range of options. 
    if(idx > totalRows)
        return nil;

    // trying to access something that has not yet been fetched
    if(idx >= [rows count]){  
        [self fetchNextPage];
        if( [self itemAtIndex:idx]){
            // TODO might want to autorelase this
            SBCouchDocument *doc = [[SBCouchDocument alloc] initWithNSDictionary:[rows objectAtIndex:idx]];
            doc.identity = @"XXSSSXXX";
            return doc;
        }else{
            return nil;
        }
    }
    // TODO Might want to autorelease this. 
    SBCouchDocument *doc = [[SBCouchDocument alloc] initWithNSDictionary:[rows objectAtIndex:idx]];
    doc.identity = @"XXSSSXXX";

    return doc;
}
- (id)nextObject{
    if( (currentIndex >= [rows count]) && [rows count] < totalRows){
    
        [self setStartKey:[[rows lastObject] objectForKey:@"id"]];
        [self fetchNextPage];
    }
    
    if(currentIndex >= [rows count]){
        // free up the rows array
        [rows release], rows = nil;
        return nil;
    }
        
    
    id object = [rows objectAtIndex:currentIndex];

    
    [self setCurrentIndex:[self currentIndex] +1 ];
    // TODO might want to autorelease this. 
    SBCouchDocument *doc = [[SBCouchDocument alloc] initWithNSDictionary:object];
    // We do this because calls to _all_docs do not have a _id property and because 
    // the dictionary we are working with at this point does not have an _id but it 
    // does represent an actual document (for example a design doc) that we may want 
    // to interact with. 
    doc.identity = [doc objectForKey:@"id"];
    return doc;
} 
- (NSArray *)allObjects{
    return nil;
}

-(void)fetchNextPage{    
    NSMutableString *viewUrl = [NSMutableString stringWithFormat:@"%@?", [self viewName]];

    [viewUrl appendFormat:@"startkey=\"%@\"&", [self startKey]];
    [viewUrl appendFormat:@"startkey_docid=\"%@\"&", [self startKey]];
    [viewUrl appendString:@"skip=1&"];
    [viewUrl appendFormat:@"limit=%i&",[self batchSize]];
    [viewUrl appendString:@"group=true"];

    STIGDebug(@"Using URL [%@]", [viewUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] );
    NSDictionary *etf = [[self db] get:[viewUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    [rows addObjectsFromArray:[etf objectForKey:@"rows"]];
}

@end
