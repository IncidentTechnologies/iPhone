//
//  SongPurchaseRequest.m
//  gTarPlay
//
//  Created by Idan Beck on 9/3/13.
//
//

#import "SongPurchaseRequest.h"

@implementation SongPurchaseRequest

@synthesize m_sel, m_obj, m_strTest, m_pSong;

-(id) initWithSong:(UserSong*)pSong andTarget:(id)obj andSelector:(SEL)sel
{
    if(self == [super init])
    {
        m_obj = obj;
        m_sel = sel;
        m_pSong = pSong;
        
        m_strTest = [[NSString alloc] initWithString:@"Test String"];
    }
    
    return self;
}


@end
