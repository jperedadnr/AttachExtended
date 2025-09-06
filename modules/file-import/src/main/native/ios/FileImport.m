/*
 * Copyright (c) 2025, Gluon
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
#include "FileImport.h"

JNIEnv *env;

JNIEXPORT jint JNICALL
JNI_OnLoad_FileImport(JavaVM *vm, void *reserved)
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

static int fileImportInited = 0;

 // FileImport
 jclass mat_jFileImportServiceClass;
 jmethodID mat_jFileImportService_setResult = 0;
 FileImport *_fileImport;

JNIEXPORT void JNICALL Java_com_gluonhq_attachextended_fileimport_impl_IOSFileImportService_initFileImport
(JNIEnv *env, jclass jClass)
{
    if (fileImportInited)
    {
        return;
    }
    fileImportInited = 1;

    mat_jFileImportServiceClass = (*env)->NewGlobalRef(env, (*env)->FindClass(env, "com/gluonhq/attachextended/fileimport/impl/IOSFileImportService"));
    mat_jFileImportService_setResult = (*env)->GetStaticMethodID(env, mat_jFileImportServiceClass, "setFileResult", "(Ljava/lang/String;Ljava/lang/String;)V");
}

void sendFileResult(NSString *picResult, NSString *picPath) {
    if (picResult)
    {
        const char *picChars = [picResult UTF8String];
        jstring jpic = (*env)->NewStringUTF(env, picChars);
        const char *pathChars = [picPath UTF8String];
        jstring jpath = (*env)->NewStringUTF(env, pathChars);
        (*env)->CallStaticVoidMethod(env, mat_jFileImportServiceClass, mat_jFileImportService_setResult, jpic, jpath);
        (*env)->DeleteLocalRef(env, jpic);
        (*env)->DeleteLocalRef(env, jpath);
        AttachLog(@"Finished sending file");
    } else
    {
        (*env)->CallStaticVoidMethod(env, mat_jFileImportServiceClass, mat_jFileImportService_setResult, NULL, NULL);
    }
}

JNIEXPORT void JNICALL Java_com_gluonhq_attachextended_fileimport_impl_IOSFileImportService_selectFile
 (JNIEnv *env, jclass jClass)
 {
     if (debugAttach) {
         AttachLog(@"File Import Service: select file");
     }
     _fileImport = [[FileImport alloc] init];
     [_fileImport selectFile];
     return;
 }

 @implementation FileImport

- (void)selectFile {
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

    UIView *_currentView = views[0];

    UIDocumentPickerViewController *documentProvider;
    documentProvider = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:[NSArray arrayWithObjects:@"public.plain-text", nil] inMode: UIDocumentPickerModeOpen];
    documentProvider.delegate = self;
    documentProvider.modalPresentationStyle = UIModalPresentationOverFullScreen;

    [_currentView.window addSubview:documentProvider.view];

}

- (void) documentPicker: (UIDocumentPickerViewController *) controller didPickDocumentAtURL: (NSURL *) url
{
    if (controller.documentPickerMode == UIDocumentPickerModeOpen)
    {
            BOOL isAccess = [url startAccessingSecurityScopedResource];
            if(!isAccess)
            {
                return;
            }

            NSError * fileOpenError = nil;
            NSString * fileContents = [NSString stringWithContentsOfURL: url
                                                               encoding: NSUTF8StringEncoding
                                                                  error: &fileOpenError];

            // FileContents should now be set properly.

            [url stopAccessingSecurityScopedResource];
    }
}

@end