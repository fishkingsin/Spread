# jpg -> video with effect
if [ ! -f 1.mp4 ]; then
  ffmpeg -i img/1.jpg -filter_complex "zoompan=z='zoom+0.002':d=25*4:s=1280x800" -pix_fmt yuv420p -c:v libx264 1.mp4
fi
if [ ! -f 2.mp4 ]; then
  ffmpeg -i img/2.jpg -filter_complex "zoompan=z='zoom+0.002':d=25*4:s=1280x800" -pix_fmt yuv420p -c:v libx264 2.mp4 
fi
if [ ! -f 3.mp4 ]; then
  ffmpeg -i img/3.jpg -filter_complex "pad=w=720:h=450:x='(ow-iw)/2':y='(oh-ih)/2',zoompan=z='zoom+0.002':d=25*4:s=1280x800" -pix_fmt yuv420p -c:v libx264 3.mp4
fi
if [ ! -f 4.mp4 ]; then
  ffmpeg -i img/4.jpg -filter_complex "pad=w=3200:h=2330:x='(ow-iw)/2':y='(oh-ih)/2',zoompan=x='(iw-0.425*ih)/2':y='(1-on/(25*8))*(ih-ih/zoom)':z='if(eq(on,1),2.56,zoom+0.002)':d=25*8:s=1280x800"  -pix_fmt yuv420p -c:v libx264 4.mp4
fi

# concat effect jpg to video
if [ ! -f out.mp4 ]; then
  ffmpeg -i 1.mp4 -i 2.mp4 -i 3.mp4 -i 4.mp4 -filter_complex "[0:v:0][1:v:0][2:v:0][3:v:0]concat=n=4:v=1[outv]" -map "[outv]"  tmp.mp4
  ffmpeg -f concat -i slides -c copy out.mp4
fi

# add captions
if [ ! -f video.mp4 ]; then
  FONTPATH="/System/Library/Fonts/STHeiti\ Medium.ttc"
  TEXT=("仔細回想一下，當初剛剛把狗狗帶回家的時候" "我們給牠起了名字，然後一遍遍的叫牠" "為了得到牠的應允，我們不惜拿出很多的零食來誘惑牠" "久而久之，狗狗便記住了這個指令" "我們給牠零食時喊牠名字；對牠進行喚回訓練時喊牠名字" "牠犯錯時我們也喊牠名字；甚至教訓牠時我們喊的還是牠名字....." "這個時候狗狗就會很鬱悶，我的這個「名字」到底代表著什麼意思呢" "是表達愛？還是懲罰" "牠不知道你喊的名字對牠來說是好事還是壞事" "在對牠有好處的事情發生時，你可以叫牠的名字" "如果是不好的事情，比如牠犯了錯" "你最好別喊牠名字，這個時候你只需要表達出你很生氣就行了" "這樣一來，狗狗逐漸的就會明白" "「名字」對於牠來說是有好事發生了" "在你喊牠名字的時候，牠就會很快的回應你" )

  filter=""
  cnt=1
  for i in "${TEXT[@]}"
  do
    filter="$filter drawtext=enable='between(t,$cnt,$((cnt+=6)))': \
    fontfile=$FONTPATH: \
    text='$i': \
    fontcolor=0xFFFFFFFF: \
    fontsize=36: \
    shadowcolor=black: \
    shadowx=3: \
    shadowy=2: \
    x=(w-tw)/2: \
    y=(h-th)/1.35,"
  done
  filter=${filter%?}
  echo $cnt
  ffmpeg -i out.mp4 \
    -vf "[in] \
    $filter \
    [out]
    " \
    caption.mp4

  ffmpeg -f concat -i cores -c copy video.mp4
fi

# add audio
ffmpeg -i video.mp4 -i dog.mp3 -codec copy -shortest spread.mp4

