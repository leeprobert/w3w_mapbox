//
//  ViewController.h
//  w3w
//
//  Created by Lee Probert on 14/05/2015.
//  Copyright (c) 2015 probert. All rights reserved.
//

@import UIKit;
@import CoreLocation;
#import "RMMapViewDelegate.h"

@class what3words;


@interface ViewController : UIViewController <RMMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) RMMapView *mapView;
@property (nonatomic, strong) RMAnnotation *userLocationAnnotation;
@property (nonatomic, strong) what3words *w3w;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

