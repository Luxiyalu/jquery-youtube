# jquery-youtube

# What it does

1. Wraps up YouTube iFrame API with jQuery access $('#ytplayer').play()
2. Lays out events by name instead of the original state change 1, 2, 3... (onReady, onStart, onPause, onEnd...)
3. Adds API for full-screen feature $('#player').toggleFullScreen()

# How to use

```html
<!-- If you want the full-screen API, add a container div -->
<div class="random-class-name">
    <div id="ytplayer"></div>
</div>
```

```css
/* If you want the full-screen API to work, add this in your stylesheet: */
:-webkit-full-screen{
    top: 0;
    width: 100% !important;
    height: 100% !important;
    position: absolute !important;
}
iframe{
    width: 100%;
    height: 100%;
}
```


```javascript
$('#ytplayer').YTplayer({
    width: 1000,
    height: 560,
    videoId: 'n4JD-3-UAzM',
    onReady: function(){
        // on video ready
    },
    onStart: function(){
        // on video start
    },
    onPause: function(){
        // on video pause
    },
    onEnd: function(){
        // on video end
    },
    onBuffer: function(){
        // on video buffer
    },
    playerVars: {
      controls: 0,
      showinfo: 0,
      iv_load_policy: 3 # hide video annotations,
    }
});
```




