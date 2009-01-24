//
//  SBCouchDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBCouchDocument : NSObject{
    NSDictionary *dictionaryDoc;
    NSString     *serverName;
    NSString     *databaseName;
}

@property (retain) NSDictionary *dictionaryDoc;
@property (retain) NSString     *serverName;
@property (retain) NSString     *databaseName;


-(SBCouchDocument*)initWithNSDictionary:(NSDictionary*)aDictionary;
-(id)objectForKey:(id)aKey;
@end
