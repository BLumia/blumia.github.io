---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
nav-title: Home
title: 'BLumia :: Wrapzone'
css-style: >
  :root {
  --transition-time: 300ms;
  }
  .bl-item {
  transition: all var(--transition-time) ease-in-out;
  width: 5.5em;
  height: 5.5em;
  padding: .5em;
  margin: 2px;
  background-color: rgba(61,52,199,0.61);
  }
  .bl-item:hover {
  background-color: rgba(115,54,195,0.61);
  }
  .bl-item .bl-icon {
  font-size: 4em;
  color: white;
  transition: font-size var(--transition-time) ease-in-out;
  }
  .bl-sm-item {
  transition: all var(--transition-time) ease-in-out;
  width: 2.2em;
  height: 2.2em;
  padding: .5em;
  margin: 2px;
  background-color: rgba(61,52,199,0.61);
  /*background-color: rgba(241, 112, 112, 0.61); new year*/
  }
  .bl-sm-item:hover {
  background-color: rgba(115,54,195,0.61);
  }
  .bl-sm-item .bl-icon {
  font-size: 1.8em;
  color: white;
  transition: font-size var(--transition-time);
  }
---

<h3 class="nobb" style="margin:0 10px;">Services / Navigation:</h3>

<div class="flex row item-align-center h25p">
	<div onmouseover="updateSubTitle('Cnblogs')" class="bl-item flex item-justify-center">
		<a href="https://www.cnblogs.com/blumia/">
			<i class="bl-icon i i-cnblogs"></i>
		</a>
	</div>
	<div onmouseover="updateSubTitle('Recommends')" class="bl-item flex item-justify-center">
		<a href="https://blumia.pythonanywhere.com/">
			<i class="bl-icon i i-good"></i>
		</a>
	</div>
	<div onmouseover="updateSubTitle('Online Judge for ACM/ICPC')" class="bl-item flex item-justify-center">
		<a href="https://oj.blumia.cn/">
			<i class="bl-icon i i-code-braces"></i>
		</a>
	</div>
	<div onmouseover="updateSubTitle('TouHou Player')" class="bl-item flex item-justify-center">
		<a href="https://bearkidsteam.github.io/thplayer/">
			<i class="bl-icon i i-thplayer"></i>
		</a>
	</div>
	<div onmouseover="updateSubTitle('The Witness Solver')" class="bl-item flex item-justify-center">
		<a href="https://blumia.net/TheWitnessSolver/">
			<i class="bl-icon i i-puzzle"></i>
		</a>
	</div>
</div>

<h3 class="nobb" style="margin-bottom:0;">Social links:</h3>

<div class="flex row item-align-center h25p">
	<div onmouseover="updateSubTitle('Twitter')" class="bl-sm-item flex item-justify-center">
		<a href="https://twitter.com/BLumiaW">
			<i class="bl-icon i i-twitter"></i>
		</a>
	</div>
	<div onmouseover="updateSubTitle('<a href=\'./sbeam.html\' class=\'nobb\'>sbeam</a>')" class="bl-sm-item flex item-justify-center">
		<a href="https://steamcommunity.com/id/BLumia/">
			<i class="bl-icon i i-steam"></i>
		</a>
	</div>
	<div onmouseover="updateSubTitle('GayHub')" class="bl-sm-item flex item-justify-center">
		<a href="https://github.com/blumia/">
			<i class="bl-icon i i-github"></i>
		</a>
	</div>
	<div onmouseover="updateSubTitle('Bandcamp')" class="bl-sm-item flex item-justify-center">
		<a href="https://blumia.bandcamp.com/">
			<i class="bl-icon i i-bandcamp"></i>
		</a>
	</div>
	<div onmouseover="updateSubTitle('Netease Musician')" class="bl-sm-item flex item-justify-center">
		<a href="https://music.163.com/artist/album?id=12194546">
			<i class="bl-icon i i-netease-music"></i>
		</a>
	</div>
</div>
<script>
var timerFunction = setTimeout("updateSubTitle()",3000);
function updateSubTitle(text) {
	if (text == document.getElementsByClassName('sub-title')[0].innerHTML) 
		return;
	window.clearTimeout(timerFunction);
	//console.log(text);
	document.getElementsByClassName('sub-title')[0].innerHTML=text == undefined ? "hOi !!" : text;
	timerFunction = setTimeout("updateSubTitle()",3000);

}
</script>
