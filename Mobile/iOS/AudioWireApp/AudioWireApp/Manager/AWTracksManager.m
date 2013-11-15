//
//  AWTracksManager.m
//  AudioWireApp
//
//  Created by Derivery Guillaume on 10/27/13.
//  Copyright (c) 2013 Derivery Guillaume. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "AWTracksManager.h"
#import "AWUserManager.h"
#import "AWConfManager.h"
#import "AWRequester.h"
#import "NSObject+NSObject_Tool.h"
#import "AWTrackModel.h"
#import "AWItunesImportManager.h"

@implementation AWTracksManager

+(AWTracksManager*)getInstance
{
    static AWTracksManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[AWTracksManager alloc] init];
    });
    return sharedMyManager;
}

//+(void)matchWithITunesLibrary:(NSArray *)arrayTrackModel cb_rep:(void (^)(NSArray *data, BOOL success, NSString *error))cb_rep
//{
//    NSArray *itunesMedia = [[AWItunesImportManager getInstance] getAllItunesMedia];
// 
//    for (MPMediaItem *object in itunesMedia)
//    {
//        for (AWTrackModel *trackModel in arrayTrackModel)
//        {
//            if ([trackModel.title isEqualToString:[object valueForProperty:MPMediaItemPropertyTitle]])
//            {
//                trackModel.iTunesItem = [object copy];
//                break;
//            }
//        }
//    }
//    cb_rep(arrayTrackModel, true, nil);
//}

+(NSMutableArray *)matchWithITunesLibrary:(NSMutableArray *)arrayTrackModel
{
    NSMutableArray *toDelete = [[NSMutableArray alloc] init];
    NSArray *itunesMedia = [[AWItunesImportManager getInstance] getAllItunesMedia];
    NSMutableArray *itunesMediaMatch = [[NSMutableArray alloc] initWithCapacity:[arrayTrackModel count]];
    
    if (!itunesMedia || [itunesMedia count] == 0)
        [arrayTrackModel removeAllObjects];
    for (int index = 0; index < [arrayTrackModel count]; index++)
    {
        AWTrackModel *trackModel = [arrayTrackModel objectAtIndex:index];
        BOOL foundInItunes = NO;
        
        for (int i = 0; i < [itunesMedia count]; i++)
        {
            MPMediaItem *object = [itunesMedia objectAtIndex:i];
            
            if ([trackModel.title isEqualToString:[object valueForProperty:MPMediaItemPropertyTitle]])
            {
                foundInItunes = YES;
                [itunesMediaMatch addObject:[object copy]];
                break;
            }
        }
        if (foundInItunes == NO)
        {
            NSLog(@"Delete from api %@ at index %d", trackModel.title, index);
            [toDelete addObject:trackModel];
        }
        else
        {
            NSLog(@"Keep from api %@", trackModel.title);
        }
    }
    // TODO SYNC remove objects on server side that is not in your itunes
    [arrayTrackModel removeObjectsInArray:toDelete];

    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>> Found from Itunes");
    for (int index = 0; index < [itunesMediaMatch count]; index++)
    {
        NSLog(@"%@", [[itunesMediaMatch objectAtIndex:index] valueForProperty:MPMediaItemPropertyTitle]);
    }
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>> Found from Itunes");
    
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>> Available from API after Match");
    for (int index = 0; index < [arrayTrackModel count]; index++)
    {
        NSLog(@"%@", ((AWTrackModel *)[arrayTrackModel objectAtIndex:index]).title);
    }
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>> Available from API after Match");
    return itunesMediaMatch;
}

-(void)getAllTracks:(void (^)(NSArray *data, BOOL success, NSString *error))cb_rep
{
    NSString *token = [AWUserManager getInstance].connectedUserTokenAccess;
    
    if (!token)
    {
        cb_rep(nil, false, NSLocalizedString(@"Something went wrong. You are trying to access data from the API but you are not actually logged in", @""));
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:[AWConfManager getURL:AWGetTracks], token];
    
    [AWRequester requestAudiowireAPIGET:url cb_rep:^(NSDictionary *rep, BOOL success)
     {
         if (success && rep)
         {
             BOOL successApi = [NSObject getVerifiedBool:[rep objectForKey:@"success"]];
             NSString *error = [NSObject getVerifiedString:[rep objectForKey:@"error"]];
             NSArray *list = [NSObject getVerifiedArray:[rep objectForKey:@"list"]];
             NSMutableArray *models = [[AWTrackModel fromJSONArray:list] mutableCopy];
             
             if (!successApi)
                 cb_rep(nil, successApi, error);
             else if ([models count] == 0)
                 cb_rep(nil, false, NSLocalizedString(@"No tracks in your library. You should import them first from your home screen!", @""));
             else
             {
                 self.itunesMedia = nil;
                 self.itunesMedia = [AWTracksManager matchWithITunesLibrary:models];
                 if ([models count] == 0)
                 {
                     cb_rep(nil, false, NSLocalizedString(@"The tracks of your library doesn't not match the ones you have in iTunes. You can import new from you home screen!", @""));
                     return ;
                 }
                 else
                     cb_rep(models, successApi, nil);
             }
         }
         else
             cb_rep(nil, false, NSLocalizedString(@"Something went wrong while attempting to retrieve data from the AudioWire - API", @""));
     }];
}

+(void)addTrack:(NSArray *)tracks_ cb_rep:(void (^)(BOOL success, NSString *error))cb_rep
{
    NSString *token = [AWUserManager getInstance].connectedUserTokenAccess;
    
    if (!token)
    {
        cb_rep(false, NSLocalizedString(@"Something went wrong. You are trying to access data from the API but you are not actually logged in", @""));
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:[AWConfManager getURL:AWAddTracks], token];
    
    NSMutableDictionary *userDict = [NSMutableDictionary new];
    [userDict setObject:[AWTrackModel toArray:tracks_] forKey:@"tracks"];
    
    [AWRequester requestAudiowireAPIPOST:url param:userDict cb_rep:^(NSDictionary *rep, BOOL success)
     {
         if (success && rep)
         {
             BOOL successApi = [NSObject getVerifiedBool:[rep objectForKey:@"success"]];
             NSString *message = [NSObject getVerifiedString:[rep objectForKey:@"message"]];
             NSString *error = [NSObject getVerifiedString:[rep objectForKey:@"error"]];
             if (success)
                 cb_rep(successApi, message);
             else
                 cb_rep(successApi, error);
         }
         else
         {
             cb_rep(FALSE, NSLocalizedString(@"Something went wrong while attempting to send data to the AudioWire - API", @""));
         }
     }];
}

+(void)updateTrack:(AWTrackModel *)trackToUpdate_ cb_rep:(void (^)(BOOL success, NSString *error))cb_rep
{
    NSString *token = [AWUserManager getInstance].connectedUserTokenAccess;
    
    if (!token)
    {
        cb_rep(false, NSLocalizedString(@"Something went wrong. You are trying to access data from the API but you are not actually logged in", @""));
        return ;
    }
    
    if (!trackToUpdate_ || !trackToUpdate_._id)
    {
        cb_rep(false, NSLocalizedString(@"The selected track is incorrect, it cannot be updated !", @""));
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:[AWConfManager getURL:AWUpdateTrack], trackToUpdate_._id, token];
    
    [AWRequester requestAudiowireAPIPUT:url param:[trackToUpdate_ toDictionary] cb_rep:^(NSDictionary *rep, BOOL success)
     {
         if (success && rep)
         {
             BOOL successApi = [NSObject getVerifiedBool:[rep objectForKey:@"success"]];
             NSString *message = [NSObject getVerifiedString:[rep objectForKey:@"message"]];
             NSString *error = [NSObject getVerifiedString:[rep objectForKey:@"error"]];
             if (success)
                 cb_rep(successApi, message);
             else
                 cb_rep(successApi, error);
         }
         else
         {
             cb_rep(FALSE, NSLocalizedString(@"Something went wrong while attempting to send data to the AudioWire - API", @""));
         }
     }];
}

+(void)deleteTracks:(NSArray *)tracksToDelete_ cb_rep:(void (^)(BOOL success, NSString *error))cb_rep
{
    NSString *token = [AWUserManager getInstance].connectedUserTokenAccess;
    
    if (!token)
    {
        cb_rep(false, NSLocalizedString(@"Something went wrong. You are trying to access data from the API but you are not actually logged in", @""));
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:[AWConfManager getURL:AWDelTracks], token];
    
    NSMutableDictionary *userDict = [NSMutableDictionary new];
    [userDict setObject:[AWTrackModel toArrayOfIds:tracksToDelete_] forKey:@"tracks_id"];
    
    [AWRequester requestAudiowireAPIPOST:url param:userDict cb_rep:^(NSDictionary *rep, BOOL success)
     {
         if (success && rep)
         {
             BOOL successApi = [NSObject getVerifiedBool:[rep objectForKey:@"success"]];
             NSString *message = [NSObject getVerifiedString:[rep objectForKey:@"message"]];
             NSString *error = [NSObject getVerifiedString:[rep objectForKey:@"error"]];
             if (success)
                 cb_rep(successApi, message);
             else
                 cb_rep(successApi, error);
         }
         else
         {
             cb_rep(FALSE, NSLocalizedString(@"Something went wrong while attempting to send data to the AudioWire - API", @""));
         }
     }];
}

+(void)deleteTrack:(AWTrackModel *)trackToDelete_ cb_rep:(void (^)(BOOL success, NSString *error))cb_rep
{
    NSString *token = [AWUserManager getInstance].connectedUserTokenAccess;
    
    if (!token)
    {
        cb_rep(false, NSLocalizedString(@"Something went wrong. You are trying to access data from the API but you are not actually logged in", @""));
        return ;
    }
    
    if (!trackToDelete_ || !trackToDelete_._id)
    {
        cb_rep(false, NSLocalizedString(@"The selected track is incorrect, it cannot be updated !", @""));
        return ;
    }
    
    NSString *url = [NSString stringWithFormat:[AWConfManager getURL:AWDelTrack], trackToDelete_._id, token];

    [AWRequester requestAudiowireAPIDELETE:url cb_rep:^(NSDictionary *rep, BOOL success)
     {
         if (success && rep)
         {
             BOOL successApi = [NSObject getVerifiedBool:[rep objectForKey:@"success"]];
             NSString *message = [NSObject getVerifiedString:[rep objectForKey:@"message"]];
             NSString *error = [NSObject getVerifiedString:[rep objectForKey:@"error"]];
             if (success)
                 cb_rep(successApi, message);
             else
                 cb_rep(successApi, error);
         }
         else
         {
             cb_rep(FALSE, NSLocalizedString(@"Something went wrong while attempting to send data to the AudioWire - API", @""));
         }
     }];
}

@end

