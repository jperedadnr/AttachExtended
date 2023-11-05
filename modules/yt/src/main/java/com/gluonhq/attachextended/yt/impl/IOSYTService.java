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
package com.gluonhq.attachextended.yt.impl;

import com.gluonhq.attach.storage.StorageService;
import com.gluonhq.attachextended.yt.YTService;
import javafx.geometry.Pos;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class IOSYTService implements YTService {

    static {
        System.loadLibrary("YT");
        initYT();
        loadResources();
    }

    @Override
    public void play(String videoId) {
        if (videoId != null && !videoId.isEmpty()) {
            playVideo(videoId);
        }
    }

    @Override
    public void hide() {
        hideVideo();
    }

    @Override
    public void setPosition(Pos alignment, double topPadding, double rightPadding, double bottomPadding, double leftPadding) {
        setPosition(alignment.getHpos().name(), alignment.getVpos().name(), topPadding, rightPadding, bottomPadding, leftPadding);
    }

    private static void loadResources() {
        final File assetsFolder;
        assetsFolder = new File(StorageService.create()
                .flatMap(StorageService::getPrivateStorage)
                .orElseThrow(() -> new RuntimeException("Error accessing Private Storage folder")), "assets");
        if (!assetsFolder.exists()) {
            assetsFolder.mkdir();
        }

        File ytFile = new File(assetsFolder, "YTPlayerView-iframe-player.html");
        if (!ytFile.exists()) {
            copyFile("/YTPlayerView-iframe-player.html", ytFile.getAbsolutePath());
        }
    }

    private static boolean copyFile(String pathIni, String pathEnd)  {
        try (InputStream input = IOSYTService.class.getResourceAsStream(pathIni)) {
            if (input == null) {
                return false;
            }
            try (OutputStream output = new FileOutputStream(pathEnd)) {
                byte[] buffer = new byte[1024];
                int length;
                while ((length = input.read(buffer)) > 0) {
                    output.write(buffer, 0, length);
                }
                output.flush();
                return true;
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // native
    private static native void initYT();
    private native void playVideo(String videoId);
    private native void hideVideo();
    private native void setPosition(String alignmentH, String alignmentV, double topPadding, double rightPadding, double bottomPadding, double leftPadding);

}
