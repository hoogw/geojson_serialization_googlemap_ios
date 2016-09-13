//
//  GeoJSONSerialization.h
//  HelloMap
//
//  Created by Guowen Hu on 9/13/16.
//  Copyright © 2016 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
// #import <MapKit/MapKit.h>
//@import GoogleMaps;
#import <GoogleMaps/GoogleMaps.h>

/**
 
 */
@interface GeoJSONSerialization : NSObject

/// @name Creating MKShape objects from GeoJSON

/**
 
 */
+ (GMSOverlay *)shapeFromGeoJSONFeature:(NSDictionary *)feature
                                  error:(NSError * __autoreleasing *)error;

/**
 
 */
+ (NSArray *)shapesFromGeoJSONFeatureCollection:(NSDictionary *)featureCollection
                                          error:(NSError * __autoreleasing *)error;

/// @name Creating GeoJSON from MKShape objects

/**
 
 */
//+ (NSDictionary *)GeoJSONFeatureFromShape:(MKShape *)shape
//                               properties:(NSDictionary *)properties
//                                    error:(NSError * __autoreleasing *)error;
//
///**
// */
//+ (NSDictionary *)GeoJSONFeatureCollectionFromShapes:(NSArray *)shapes
//                                          properties:(NSArray *)arrayOfProperties
//                                               error:(NSError * __autoreleasing *)error;

@end

extern NSString * const GeoJSONSerializationErrorDomain;