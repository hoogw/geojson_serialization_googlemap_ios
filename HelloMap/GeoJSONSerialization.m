//
//  GeoJSONSerialization.m
//  HelloMap
//
//  Created by Guowen Hu on 9/13/16.


#import "GeoJSONSerialization.h"



#pragma mark - Geometry Primitives

NSString * const GeoJSONSerializationErrorDomain = @"com.geojson.serialization.error";

static inline double CLLocationCoordinateNormalizedLatitude(double latitude) {
    return fmod((latitude + 90.0f), 180.0f) - 90.0f;
}

static inline double CLLocationCoordinateNormalizedLongitude(double latitude) {
    return fmod((latitude + 180.0f), 360.0f) - 180.0f;
}

static inline CLLocationCoordinate2D CLLocationCoordinateFromCoordinates(NSArray *coordinates) {
    NSCParameterAssert(coordinates && [coordinates count] >= 2);
    
    NSNumber *longitude = coordinates[0];
    NSNumber *latitude = coordinates[1];
    
    return CLLocationCoordinate2DMake(CLLocationCoordinateNormalizedLatitude([latitude doubleValue]), CLLocationCoordinateNormalizedLongitude([longitude doubleValue]));
}

static inline GMSMutablePath * CLCreateLocationCoordinatesFromCoordinatePairs(NSArray *coordinatePairs) {
    NSUInteger count = [coordinatePairs count];
    
    
    
    GMSMutablePath *path = [GMSMutablePath path];
    
    
    for (NSUInteger idx = 0; idx < count; idx++) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinateFromCoordinates(coordinatePairs[idx]);
        
        [path addCoordinate:coordinate];
        
        
    }
    
    return path;
}

static GMSMarker * GMSMarkerFromGeoJSONPointFeature(NSDictionary *feature) {
    NSDictionary *geometry = feature[@"geometry"];
    
    NSCParameterAssert([geometry[@"type"] isEqualToString:@"Point"]);
    
    GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinateFromCoordinates(geometry[@"coordinates"])];
    
    
    NSDictionary *properties = [NSDictionary dictionaryWithDictionary:feature[@"properties"]];
    
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:properties options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    
    marker.title = myString;
    
    
    
    
    
    return marker;
}

static GMSPolyline * GMSPolylineFromGeoJSONLineStringFeature(NSDictionary *feature) {
    NSDictionary *geometry = feature[@"geometry"];
    
    NSCParameterAssert([geometry[@"type"] isEqualToString:@"LineString"]);
    
    NSArray *coordinatePairs = geometry[@"coordinates"];
    GMSMutablePath *polylineCoordinates = CLCreateLocationCoordinatesFromCoordinatePairs(coordinatePairs);
    GMSPolyline *polyLine = [GMSPolyline polylineWithPath:polylineCoordinates];
    polyLine.strokeWidth = 3;
    polyLine.strokeColor = [UIColor redColor];
    polyLine.tappable = YES;
    
    
    NSDictionary *properties = [NSDictionary dictionaryWithDictionary:feature[@"properties"]];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:properties options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    // NSLog(@"======%@",myString);
    
    polyLine.title = myString;
    
    
    
    return polyLine;
}

static GMSPolygon * GMSPolygonFromGeoJSONPolygonFeature(NSDictionary *feature) {
    NSDictionary *geometry = feature[@"geometry"];
    
    
    NSCParameterAssert([geometry[@"type"] isEqualToString:@"Polygon"]);
    
    NSArray *coordinateSets = geometry[@"coordinates"];
    
    
   
    
    NSMutableArray *mutablePolygons = [NSMutableArray arrayWithCapacity:[coordinateSets count]];
    
    for (NSArray *coordinatePairs in coordinateSets) {
        GMSMutablePath *polygonCoordinates = CLCreateLocationCoordinatesFromCoordinatePairs(coordinatePairs);
        GMSPolygon *polygon = [GMSPolygon polygonWithPath:polygonCoordinates];
        polygon.tappable = YES;
        polygon.strokeColor = [UIColor blueColor];
        polygon.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.0f];
        
        
        polygon.strokeWidth = 2;
        
        [mutablePolygons addObject:polygon];
        
    }
    
    
  
    
    GMSPolygon *polygon = nil;
    switch ([mutablePolygons count]) {
        case 0:
            return nil;
        case 1:
            polygon = [mutablePolygons firstObject];
            break;
        default: {
            GMSPolygon *exteriorPolygon = [mutablePolygons firstObject];
            NSArray *interiorPolygons = [mutablePolygons subarrayWithRange:NSMakeRange(1, [mutablePolygons count] - 1)];
            
            
            
            NSArray<GMSPath*> *holes_path_array = [NSArray<GMSPath*> array];
            
            
            
            //  add hole to polygon
            for (GMSPolygon *interior_polygon in interiorPolygons){
                
                
               holes_path_array = [holes_path_array arrayByAddingObject:interior_polygon.path];
                
                
            }
            
            
            exteriorPolygon.holes = holes_path_array;
            polygon = exteriorPolygon;
            
        }
            break;
    }
    
    NSDictionary *properties = [NSDictionary dictionaryWithDictionary:feature[@"properties"]];
    
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:properties options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    // NSLog(@"======%@",myString);
    
    polygon.title = myString;
    
    return polygon;
}

#pragma mark - Multipart Geometries

static NSArray * GMSMarkersFromGeoJSONMultiPointFeature(NSDictionary *feature) {
    NSDictionary *geometry = feature[@"geometry"];
    
    NSCParameterAssert([geometry[@"type"] isEqualToString:@"MultiPoint"]);
    
    NSArray *coordinatePairs = geometry[@"coordinates"];
    NSDictionary *properties = [NSDictionary dictionaryWithDictionary:feature[@"properties"]];
    
    NSMutableArray *markers = [NSMutableArray arrayWithCapacity:[coordinatePairs count]];
    for (NSArray *coordinates in coordinatePairs) {
        NSDictionary *subFeature = @{
                                     @"type": @"Feature",
                                     @"geometry": @{
                                             @"type": @"Point",
                                             @"coordinates": coordinates
                                             },
                                     @"properties": properties
                                     };
        
        [markers addObject:GMSMarkerFromGeoJSONPointFeature(subFeature)];
    }
    
    return [NSArray arrayWithArray:markers];
}

static NSArray * GMSPolylinesFromGeoJSONMultiLineStringFeature(NSDictionary *feature) {
    NSDictionary *geometry = feature[@"geometry"];
    
    NSCParameterAssert([geometry[@"type"] isEqualToString:@"MultiLineString"]);
    
    NSArray *coordinateSets = geometry[@"coordinates"];
    NSDictionary *properties = [NSDictionary dictionaryWithDictionary:feature[@"properties"]];
    
    NSMutableArray *mutablePolylines = [NSMutableArray arrayWithCapacity:[coordinateSets count]];
    for (NSArray *coordinatePairs in coordinateSets) {
        NSDictionary *subFeature = @{
                                     @"type": @"Feature",
                                     @"geometry": @{
                                             @"type": @"LineString",
                                             @"coordinates": coordinatePairs
                                             },
                                     @"properties": properties
                                     };
        
        [mutablePolylines addObject:GMSPolylineFromGeoJSONLineStringFeature(subFeature)];
    }
    
    return [NSArray arrayWithArray:mutablePolylines];
}

static NSArray * GMSPolygonsFromGeoJSONMultiPolygonFeature(NSDictionary *feature) {
    NSDictionary *geometry = feature[@"geometry"];
    
    NSCParameterAssert([geometry[@"type"] isEqualToString:@"MultiPolygon"]);
    
    NSArray *coordinateGroups = geometry[@"coordinates"];
    NSDictionary *properties = [NSDictionary dictionaryWithDictionary:feature[@"properties"]];
    
    NSMutableArray *mutablePolygons = [NSMutableArray arrayWithCapacity:[coordinateGroups count]];
    for (NSArray *coordinateSets in coordinateGroups) {
        NSDictionary *subFeature = @{
                                     @"type": @"Feature",
                                     @"geometry": @{
                                             @"type": @"Polygon",
                                             @"coordinates": coordinateSets
                                             },
                                     @"properties": properties
                                     };
        
        [mutablePolygons addObject:GMSPolygonFromGeoJSONPolygonFeature(subFeature)];
    }
    
    return [NSArray arrayWithArray:mutablePolygons];
}

#pragma mark -

static id GMSOverlayFromGeoJSONFeature(NSDictionary *feature) {
    NSCParameterAssert([feature[@"type"] isEqualToString:@"Feature"]);
    
    NSDictionary *geometry = feature[@"geometry"];
    NSString *type = geometry[@"type"];
    if ([type isEqualToString:@"Point"]) {
        return GMSMarkerFromGeoJSONPointFeature(feature);
    } else if ([type isEqualToString:@"LineString"]) {
        return GMSPolylineFromGeoJSONLineStringFeature(feature);
    } else if ([type isEqualToString:@"Polygon"]) {
        return GMSPolygonFromGeoJSONPolygonFeature(feature);
    } else if ([type isEqualToString:@"MultiPoint"]) {
        return GMSMarkersFromGeoJSONMultiPointFeature(feature);
    } else if ([type isEqualToString:@"MultiLineString"]) {
        return GMSPolylinesFromGeoJSONMultiLineStringFeature(feature);
    } else if ([type isEqualToString:@"MultiPolygon"]) {
        return GMSPolygonsFromGeoJSONMultiPolygonFeature(feature);
    }
    
    return nil;
}

static NSArray * GMSOverlayFromGeoJSONFeatureCollection(NSDictionary *featureCollection) {
    NSCParameterAssert([featureCollection[@"type"] isEqualToString:@"FeatureCollection"]);
    
    NSMutableArray *mutableShapes = [NSMutableArray array];
    for (NSDictionary *feature in featureCollection[@"features"]) {
        id shape = GMSOverlayFromGeoJSONFeature(feature);
        if (shape) {
            if ([shape isKindOfClass:[NSArray class]]) {
                [mutableShapes addObjectsFromArray:shape];
            } else {
                [mutableShapes addObject:shape];
            }
        }
    }
    
    return [NSArray arrayWithArray:mutableShapes];
}









#pragma mark -


@implementation GeoJSONSerialization

+ (GMSOverlay *)shapeFromGeoJSONFeature:(NSDictionary *)feature
                                  error:(NSError * __autoreleasing *)error
{
    @try {
        return GMSOverlayFromGeoJSONFeature(feature);
    }
    @catch (NSException *exception) {
        if (error) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: exception.name,
                                       NSLocalizedFailureReasonErrorKey: exception.reason
                                       };
            
            *error = [NSError errorWithDomain:GeoJSONSerializationErrorDomain code:-1 userInfo:userInfo];
        }
        
        return nil;
    }
}

+ (NSArray *)shapesFromGeoJSONFeatureCollection:(NSDictionary *)featureCollection
                                          error:(NSError * __autoreleasing *)error
{
    @try {
        return GMSOverlayFromGeoJSONFeatureCollection(featureCollection);
    }
    @catch (NSException *exception) {
        if (error) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: exception.name,
                                       NSLocalizedFailureReasonErrorKey: exception.reason
                                       };
            
            *error = [NSError errorWithDomain:GeoJSONSerializationErrorDomain code:-1 userInfo:userInfo];
        }
        
        return nil;
    }
}




@end

