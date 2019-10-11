//
//  EMKRouter.h
//  Emakina-SelfTest
//
//  Created by Jordan Jasinski on 11/10/2019.
//  Copyright © 2019 skyisthelimit.aero. All rights reserved.
//

#ifndef EMKRouter_h
#define EMKRouter_h

@class EMKMainRouter;

@protocol EMKRouter <NSObject>

@property (nonatomic,weak) EMKMainRouter *mainRouter;

-(id)mainView;
//-(void)setMainRouter:(EMKMainRouter*)router;

@end

#endif /* EMKRouter_h */
