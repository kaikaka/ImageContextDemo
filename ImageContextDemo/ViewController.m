//
//  ViewController.m
//  ImageContextDemo
//
//  Created by xiangkai yin on 16/5/6.
//  Copyright © 2016年 kuailao_2. All rights reserved.
//

#import "ViewController.h"
#import "ImageContextController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource> {
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.textLabel.text = @"scaleToSize";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"compressToMaxFileSize";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"didSelect"]) {
        ImageContextController *controller = segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *)sender;
        [controller setSelectTag:cell.tag];
    }
}

@end
