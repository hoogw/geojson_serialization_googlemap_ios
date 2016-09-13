# geojson_serialization_googlemap_ios
Serialize geojson to google map iOS shapes

how to use :

    #import <GoogleMaps/GoogleMaps.h>
    #import "GeoJSONSerialization.h"
    
    NSData *data;
    NSDictionary *geoJSON;
    NSArray *shapes;
    
    
    
    // add geojson
    data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"your_data" withExtension:@"geojson"]];
    geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    shapes = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:geoJSON error:nil];
    
    
    for (GMSOverlay *shape in shapes) {
        shape.map = mapView_;
        
    }
    
    
    
    
   
