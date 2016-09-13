#import "HMViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GeoJSONSerialization.h"

@interface HMViewController () {
  GMSMapView *mapView_;
    
    
    NSData *data;
    NSDictionary *geoJSON;
    NSArray *shapes;
    
}

@end

@implementation HMViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Position the camera at 0,0 and zoom level 1.
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:33.693495
                                                          longitude:-117.793350
                                                               zoom:9];

  // Create the GMSMapView with the camera position.
  mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];

  // Set the controller view to be the MapView. 
  self.view = mapView_;
    
    
    
    // add point
    data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"point" withExtension:@"geojson"]];
    geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    shapes = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:geoJSON error:nil];
    
    
    for (GMSOverlay *shape in shapes) {
        shape.map = mapView_;
        
    }
    
    
    
    
    // add polygon
    data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"polygon" withExtension:@"geojson"]];
    geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    shapes = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:geoJSON error:nil];
    
    
    
    for (GMSOverlay *shape in shapes) {
        shape.map = mapView_;
        
    }
    
    
    
    // add polyline
    data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"polyline" withExtension:@"geojson"]];
    geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    shapes = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:geoJSON error:nil];
    
    
    for (GMSOverlay *shape in shapes) {
        shape.map = mapView_;
        
    }
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
