//
//  AdjustAdobeExtensionSharedStateListener.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 04/09/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import "AdjustAdobeExtensionSharedStateListener.h"
#import "AdjustAdobeExtension.h"
#import <ACPCore/ACPExtension.h>

NSString * const ADJAdobeModuleConfiguration = @"com.adobe.module.configuration";

NSString * const ADJConfigurationAppToken = @"adjustAppToken";
NSString * const ADJConfigurationTrackAttribution = @"adjustTrackAttribution";

@implementation AdjustAdobeExtensionSharedStateListener

- (void)hear:(ACPExtensionEvent *)event {
    NSDictionary *eventData = [event eventData];

    if (!eventData) {
        return;
    }
    if (![eventData[@"stateowner"] isEqualToString:ADJAdobeModuleConfiguration]) {
        return;
    }

    NSError *error = nil;
    NSDictionary *configSharedState =
        [self.extension.api getSharedEventState:ADJAdobeModuleConfiguration event:event error:&error];

    if (error) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:@"Error on getSharedEventState %@:%zd.",
                      [error domain],
                      [error code]]];
        return;
    }

    NSString *adjustAppToken = [configSharedState objectForKey:ADJConfigurationAppToken];
    id adjustTrackAttribution = [configSharedState objectForKey:ADJConfigurationTrackAttribution];

    if (adjustAppToken == nil || adjustTrackAttribution == nil) {
        return;
    }

    if (![self.extension isKindOfClass:[AdjustAdobeExtension class]]) {
        return;
    }

    AdjustAdobeExtension *adjExt = (AdjustAdobeExtension *)[self extension];

    BOOL shouldTrackAttribution =
        [adjustTrackAttribution isKindOfClass:[NSNumber class]]
        && [adjustTrackAttribution integerValue] == 1;

    [adjExt setupAdjustWithAppToken:adjustAppToken trackAttribution:shouldTrackAttribution];
}

@end
