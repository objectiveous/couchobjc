//
//  SBCouchDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBOrderedDictionary.h"
#import "SBCouchResponse.h"

@class SBCouchDatabase;

@interface SBCouchDocument : SBOrderedDictionary{
    SBCouchDatabase       *couchDatabase;
}

@property (retain) SBCouchDatabase *couchDatabase;

- (SBCouchDocument*)initWithNSDictionary:(NSDictionary*)aDictionary couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil;
- (NSInteger)numberOfRevisions;
/* Returns and array of revision strings with prefixes included. As of CouchDB 0.9, its not 
   clear how to interpret the prefix. At the moment this method requires that the revs_info
   query string be used. 

   http://localhost:5984/database/docID?revs_info=true
 
    _revs_info":[
                  {"rev":"2-1735408827","status":"available"},
                  {"rev":"1-4271393452","status":"available"}
                ]
 */
- (NSArray*)revisions;
- (NSString *)previousRevision;
- (NSInteger)revisionIndex;

/*!
 The identity of a SBCouchDocument is currently a bit odd. In most cases the identity of a document 
 maps directly to the last path part of its URL. For example, the identity of an SBCouchDocument fetched
 from http://localhost:5984/cushion-tickets/46c1cb086daa2fd8f26847e8212f1198 would be 46c1cb086daa2fd8f26847e8212f1198.
 
 This is determined by looking at the _id property of the document returned from defreferenceing (calling GET) 
 the above URL. 
 
 {"_id":"46c1cb086daa2fd8f26847e8212f1198","_rev":"391446400"}
 
 In the case of views, however, there is no document ID as such. In other words, the resource 
 http://localhost:5984/cushion-tickets/_view/More%20Stuff/sprint has no _id property to identify it. Said 
 another way, the symetry of _id and the last path part of the URL does not exist. 
 
 Complicating matters a bit is the fact that we treat the JSON objects returned by a view as SBCouchDocuments. 
 So the objects in the rows array are SBCouchDocuments but they have an id property and not an _id property. 
 
 {"total_rows":4,"offset":0,"rows":[
 {"id":"46c1cb086daa2fd8f26847e8212f1198","key":"sprint","value":"monkey"},
 {"id":"9b4ac3daeae2756336bd8424e43f7870","key":"sprint","value":"monkey"},
 {"id":"a21129d076224410a1a4d6fa8d4df03d","key":"sprint","value":"monkey"},
 {"id":"eb4635a8aec5619b2dbb452354fa8fdc","key":"sprint","value":"monkey"}
 ]}
 
 
 
 */
- (NSString *)identity;
- (void)setIdentity:(NSString *)someId;
- (NSString *)revision;
- (void)setRevision:(NSString *)aRevision;
// removes _id, _rev and _revs from a document. 
- (void)detach;

#pragma mark -
#pragma mark REST
// REST Methods. The idea here is that document having an identity ought to be able to fetch, update and delete its self. 
- (SBCouchDocument*)getWithRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil;
// This very questionable. 
- (SBCouchResponse*)putDocument:(SBCouchDocument*)couchDocument;
- (SBCouchResponse*)put;
- (SBCouchResponse*)post;

@end
