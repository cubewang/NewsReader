#import <Foundation/Foundation.h>
#import "XMPPRoster.h"


@interface XMPPRoster (iKnowFollow)

- (BOOL)userIsOnLine:(XMPPJID *)jid;

//假同步不能保证一定操作成功
- (BOOL)addBuddySync:(XMPPJID *)jid;
- (BOOL)removeBuddySync:(XMPPJID *)jid;

- (BOOL)addFollowSync:(XMPPJID *)jid;
- (BOOL)removeFollowSync:(XMPPJID *)jid;

@end
