//
//  SLCollectionViewFlowLayout.m
//  Divineray
//
//  Created by ""  on 24/11/18.
//

#import "SLCollectionViewFlowLayout.h"
#import "SLGlobalShared.h"

@implementation SLCollectionViewFlowLayout

- (id)initVideosFlowLayout {
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(SLSCREEN_WIDTH/2 - 7.5, (SLSCREEN_WIDTH*4)/6 - 10);
    self.sectionInset =  UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 5.0f;
    return self;
}

    

- (id)initLiveVideosFlowLayout {
    if (!(self = [super init])) return nil;
    
//    self.itemSize = CGSizeMake(SLSCREEN_WIDTH, 250);
    self.itemSize = CGSizeMake(SLSCREEN_WIDTH-10, SLSCREEN_WIDTH-10);

    self.sectionInset =  UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 0.0f;
    return self;
}



- (id)initVodPlaylistFlowLayout
    {
    if (!(self = [super init])) return nil;
    self.itemSize = [[UIScreen mainScreen]bounds].size;
    self.sectionInset =  UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 0.0f;
    self.headerReferenceSize = CGSizeZero;
    self.footerReferenceSize = CGSizeZero;
    return self;
}

-(id)initTagVideosFlowLayoutTwo:(NSInteger)height {
        if (!(self = [super init])) return nil;
        
        self.itemSize = CGSizeMake(SLSCREEN_WIDTH/2, (SLSCREEN_WIDTH*4)/6 - 10);
        self.sectionInset =  UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
        self.minimumInteritemSpacing = 0.0f;
        self.minimumLineSpacing = 0.0f;
    self.headerReferenceSize = CGSizeMake(SLSCREEN_WIDTH, height);
    self.footerReferenceSize = CGSizeMake(SLSCREEN_WIDTH, 30);;
        return self;
    }
-(id)initTagVideosFlowLayoutThree {
        if (!(self = [super init])) return nil;
        
        self.itemSize = CGSizeMake(SLSCREEN_WIDTH/3 - 2, (SLSCREEN_WIDTH*4)/9);
        self.sectionInset =  UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
        self.minimumInteritemSpacing = 2.5f;
        self.minimumLineSpacing = 3.0f;
        self.headerReferenceSize = CGSizeMake(SLSCREEN_WIDTH, 175);
        self.footerReferenceSize = CGSizeMake(SLSCREEN_WIDTH, 30);;
        return self;
    }

-(id)initTagHeaderVideosFlowLayout:(NSInteger)height {
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(SLSCREEN_WIDTH, height);
    self.sectionInset =  UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 0.0f;
    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    return self;
}
-(id)initTagHeaderVideosDispFlowLayout:(NSInteger)height {
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(SLSCREEN_WIDTH/4 + 10 , height);
    self.sectionInset =  UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 3.0f;
    self.headerReferenceSize = CGSizeMake(0, height);

    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    return self;
}
-(id)initAppleTagHeaderVideosDispFlowLayout:(NSInteger)height {
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(50+5 , height);
    self.sectionInset =  UIEdgeInsetsMake(0.0,0.0,0.0,0.0);
    self.minimumInteritemSpacing = 0.0f;
    self.minimumLineSpacing = 3.0f;
    self.headerReferenceSize = CGSizeMake(0, height);
    
    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    return self;
}
@end
