//
//  ViewController.m
//  w3w
//
//  Created by Lee Probert on 14/05/2015.
//  Copyright (c) 2015 probert. All rights reserved.
//

#import "ViewController.h"
#import "MapBox.h"
#import "What3Words.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    /* ---------------------------------
        Init w3w helper class instance
     */
    self.w3w = [[what3words alloc] initWithWithApiKey:@"735TB2CC"];
    
    /* ---------------------------------
        Init location manager
     */
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 500;
    
    [self.locationManager startUpdatingLocation];
    
    /* ---------------------------------
        Init MapBox and view
     */
    
    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoibGVlcHJvYmVydCIsImEiOiJLNnpfaTdjIn0.Y_M6MLvwpH7pyqxB8QvxZg"];
    
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"leeprobert.m67mbd63"];
    
    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds
                                            andTilesource:tileSource];
    self.mapView.delegate = self;
    
    // set coordinates
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(38.91235, -77.03128);
    
    // set zoom
    self.mapView.zoom = 15;
    
    // center the map to the coordinates
    self.mapView.centerCoordinate = center;
    
    [self.view addSubview:self.mapView];
}

#pragma mark - PRIVATE

- (void)setAnnotationTitle:(NSString*)title {
    
    [self.userLocationAnnotation setTitle:title];
}

- (void) updateAnnotation:(CLLocationCoordinate2D)coord {
    
    // build first marker and title if nil
    if(nil == self.userLocationAnnotation){
        
        self.userLocationAnnotation = [[RMAnnotation alloc]
                                       initWithMapView:self.mapView
                                       coordinate:coord
                                       andTitle:@"--.--.--"];
        
        self.userLocationAnnotation.userInfo = @"w3w";
        
        
        [self.mapView addAnnotation:self.userLocationAnnotation];
        
    }else{
        
        // just change the coordinates to match latest
        self.userLocationAnnotation.coordinate = coord;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        
        [self updateAnnotation:location.coordinate];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"%@",[error description]);
}

#pragma mark - RMMapViewDelegate

- (void)mapView:(RMMapView *)mapView didSelectAnnotation:(RMAnnotation *)annotation {
    
    if ([annotation.userInfo isEqualToString:@"w3w"])
    {
        NSString *latlng = [NSString stringWithFormat:@"%f,%f",annotation.coordinate.latitude,annotation.coordinate.longitude];
        
        // Need to set the title dynamically by initiating a new call to the w3w API
        
        __block NSArray *words;
        
        [self.w3w positionToWords:latlng
              withCompletion:^(NSDictionary *result, NSError *error) {
                  NSLog(@"aici: %@", result);
                  
                  words = (NSArray*)[result valueForKey:@"words"];
                  NSString *newtitle = [NSString stringWithFormat:@"%@.%@.%@",words[0],words[1],words[2]];
                  [self setAnnotationTitle:newtitle];
              }];
    }
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMarker *marker;
    
    // set 'training' marker image
    if ([annotation.userInfo isEqualToString:@"w3w"])
    {
        marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"pin_red"] anchorPoint:CGPointMake(0, 1)];
    }
    
    marker.canShowCallout = YES;
    
    return marker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
