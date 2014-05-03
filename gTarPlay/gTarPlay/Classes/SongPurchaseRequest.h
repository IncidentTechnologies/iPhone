//
//  SongPurchaseRequest.h
//  gTarPlay
//
//  Created by Idan Beck on 9/3/13.
//
//

#import <Foundation/Foundation.h>
#import <gTarAppCore/UserSong.h>

@interface SongPurchaseRequest : NSObject {

};

@property (strong, nonatomic) id m_obj;
@property (assign, nonatomic) SEL m_sel;
@property (strong, nonatomic) UserSong* m_pSong;
@property (strong, nonatomic) NSString* m_strTest;

-(id) initWithSong:(UserSong*)pSong andTarget:(id)obj andSelector:(SEL)sel;

@end
