# Youtube-jQuery: create iFrame player with jQuery
# 
# Version 0.1.0
# https://github.com/Luxiyalu/youtube-jquery
# Copyright (c) 2010-2014 Lucia Lu
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

do (window, $ = window.jQuery) ->
  jyt = jyt || {}
  jyt.init = (feature) ->
    @ApiReady = false
    
    # platform detect
    ua = window.navigator.userAgent.toLowerCase()
    @platform =
      isIE8: ua.match(/msie 8/) isnt null
      
    # feature detect
    @feature = feature || if @platform.isIE8 then 'flash' else 'iframe'
      
    # flash feature would 
    # if @feature is 'iframe' then @iframe.init()
    do @[@feature].init
    do @registerPackage
      
  jyt.onApiReady = ->
    console.log @feature, 'API ready, initialize Video.'
    @ApiReady = true
    
    # load all the players in the queue
    for own id, value of @YTplayers
      value = @[@feature].initializeVideo(id, value) if !value.initialized
      
  jyt.pushToQueue = (id, options) ->
    @YTplayers[id] = options
    @YTplayers[id].initialized = false
    
  jyt.util =
    objToUrl: (obj) ->
      i = 0
      string = ""
      for own key, value of obj
        link = if i is 0 then "?" else "&"
        string += "#{link}#{key}=#{value}"
        i++
      string
      
  jyt.iframe =
    init: ->
      console.log 'init iframe'
      
      # Register onReady event
      window.onYouTubeIframeAPIReady = =>
        jyt.onApiReady()
        
      # Lazy load in the required iframeAPI script from youtube
      tag = document.createElement('script')
      tag.src = "https://www.youtube.com/iframe_api"
      firstScriptTag = document.getElementsByTagName('script')[0]
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
      
    initializeVideo: (id, options) ->
      options.playerVars = options.playerVars || {}
      options.playerVars.wmode = 'opaque'
      options.playerVars.html5 = 1 # force flash when both flash and html5 are available
      
      player = new YT.Player id,
        wmode: 'opaque'
        width: options.width
        height: options.height
        videoId: options.videoId
        playerVars: options.playerVars
        # reference: https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
        events:
          onReady: options.onReady
          onStateChange: (e) ->
            options.onStateChange?(e)
            switch e.data
              # when -1 then options.onReady?(e)
              when 0 then options.onEnd?(e)
              when 1 then options.onPlay?(e)
              when 2 then options.onPause?(e)
              when 3 then options.onBuffer?(e)
          onPlaybackQualityChange: options.onPlaybackQualityChange
          onPlaybackRateChange: options.onPlaybackRateChange
          onApiChange: options.onApiChange
          onError: options.onError
      # return player
      console.log 'video initialized'
      jyt.YTplayers[id] = player

  jyt.flash =
    init: ->
      console.log 'init flash'
      
      # Lazy load in the required swfoBject script from youtube
      tag = document.createElement('script')
      tag.onload = () ->
        console.log 'swfobject script load'
        jyt.onApiReady()
        
      tag.src = "http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js"
      firstScriptTag = document.getElementsByTagName('script')[0]
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
      
    initializeVideo: (id, options) ->
      console.log 'flash initialiseVideo'
      
      options.playerVars = options.playerVars || {}
      options.playerVars.wmode = 'opaque'
      options.playerVars.version = 3
      options.playerVars.enablejsapi = 1
      options.playerVars.playerapiid = options.videoId
      
      urlParam = jyt.util.objToUrl(options.playerVars)
      swfobject.embedSWF "http://www.youtube.com/v/#{options.videoId}#{urlParam}",
        id, options.width, options.height, "8", null, null,
        {allowScriptAccess: 'always'}, {id: id}
        
      # Register onReady event
      window.onYouTubePlayerReady = (videoId) ->
        console.log 'flash onYouTubePlayerReady'
        # options.onReady?()
        
        # bind events
        player = document.getElementById(id)
        window["#{id}OnStateChange"] = (e) ->
          options.onStateChange?(e)
          switch e
            when -1 then options.onReady?(e)
            when 0 then options.onEnd?(e)
            when 1 then options.onPlay?(e)
            when 2 then options.onPause?(e)
            when 3 then options.onBuffer?(e)
        window["#{id}OnError"] = (e) -> options.onError?(e)
        window["#{id}OnApiChange"] = (e) -> options.onApiChange?(e)
        window["#{id}OnPlaybackRateChange"] = (e) -> options.onPlaybackRateChange?(e)
        window["#{id}OnPlaybackQualityChange"] = (e) -> options.onPlaybackQualityChange?(e)
        
        player.addEventListener('onError', "#{id}OnError")
        player.addEventListener('onApiChange', "#{id}OnApiChange")
        player.addEventListener('onStateChange', "#{id}OnStateChange")
        player.addEventListener('onPlaybackRateChange', "#{id}OnPlaybackRateChange")
        player.addEventListener('onPlaybackQualityChange', "#{id}OnPlaybackQualityChange")
        # don't listen to anonymous function here, because it has to be called
        # from within flash. It needs a string.
        jyt.YTplayers[id] = player
        window.player = player
        return
    
  # Initialise with jQuery
  $::YTplayer = (options) ->
    # Default options
    @id = $(this).attr('id')
    @width = options.width || 640
    @height = options.height || 480
    @videoId = options.videoId || 'fz4MzJTeL0c'
    @playerVars = options.playerVars
    
    {
      # events
      @onReady, @onStateChange,
      @onStart, @onEnd, @onPlay, @onPause, @onBuffer,
      @onPlaybackQualityChange, @onPlaybackRateChange,
      @onError, @onApiChange
    } = options
    
    # push to queue, or initialize right away
    jyt.YTplayers = jyt.YTplayers || {}
    
    if jyt.ApiReady
      console.log jyt.feature, 'API ready, initialize Video.'
      jyt[jyt.feature].initializeVideo(@id, this)
    else
      console.log jyt.feature, 'API not ready, queue Video.'
      jyt.pushToQueue(@id, this)
      
  ## APIs
  # reference here: https://developers.google.com/youtube/iframe_api_reference
  jyt.registerPackage = ->
    
    # abstraction
    @registerPackage = (alias, name = alias) ->
      $::[alias] = (args...) ->
        id = $(this).attr('id')
        return if jyt.YTplayers[id] is undefined
        player = jyt.YTplayers[id]
        return if player.initialized is false
        player[name]?.apply(player, args)
        
    # play related
    @registerPackage('play', 'playVideo')
    @registerPackage('pause', 'pauseVideo')
    @registerPackage('stop', 'stopVideo')
    @registerPackage('clear', 'clearVideo')
    @registerPackage('seekTo')
      
    for fn in [
      'setSize', # player size
      'mute', 'unMute', 'isMuted', 'setVolume', 'getVolume', # volume related
      'getVideoLoadedFraction', 'getPlayerState', 'getCurrentTime', # playback status
      'setPlaybackRate', 'getPlaybackRate', 'getAvailablePlaybackRate', # playback rate
      'getPlaybackQuality', 'setPlaybackQuality', 'getAvailableQualityLevels', # playback quality
      'getDuration', 'getVideoUrl', 'getVideoEmbedCode', # retrieving video info
      'addEventListener', 'removeEventListener', # events
      'getIframe', 'destroy', # Accessing and modifying DOM nodes
    ]
      @registerPackage(fn)
      
    # add API for fullscreen
    enterFullscreen = (ele) ->
      if document.documentElement.requestFullscreen
        ele.requestFullscreen()
      else
        ele.msRequestFullscreen?()
        ele.mozRequestFullScreen?()
        ele.webkitRequestFullscreen?(Element.ALLOW_KEYBOARD_INPUT)
        
    exitFullscreen = (ele) ->
      if document.exitFullscreen
        document.exitFullscreen()
      else
        document.msExitFullscreen?()
        document.mozCancelFullScreen?()
        document.webkitExitFullscreen?()
        
    toggleFullscreen = (ele) ->
      if !$.fullscreenElement()
        # doesn't have full screen element yet
        enterFullscreen(ele)
        $(ele).addClass('ytplayer-fullscreen')
      else
        # some element is already full-screened
        exitFullscreen(ele)
        $(ele).removeClass('ytplayer-fullscreen')

    # fix esc exit
    $(document).on 'keyup', (e) ->
      if e.which is 27 && $('.ytplayer-fullscreen').length > 0
        $('.ytplayer-fullscreen').removeClass('ytplayer-fullscreen')

    # fix for firefox since it doesn't detect esc keystroke when fullscreen
    $(window).on 'resize', ->
      if $.fullscreenElement()
        $('.ytplayer-fullscreen').removeClass('ytplayer-fullscreen')

          
    $.fullscreenElement = ->
      ele = document.fullScreenElement || document.mozFullScreenElement || document.webkitFullscreenElement || document.msFullscreenElement
    $::enterFullscreen = ->
      enterFullscreen($(this)[0])
    $::exitFullscreen = ->
      exitFullscreen($(this)[0])
    $::toggleFullscreen = ->
      toggleFullscreen($(this)[0])
    
  # you can choose to initiate with either iframe or flash
  # jyt.init('iframe')
  # jyt.init('flash')
  jyt.init()