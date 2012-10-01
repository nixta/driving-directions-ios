//
//  NearByViewController.m
//  Map
//
//  Created by Al Pascual on 10/1/12.
//
//

#import "NearByViewController.h"

@interface NearByViewController ()

@end

@implementation NearByViewController

@synthesize webView = _webView;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load a website
    NSString *fullURL = @"http://help.arcgis.com/en/webapi/javascript/arcgis/samples/mobile_findnearby/index.html";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
