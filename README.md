# jquery-youtube

## What it does

1. Wraps up YouTube iFrame API with jQuery access ```$('#ytplayer').play()```
2. Lays out events by name instead of the original state change 1, 2, 3... (```onReady, onStart, onPause, onEnd...```)
3. Adds API for full-screen feature ```$('#player').toggleFullScreen()```
4. Adds a patch for the wmode issue

## How to use

#### HTML
```html
<div id="ytplayer"></div>
```

#### CSS
```css
/* If you want the full-screen API to work, add this in your stylesheet: */
:-webkit-full-screen{
    top: 0;
    width: 100%;
    height: 100%;
    position: absolute;
}
```

#### JavaScript
```javascript
// Initiating
$('#ytplayer').YTplayer({});

// With configurations
$('#ytplayer').YTplayer({
    // Basic setting
    width: 1000,                // video width
    height: 560,                // video height
    videoId: 'n4JD-3-UAzM',     // youtube video id

    // Events
    onReady: function(){},      // on video ready
    onStart: function(){},      // on video start
    onPause: function(){},      // on video pause
    onEnd: function(){},        // on video end
    onBuffer: function(){},     // on video buffer
    onStateChange: function(){}, // will be triggered by all the 5 events above
    
    // Player variables
    playerVars: {
        autohide: 2,            // Values: 2 (default), 1, and 0. This parameter indicates whether the video controls will automatically hide after a video begins playing
        autoplay: 0,            // Values: 0 or 1. Default is 0. Sets whether or not the initial video will autoplay when the player loads.
        cc_load_policy: 1,      // Values: 1. Default is based on user preference. Setting to 1 will cause closed captions to be shown by default, even if the user has turned captions off.
        color: 'red',           // Valid parameter values are red and white, and, by default, the player will use the color red in the video progress bar.
        controls: 0,            // Values: 0 (do not display), 1, or 2. Default is 1. This parameter indicates whether the video player controls will display
        disablekb: 0,           // Values: 0 or 1. Default is 0. Setting to 1 will disable the player keyboard controls
        enablejsapi: 0,         // Values: 0 or 1. Default is 0. Setting this to 1 will enable the Javascript API
        end: number,            // Values: A positive integer. This parameter specifies the time, measured in seconds from the start of the video, when the player should stop playing the video
        fs: 1,                  // Values: 0 or 1. The default value is 1, which causes the fullscreen button to display. Setting this parameter to 0 prevents the fullscreen button from displaying
        hl: 'en',               // Sets the player's interface language
        iv_load_policy: 3,      // Values: 1 or 3. Default is 1. Setting to 1 will cause video annotations to be shown by default, whereas setting to 3 will cause video annotations to not be shown by default
        modestbranding: 1,      // This parameter lets you use a YouTube player that does not show a YouTube logo. Set the parameter value to 1 to prevent the YouTube logo from displaying in the control bar
        origin: '',             // This parameter provides an extra security measure for the IFrame API and is only supported for IFrame embeds. If you are using the IFrame API, which means you are setting the enablejsapi parameter value to 1, you should always specify your domain as the origin parameter value
        playsinline: 0,         // This parameter controls whether videos play inline or fullscreen in an HTML5 player on iOS
        rel: 1,                 // Values: 0 or 1. Default is 1. This parameter indicates whether the player should show related videos when playback of the initial video ends
        showinfo: 1,            // Values: 0 or 1. The parameter's default value is 1. If you set the parameter value to 0, then the player will not display information like the video title and uploader before the video starts playing
        start: number,          // Values: A positive integer. This parameter causes the player to begin playing the video at the given number of seconds from the start of the video
        theme: 'dark'           // This parameter indicates whether the embedded player will display player controls (like a play button or volume control) within a dark or light control bar. Valid parameter values are dark and light
    }
    // full reference: https://developers.google.com/youtube/player_parameters.html?playerVersion=HTML5
});
```

## API
After the initiation, you could access the player like this: ```$('#ytplayer').pause()```. The APIs include:

```javascript
// Playing a video
play()                          // plays video
pause()                         // pauses video
stop()                          // stops video
clear()                         // Clears the video display. This function is useful if you want to clear the video remnant after calling stopVideo()
seekTo(seconds:Number, allowSeekAhead:Boolean) // Seeks to a specified time in the video. If the player is paused when the function is called, it will remain paused.

// Fullscreen feature
enterFullscreen()               // enters fullscreen
exitFullscreen()                // exits fullscreen
toggleFullscreen()              // toggles fullscreen

// Changing the player volume
mute()                          // mutes the player
unmute()                        // unmutes the player
isMuted()                       // Returns true if the player is muted, false if not
getVolume()                     // Returns the player's current volume, an integer between 0 and 100. Note that getVolume() will return the volume even if the player is muted
setVolume(volume:Number)        // Sets the volume. Accepts an integer between 0 and 100

// Setting the player size
setSize(width:Number, height:Number) // Sets the size in pixels of the <iframe> that contains the player

// Setting the playback rate
getPlaybackRate()               // This function retrieves the playback rate of the currently playing video. The default playback rate is 1. Playback rates may include values like 0.25, 0.5, 1, 1.5, and 2
setPlaybackRate(suggestedRate:Number) // This function sets the suggested playback rate for the current video
getAvailablePlaybackRates()     // This function returns the set of playback rates in which the current video is available

// Playback status
getVideoLoadedFraction()        // Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
getPlayerState()                // Returns the state of the player. Possible values are: -1 – unstarted, 0 – ended, 1 – playing, 2 – paused, 3 – buffering, 5 – video cued
getCurrentTime()                // Returns the elapsed time in seconds since the video started playing

// Playback quality
getPlaybackQuality()            // This function retrieves the actual video quality of the current video. Possible return values are highres, hd1080, hd720, large, medium and small. It will also return undefined if there is no current video
setPlaybackQuality(suggestedQuality:String) // This function sets the suggested video quality for the current video
getAvailableQualityLevels()     // This function returns the set of quality formats in which the current video is available. You could use this function to determine whether the video is available in a higher quality than the user is viewing, and your player could display a button or other element to let the user adjust the quality

// Retrieving video information
getDuration()                   // Returns the duration in seconds of the currently playing video
getCurrentTime()                // Returns the elapsed time in seconds since the video started playing
getVideoUrl()                   // Returns the YouTube.com URL for the currently loaded/playing video
getVideoEmbedCode()             // Returns the embed code for the currently loaded/playing video
```

Full reference: https://developers.google.com/youtube/iframe_api_reference
