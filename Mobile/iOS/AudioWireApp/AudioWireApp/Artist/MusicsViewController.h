//
//  LibraryViewController.h
//  AudioWireApp
//
//  Created by Derivery Guillaume on 8/3/13.
//  Copyright (c) 2013 Derivery Guillaume. All rights reserved.
//

#import "MasterViewController.h"

@interface MusicsViewController : MasterViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *tableData;
}
@property Boolean isAlreadyInPlaylist;

@property (weak, nonatomic) IBOutlet UIView *viewForMiniPlayer;
@property (weak, nonatomic) IBOutlet UITableView *tb_list_artist;

@end