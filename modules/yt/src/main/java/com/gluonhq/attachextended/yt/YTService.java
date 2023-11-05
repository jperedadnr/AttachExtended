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
package com.gluonhq.attachextended.yt;

import com.gluonhq.attach.util.Services;
import javafx.geometry.Pos;

import java.util.Optional;

public interface YTService {

    /**
     * Returns an instance of {@link YTService}.
     * @return An instance of {@link YTService}.
     */
    static Optional<YTService> create() {
        return Services.get(YTService.class);
    }

    /**
     * Plays a video.
     *
     * @param videoId A string with the video id to be played.
     */
    void play(String videoId);

    /**
     * Removes the layer with the control, so the JavaFX layer can resume normal
     * interaction. If a media file is currently playing, it will be stopped.
     *
     * <p>This method can be called at any time to stop and hide the media player.
     */
    void hide();

    /**
     * Allows setting the position of the media file. Only valid when full screen
     * is disabled.
     *
     * @param alignment values for describing vertical and horizontal positioning
     * and alignment
     * @param topPadding the top padding value, relative to the screen
     * @param rightPadding the right padding value, relative to the screen
     * @param bottomPadding the bottom padding value, relative to the screen
     * @param leftPadding the left padding value, relative to the screen
     */
    void setPosition(Pos alignment, double topPadding, double rightPadding, double bottomPadding, double leftPadding);
}
