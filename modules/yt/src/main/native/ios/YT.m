/*
 * Copyright (c) 2023, Gluon
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GLUON BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#include "YT.h"


JNIEnv *env;

JNIEXPORT jint JNICALL
JNI_OnLoad_YT(JavaVM *vm, void *reserved)
{
#ifdef JNI_VERSION_1_8
    //min. returned JNI_VERSION required by JDK8 for builtin libraries
    if ((*vm)->GetEnv(vm, (void **)&env, JNI_VERSION_1_8) != JNI_OK) {
        return JNI_VERSION_1_4;
    }
    return JNI_VERSION_1_8;
#else
    return JNI_VERSION_1_4;
#endif
}

static int YTInited = 0;

YT *_yt;

BOOL init;
UIView *_currentView;
UIViewController *rootViewController;

BOOL showing, fullScreenMode;
int alignH;
int alignV;
double topPadding, rightPadding, bottomPadding, leftPadding;

JNIEXPORT void JNICALL Java_com_gluonhq_attachextended_yt_impl_IOSYTService_initYT
(JNIEnv *env, jclass jClass)
{
    if (YTInited)
    {
        return;
    }
    YTInited = 1;

    AttachLog(@"Init YT");
    _yt = [[YT alloc] init];
}


JNIEXPORT void JNICALL Java_com_gluonhq_attachextended_yt_impl_IOSYTService_playVideo
(JNIEnv *env, jclass jClass, jstring jVideoId)
{
    const jchar *charsVideoId = (*env)->GetStringChars(env, jVideoId, NULL);
    NSString *videoId = [NSString stringWithCharacters:(UniChar *)charsVideoId length:(*env)->GetStringLength(env, jVideoId)];
    if (debugAttach) {
        AttachLog(@"YT Service: %@", videoId);
    }
    [_yt play:videoId];
    (*env)->ReleaseStringChars(env, jVideoId, charsVideoId);
    return;
}

JNIEXPORT void JNICALL Java_com_gluonhq_attachextended_yt_impl_IOSYTService_setPosition
(JNIEnv *env, jclass jClass, jstring jalignmentH, jstring jalignmentV, jdouble jtopPadding,
        jdouble jrightPadding, jdouble jbottomPadding, jdouble jleftPadding)
{
    const jchar *charsAlignH = (*env)->GetStringChars(env, jalignmentH, NULL);
    NSString *sAlignH = [NSString stringWithCharacters:(UniChar *)charsAlignH length:(*env)->GetStringLength(env, jalignmentH)];
    (*env)->ReleaseStringChars(env, jalignmentH, charsAlignH);

    const jchar *charsAlignV = (*env)->GetStringChars(env, jalignmentV, NULL);
    NSString *sAlignV = [NSString stringWithCharacters:(UniChar *)charsAlignV length:(*env)->GetStringLength(env, jalignmentV)];
    (*env)->ReleaseStringChars(env, jalignmentV, charsAlignV);
    if (debugAttach) {
        AttachLog(@"YT Video Alignment H: %@, V: %@", sAlignH, sAlignV);
    }

    if ([sAlignH isEqualToString:@"LEFT"]) {
        alignH = -1;
    } else if ([sAlignH isEqualToString:@"RIGHT"]) {
        alignH = 1;
    } else {
        alignH = 0;
    }
    if ([sAlignV isEqualToString:@"TOP"]) {
        alignV = -1;
    } else if ([sAlignV isEqualToString:@"BOTTOM"]) {
        alignV = 1;
    } else {
        alignV = 0;
    }
    topPadding = jtopPadding;
    rightPadding = jrightPadding;
    bottomPadding = jbottomPadding;
    leftPadding = jleftPadding;

    [_yt resizeRelocateVideo];
    return;
}

JNIEXPORT void JNICALL Java_com_gluonhq_attachextended_yt_impl_IOSYTService_hideVideo
(JNIEnv *env, jclass jClass)
{
    if (_yt)
    {
        [_yt hideVideo];
    }
    return;
}

@implementation YT

- (void)initYT
{
    [self logMessage:@"Init window"];
    if(![[UIApplication sharedApplication] keyWindow])
    {
        AttachLog(@"key window was nil");
        return;
    }

    NSArray *views = [[[UIApplication sharedApplication] keyWindow] subviews];
    if(![views count]) {
        AttachLog(@"views size was 0");
        return;
    }

    _currentView = views[0];


    rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if(!rootViewController)
    {
        AttachLog(@"rootViewController was nil");
        return;
    }

    self.playerView = [[YTPlayerView alloc] init];
    self.playerView.delegate = self;
    AttachLog(@"IOSYTService playerView: %@", self.playerView);

    [self resizeRelocateVideo];
    [_currentView addSubview: self.playerView];
    init = YES;
}

- (void) play:(NSString *)videoId
{
    if (!init) {
        [_yt initYT];
        if (!init) {
            return;
        }
    }

    // TODO: API to configure this:
    NSDictionary *playerVars = @{
      @"controls" : @1,
      @"playsinline" : @1,
      @"autohide" : @1,
      @"showinfo" : @0,
      @"modestbranding" : @1
    };

    AttachLog(@"IOSYTService play: %@", videoId);
    [self.playerView loadWithVideoId:videoId playerVars:playerVars];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(receivedPlaybackStartedNotification:)
                                                   name:@"Playback started"
                                                 object:nil];
}

-(void)hideVideo
{
    AttachLog(@"YTVideo removeWebView");
    [self.playerView removeWebView];
}

- (void) resizeRelocateVideo
{
    AttachLog(@"YTVideo resize and relocate");
    CGRect theLayerRect = [[UIScreen mainScreen] bounds];
    if (fullScreenMode) {
        self.playerView.frame = theLayerRect;
    }
    else
    {
        double maxW = theLayerRect.size.width - (leftPadding + rightPadding);
        double maxH = theLayerRect.size.height - (topPadding + bottomPadding);
        AttachLog(@"Video max size: %f x %f", maxW, maxH);

            CGFloat movieAspectRatio = 16.0f / 9.0f;
            CGFloat viewAspectRatio = maxW / maxH;
            [self logMessage:@"Video movie ratio: %f, view ratio: %f", movieAspectRatio, viewAspectRatio];

            CGRect theVideoRect = CGRectZero;
            [self logMessage:@"Video set video rect: %@", NSStringFromCGRect(theVideoRect)];

            if (viewAspectRatio < movieAspectRatio) {
                theVideoRect.size.width = maxW;
                theVideoRect.size.height = maxW / movieAspectRatio;
                [self logMessage:@"Video video size %@", NSStringFromCGSize(theVideoRect.size)];
                theVideoRect.origin.x = leftPadding;
                if (alignV == -1) {
                    theVideoRect.origin.y = topPadding;
                } else if (alignV == 0) {
                    theVideoRect.origin.y = topPadding + (maxH - theVideoRect.size.height) / 2;
                } else {
                    theVideoRect.origin.y = topPadding + (maxH - theVideoRect.size.height);
                }
            } else  {
                theVideoRect.size.width = movieAspectRatio * maxH;
                theVideoRect.size.height = maxH;
                [self logMessage:@"Video video size %@", NSStringFromCGSize(theVideoRect.size)];
                if (alignH == -1) {
                    theVideoRect.origin.x = leftPadding;
                } else if (alignH == 0) {
                    theVideoRect.origin.x = leftPadding + (maxW - theVideoRect.size.width) / 2;
                } else {
                    theVideoRect.origin.x = leftPadding + (maxW - theVideoRect.size.width);
                }
                theVideoRect.origin.y = topPadding;
            }
            [self logMessage:@"Video video origin %f x %f", theVideoRect.origin.x, theVideoRect.origin.y];

            [self logMessage:@"Video frame: %@", NSStringFromCGRect(theVideoRect)];
            self.playerView.frame = theVideoRect;
    }
}

- (void)playerView:(YTPlayerView *)ytPlayerView didChangeToState:(YTPlayerState)state {
    NSString *message = [NSString stringWithFormat:@"Player state changed: %ld\n", (long)state];
    AttachLog(@"IOSYTService message: %@", message);
}

- (void)receivedPlaybackStartedNotification:(NSNotification *) notification {
    AttachLog(@"IOSYTService notification: %@", notification);
    if([notification.name isEqual:@"Playback started"] && notification.object != self) {
        [self.playerView pauseVideo];
    }
}

- (void) logMessage:(NSString *)format, ...;
{
    if (debugAttach)
    {
        va_list args;
        va_start(args, format);
        NSLogv([@"[Debug] " stringByAppendingString:format], args);
        va_end(args);
    }
}
@end