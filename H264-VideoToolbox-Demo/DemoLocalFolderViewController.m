//
//  ViewController.h
//  H264-VideoToolbox-Demo
//
//  Created by 殷汶杰 on 2018/2/4.
//  Copyright © 2018年 殷汶杰. All rights reserved.
//


#import "DemoLocalFolderViewController.h"

@interface DemoLocalFolderViewController ()

@end

@implementation DemoLocalFolderViewController {
    NSString *_folderPath;
    NSMutableArray *_subpaths;
    NSMutableArray *_files;
}

- (instancetype)initWithFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        folderPath = [folderPath stringByStandardizingPath];
        self.title = [folderPath lastPathComponent];
        
        _folderPath = folderPath;
        _subpaths = [NSMutableArray array];
        _files = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *error = nil;
    BOOL isDirectory = NO;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_folderPath error:&error];

    [_subpaths addObject:@".."];

    for (NSString *fileName in files) {
        NSString *fullFileName = [_folderPath stringByAppendingPathComponent:fileName];
        
        [[NSFileManager defaultManager] fileExistsAtPath:fullFileName isDirectory:&isDirectory];
        if (isDirectory) {
            [_subpaths addObject:fileName];
        } else {
            [_files addObject:fileName];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _subpaths.count;
            
        case 1:
            return _files.count;
            
        default:
            break;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"abc"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abc"];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = [NSString stringWithFormat:@"[%@]", _subpaths[indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } break;
        case 1: {
            cell.textLabel.text = _files[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            NSString *fileName = [_folderPath stringByAppendingPathComponent:_subpaths[indexPath.row]];

            DemoLocalFolderViewController *viewController = [[DemoLocalFolderViewController alloc] initWithFolderPath:fileName];
            
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case 1: {
            NSString *fileName = [_folderPath stringByAppendingPathComponent:_files[indexPath.row]];

            fileName = [fileName stringByStandardizingPath];

            NSLog(@"File name: %@", fileName);
            
        } break;
        default:
            break;
    }
}

@end
