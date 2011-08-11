//
//  PlexMediaAsset.m
//  atvTwo
//
//  Created by Frank Bauer on 27.10.10.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  
#import "PlexSongAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Machine.h>
#import <ambertation-plex/Ambertation.h>

@implementation PlexSongAsset
@synthesize pmo, url;

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) initWithURL:(NSURL*)u mediaProvider:(id)mediaProvider  mediaObject:(PlexMediaObject*)o
{
	self = [super init];
	if (self != nil) {
		pmo = [o retain];

        //TODO: Frank, why is this needed? it's nil otherwise
        [pmo.mediaContainer retain]; 
        
		self.url = u;
		DLog(@"PMO attrs: %@", pmo.attributes);
		//PlexRequest *req = pmo.request;
		//DLog(@"PMO request attrs: %@", req);
		DLog(@"SongAsset-PMO MediaContainer attrs: %@", pmo.mediaContainer.attributes);
		//DLog(@"Ref = %x", [self mediaItemRef]);
	}
	return self;
}

- (void) dealloc
{
	DLog(@"deallocing song asset");
	[pmo release];
	[url release];
	[super dealloc];
}

- (NSString*)assetID{
    DLog(@"Asset: %@", pmo.key);
	return pmo.key;
}

- (NSString*)mediaURL{
    DLog(@"track url: %@", [url description]);
    return [url description];
}

-(id)playbackMetadata{
	DLog(@"Metadata");
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithLong:self.duration], @"duration",
			self.mediaURL, @"mediaURL",
			self.assetID, @"id",
			nil];
}

- (id)mediaType{
	return [BRMediaType song];
}

-(long int)duration{
	DLog(@"Duration: %d, Totaltime: %d",[pmo.attributes integerForKey:@"duration"]/1000, [pmo.attributes integerForKey:@"totalTime"]/1000);
	
	int _duration = [pmo.attributes integerForKey:@"duration"]/1000;
	if (!(_duration > 0))
		_duration = [pmo.attributes integerForKey:@"totalTime"]/1000;
	
	return _duration;
}


#pragma mark BRMediaAsset
- (id)provider {
	return nil;
}

- (id)titleForSorting {
	return pmo.name;
};

-(id)title {
	return pmo.name;  
}

- (id)mediaDescription {
	return nil;
};

- (id)mediaSummary {
	return nil;
};

- (id)previewURL {
	[super previewURL];
	DLog(@"previewURL");
	return nil;//[[NSURL fileURLWithPath:[pmo.thumb imagePath]] absoluteString];
};


- (id)imageProxy {
	DLog(@"imageproxy for media obj: %@",pmo);
	
	NSString *thumbURL=@"";
	
    //HACK: need to support both regular music and itunes plugin. thumbs are stored in different objects...
	if ([pmo.mediaContainer.attributes valueForKey:@"thumb"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.mediaContainer.attributes valueForKey:@"thumb"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	} 
	else if ([pmo.attributes valueForKey:@"thumb"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"thumb"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	}   
	else if ([pmo.mediaContainer.attributes valueForKey:@"art"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.mediaContainer.attributes valueForKey:@"art"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	} 
	else if ([pmo.attributes valueForKey:@"art"] != nil){
		thumbURL = [NSString stringWithFormat:@"%@%@",pmo.request.base, [pmo.attributes valueForKey:@"art"]];
		return [BRURLImageProxy proxyWithURL:[NSURL URLWithString:thumbURL]];
	}	
	else
		return nil;
};

- (id)imageProxyWithBookMarkTimeInMS:(unsigned int)fp8 {
	DLog(@"imageProxyWithBookMarkTimeInMS");
	return [self imageProxy];
};
- (BOOL)hasCoverArt {
	return YES;
};

- (id)trickPlayURL {
	return nil;
};

- (id)artist {
	DLog(@"artist");
	if ([pmo.attributes objectForKey:@"artist"] != nil)
		return [pmo.attributes objectForKey:@"artist"];
	else if ([pmo.attributes objectForKey:@"grandparentTitle"] != nil)
		return [pmo.attributes objectForKey:@"grandparentTitle"];
	else
		return [pmo.mediaContainer.attributes valueForKey:@"title1"];
};
- (id)artistForSorting {
	return self.artist;
};

- (id)AlbumName {
    DLog(@"AlbumNAme");
	if ([pmo.attributes objectForKey:@"album"] != nil)
		return [pmo.attributes objectForKey:@"album"];
	else
		return [pmo.mediaContainer.attributes valueForKey:@"title2"];
};

- (id)primaryCollectionTitle {
    DLog(@"primaryCollectionTitle");
	if ([pmo.attributes objectForKey:@"album"] != nil)
		return [pmo.attributes objectForKey:@"album"];
  else if ([pmo.attributes objectForKey:@"parentTitle"] != nil)
    return [pmo.attributes objectForKey:@"parentTitle"];
	else
		return [pmo.mediaContainer.attributes valueForKey:@"title2"];
};

- (id)AlbumID {
	return nil;
}

- (id)TrackNum {
    DLog(@"TrackNum");
	return [pmo.attributes valueForKey:@"index"];
};
- (id)composer {
	return nil;
};
- (id)composerForSorting {
	return nil;
};
- (id)copyright {
	return nil;
};
- (void)setUserStarRating:(float)fp8 {
	
};
- (float)starRating {
	return 4;
};

- (BOOL)closedCaptioned {
	return NO;
};
- (BOOL)dolbyDigital {
	return NO;
};
- (long)performanceCount {
	return 1;
};
- (void)incrementPerformanceCount {
	
};
- (void)incrementPerformanceOrSkipCount:(unsigned int)fp8 {
	
};
- (BOOL)hasBeenPlayed {
	return YES;
};
- (void)setHasBeenPlayed:(BOOL)fp8 {
	
};

- (id)playbackRightsOwner {
	return nil;
};
- (id)collections {
	return nil;
};
- (id)primaryCollection {
	return nil;
};
- (id)artistCollection {
	return nil;
};

- (id)primaryCollectionTitleForSorting {
	return nil;
};
- (int)primaryCollectionOrder {
	return 0;
};
- (int)physicalMediaID {
	return 0;
};
- (id)seriesName {
	return pmo.name;
};
- (id)seriesNameForSorting {
	return pmo.name;
};
- (id)broadcaster {
	return [pmo.attributes valueForKey:@"studio"];
};

- (id)genres {
	return nil;
};
- (id)dateAcquired {
	return nil;
};
- (id)dateAcquiredString {
	return nil;
};
- (id)dateCreated {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];  
	return [dateFormatter dateFromString:[pmo.attributes valueForKey:@"originallyAvailableAt"]];
};
- (id)dateCreatedString {
	return [pmo.attributes valueForKey:@"originallyAvailableAt"];
};
- (id)datePublishedString {
	return nil;
};
- (void)setBookmarkTimeInMS:(unsigned int)fp8 {
	
};
- (void)setBookmarkTimeInSeconds:(unsigned int)fp8 {
	
};
- (unsigned int)bookmarkTimeInMS {
	return 1;
};
- (unsigned int)bookmarkTimeInSeconds {
	return 1;
};
- (id)lastPlayed {
	return nil;
};
- (void)setLastPlayed:(id)fp8 {
	
};
- (id)resolution {
	return nil;
};
- (BOOL)canBePlayedInShuffle {
	return YES;
};

- (void)skip {
	
};
- (id)authorName {
	return nil;
};
- (id)keywords {
	return nil;
};
- (id)viewCount {
	return nil;
};
- (id)category {
	return nil;
};

- (int)grFormat {
	return 1;
};
- (void)willBeDeleted {
	DLog(@"willBeDeleted");
};
- (void)preparePlaybackContext
{
	DLog(@"preparePlaybackContext");
};
- (void)cleanUpPlaybackContext {
	DLog(@"cleanUpPlaybackContext");
};
- (long)parentalControlRatingSystemID {
	return 1;
};
- (long)parentalControlRatingRank {
	return 1;
};

- (BOOL)playable {
	return YES;
};

/*
 - (void *)createMovieWithProperties:(void *)fp8 count:(long)fp12 {
 DLog(@"createMovieWithProperties");
 };
 */

- (id)sourceID {
	return nil;
};
- (id)publisher {
	return nil;
};
- (id)rating {
	return nil;
};

- (id)primaryGenre {
	return nil;
};
- (id)datePublished {
	return nil;
};
- (float)userStarRating {
	return 2;
};
- (id)cast {
	return nil;
};
- (id)directors {
	return nil;
};
- (id)producers {
	return nil;
};

- (BOOL)hasVideoContent{
    return NO;
}

- (BOOL)isAvailable{
	DLog(@"Avail?");
	return YES;
}

- (BOOL)isCheckedOut{
	DLog(@"CheckedOut?");
	return YES;
}

- (BOOL)isDisabled{
	DLog(@"Disabled?");
	return NO;
}

- (BOOL)isExplicit{
	DLog(@"Explicit?");
	return NO;
}

- (BOOL)isHD{
	DLog(@"HD?");
	return NO;
}

- (BOOL)isInappropriate{
	DLog(@"Inapprop?");
	return NO;
}

- (BOOL)isLocal{
	DLog(@"Local?");
	return NO;
}

- (BOOL)isPlaying{
	DLog(@"Playing = %i", [super isPlaying]);
	return [super isPlaying];
}

- (BOOL)isPlayingOrPaused{
	DLog(@"PlayingOrPause = %i", [super isPlayingOrPaused]);
	return [super isPlayingOrPaused];
}
- (BOOL)isProtectedContent{
	DLog(@"Protected?");
	return NO;
}

- (BOOL)isWidescreen{
	DLog(@"Widescreen?");
	return YES;
}

#pragma mark BRMediaPreviewFactoryDelegate

- (BOOL)mediaPreviewShouldShowMetadata{ 
	return YES;
}
- (BOOL)mediaPreviewShouldShowMetadataImmediately{ 
	return YES;
}



#pragma mark BRImageProvider
- (NSString*)imageID{return nil;}
- (void)registerAsPendingImageProvider:(BRImageLoader*)loader {
	DLog(@"registerAsPendingImageProvider");
}
- (void)loadImage:(BRImageLoader*)loader{ 
	DLog(@"load Image");
}


@end
