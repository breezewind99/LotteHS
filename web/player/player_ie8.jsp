<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!--플레이어 영역-->

<div class="tableSize4">
	<div id="outer_player">
		<object width="474" height="140" id="player" name="player"
			classid="CLSID:6BF52A52-394A-11D3-B153-00C04F79FAA6"
			codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701"
			standby="Loading Microsoft Windows Media Player components..."
			type="application/x-wav">
			<param name="filename" value="<?=$listen_file?>" />
			<param name="Url" value="<?=$listen_file?>" />
			<param name="animationatstart" value="1" />
			<param name="autostart" value="1" />
			<param name="balance" value="0" />
			<param name="currentmarker" value="0" />
			<param name="currentPosition" value="0" />
			<param name="displaymode" value="4" />
			<param name="enablecontextmenu" value="0" />
			<param name="enabled" value="1" />
			<param name="fullscreen" value="0" />
			<param name="invokeurls" value="1" />
			<param name="PlayCount" value="1" />
			<param name="rate" value="1" />
			<param name="showcontrols" value="1" />
			<param name="showstatusbar" value="1" />
			<param name="stretchtofit" value="1" />
			<param name="transparentatstart" value="1" />
			<param name="captioningID" value="captions" />
			<param name="displaybackcolor" value="0" />
		</object>
	</div>
</div>
<div class="tableSize4 player_nav">
	<div class="colLeft">
		<!--   <button name="btn_view_marking" class="btn btn-primary btn-xs">Marking</button>-->
		<button name="btn_download" class="btn btn-primary btn-xs hide">Down</button>
	</div>
	<div class="colLeft" style="margin-left: 30px;">
		<ul class="list-inline">
			<li>
				<select name="move_sec" align="absmiddle">
					<option value="1">1</option>
					<option value="3">3</option>
					<option value="5">5</option>
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="60">60</option>
				</select>
			</li>
			<li class="btn btn-primary btn-xs" id="btn_forward">Fw</li>
			<li class="btn btn-primary btn-xs" id="btn_backward">Bw</li>
		</ul>              
	</div>
	<div class="colLeft" style="margin: 1px 0 0 40px;">
		<ul class="list-inline">
			<li class="speed btn btn-primary btn-xs" prop="0.5">0.5</li>
			<li class="speed btn btn-success btn-xs" prop="1.0" style="margin-left: 2px;">1.0</li>
			<li class="speed btn btn-primary btn-xs" prop="1.2" style="margin-left: 2px;">1.2</li>
			<li class="speed btn btn-primary btn-xs" prop="1.5" style="margin-left: 2px;">1.5</li>
			<li class="speed btn btn-primary btn-xs" prop="2.0" style="margin-left: 2px;">2.0</li>
		</ul>
	</div>
	<div class="colRight" style="margin-top: 3px;">
		<span id="play_time">
			<font>00:00 / <strong>00:00</strong></font>
		</span>                                           
	</div>
</div>   
<!--플레이어 영역 끝-->

