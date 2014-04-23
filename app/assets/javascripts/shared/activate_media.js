var yt_api = document.createElement('script');
yt_api.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(yt_api, firstScriptTag);

var iframesReady = false;

var yt_queue = new Array();
function onYouTubeIframeAPIReady(){
  iframesReady = true;
  // Process all queued youtube iframes
  $.each(yt_queue, function(index,yt_id) {
    new YT.Player("video"+index, {
      width: '100%',
      videoId: yt_id
    });
  });
}

var imgStr = "\.(jpg|gif|png)+"
var youtubeStr = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/;

// Expand <a /> with its associate application, ex. img, youtube
function activate_media(){
  var videoCount = 0;
  $("#main-container .comment_bodies a").filter(function(){
      // image url
    var url = $(this).attr("href");
    if( url.match(imgStr)) {
      $(this).replaceWith($("<img>").attr("src",url).addClass("comment_img"));
    }
    // youtube url
    var yt_match = url.match(youtubeStr);  // dessemble youtube url into fields
    if( yt_match && yt_match[7].length==11 ) {
      $(this).replaceWith("<div class='youtube-iframe'><a id='video" + videoCount + "'></a></div>");
      
      if (iframesReady) {
        new YT.Player("video"+videoCount, {
          width: '100%',
          videoId: yt_match[7]
        });
      }
      else {
         yt_queue.push( yt_match[7] );
      }
      videoCount++;
    }
  });
}