# Youtube-jQuery: create iFrame player with jQuery
# 
# Version 0.0.1
# 
# https://github.com/Luxiyalu/youtube-jquery
# 
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
  youTubeIframeAPIReady = false
    
  # Lazy load in the required iframeAPI script from youtube
  tag = document.createElement('script')
  # tag.src = "https://www.youtube.com/iframe_api"
  tag.src = 'scripts/api.js'
  firstScriptTag = document.getElementsByTagName('script')[0]
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
    
  pushToQueue = (id, options) ->
    $.YTplayers = $.YTplayers || {}
    $.YTplayers[id] = options
    $.YTplayers[id].initialized = false
    
  initializeVideo = (id, options) ->
    window.player = new YT.Player id,
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
            when -1 then options.onStart?(e)
            when 0 then options.onEnd?(e)
            when 1 then options.onPlay?(e)
            when 2 then options.onPause?(e)
            when 3 then options.onBuffer?(e)
        onPlaybackQualityChange: options.onPlaybackQualityChange
        onPlaybackRateChange: options.onPlaybackRateChange
        onApiChange: options.onApiChange
        onError: options.onError
        
    $.YTplayers[id] = player
    $("##{id}").data('YTplayer', player)
    $("##{id}").parent().css(width: options.width, height: options.height)
    # console.log $.YTplayers
    
  # Preparation for the event
  window.onYouTubeIframeAPIReady = ->
    youTubeIframeAPIReady = true
    # load all the players
    for own id, value of $.YTplayers
      if !value.initialized
        value = initializeVideo(id, value)
        
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
    if !youTubeIframeAPIReady
      pushToQueue(@id, this)
    else
      initializeVideo(@id, this)
      
  ## APIs
  # reference here: https://developers.google.com/youtube/iframe_api_reference
    
  # abstraction
  registerPackage = (alias, name = alias) ->
    $::[alias] = (args...) ->
      player = $(this).data('YTplayer')
      return if player is undefined
      player[name]?.apply(player, args)
      
  # play related
  registerPackage('play', 'playVideo')
  registerPackage('pause', 'pauseVideo')
  registerPackage('stop', 'stopVideo')
  registerPackage('clear', 'clearVideo')
  registerPackage('seekTo')
    
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
    registerPackage(fn)
    
  # add API for fullscreen
  enterFullscreen = (ele) ->
    if document.documentElement.requestFullscreen
      ele.requestFullscreen()
    else
      ele.msRequestFullScreen?()
      ele.mozRequestFullScreen?()
      ele.webkitRequestFullScreen?(Element.ALLOW_KEYBOARD_INPUT)
      
  exitFullscreen = (ele) ->
    if document.exitFullscreen
      document.exitFullscreen()
    else
      document.msExitFullscreen?()
      document.mozCancelFullScreen?()
      document.webkitExitFullscreen?()
      
  toggleFullscreen = (ele) ->
    if !document.fullScreenElement && !document.mozFullScreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement
      # doesn't have full screen element yet
      enterFullscreen(ele)
    else
      # some element is already full-screened
      exitFullscreen(ele)
        
  $::enterFullscreen = ->
    enterFullscreen($(this).parent()[0])
  $::exitFullscreen = ->
    exitFullscreen($(this).parent()[0])
  $::toggleFullscreen = ->
    toggleFullscreen($(this).parent()[0])
