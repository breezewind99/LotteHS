var waveform;
var wave_w = 534;
var wave_h = 80;
var wave_data;

var duration = 0;

$(function () {
	
	/* CJM(20190104)
	 * 개발서버에서는 ajax 호출시 cross domain 오류 발생
	 * 신규 사이트에 구축시 정상적으로 ajax 호출됨(조선호텔)
	 * 해당 사항에 대해 확인 필요함
	 * ajax 호출 후 미디어 서버에 지정 위치에 복호화 된 wav 파일 생성
	 * wave_data 주석처리
	 * file_url2 는 복호화된 파일 위치 호출
	 * waveform.load(file_url2, wave_data) 파형이 제대로 노출 안될 경우 html를 이용 wave 고정 영역 지정 하여 img 지정
	 *
	 * CJM(20190627)
	 * 미디어 서버로 mp3 형식으로 url 호출 시 data response 되도록 미디어 서버 수정됨.
	 * fft_url은 파형호출을 위한 url
	 * wave surfer에서 load 시 자체 파형이 생성되므로 불필요 
	 * SDS는 fft_url ajax 호출 필요 rx, tx 파일을 wave 파일 생성을 위해 필요함.
	 * wavefom.load(file_url) 변경
	*/
	
	var html = "";
//	var fft_url = file_url.replace(".wav","."+fft_ext);
	
	//mp3 확장명으로 변경 - CJM(20190627)
	file_url = file_url.substring(0, file_url.lastIndexOf("."))+".mp3";
	var fft_url = file_url.substring(0, file_url.lastIndexOf("."))+"."+fft_ext;	
	
	//console.log("file_url : "+file_url);
	//console.log("fft_url : "+fft_url);
	//console.log("fft_ext : "+fft_ext);
	
	if(wave_type == "img") 
	{
		// get wave form image
		html += "<wave style='position: relative; width: "+wave_w+"px; height: "+wave_h+"px; background-color: #171A20; display: block;'>";
		html += "	<img id='wave_img' src='../rec_search/player_waveform.jsp?url=" + encodeURIComponent(fft_url) + "'/>";
		html += "	<wave style='position: absolute; top: 0; left: 0; bottom: 0; width: 0; overflow: hidden; border-right: 1px solid #FF3131; box-sizing: border-box; background-color: #666666; opacity: 0.8;'></wave>";
		html += "</wave>";

		$("#waveform").html(html);
	} 
	else if(wave_type == "img2") 
	{
		// get wave data
		$.ajax({
			type: "GET",
			url: fft_url,
			//crossDomain: true,
			async: false,
			dataType: "text",
			success:function(data){  
				//console.log(data);
				if(data.toLowerCase().indexOf("error") < 0) 
				{
					//wave_data = eval("[" + data + "]");
					//wave_data = data.split(",");
				} 
				else 
				{
					alert("미디어 서버에 오류가 발생하였습니다.");
					self.close();
					return false;
				}
			},
			error:function(req,status,err){
				/*
				console.log(status);
				console.log(err);
				console.log("code:"+req.status+"\n"+"message:"+req.responseText+"\n"+"error:"+err);
				*/
				alert("미디어 서버 연결에 실패했습니다.");
				self.close();
				return false;
			}
		});
		
		var wf_options = {
				container: "#waveform",
				waveColor: "#A8DBA8",
				progressColor: "#FF8B00",
				cursorColor: "#FF8B00",
				cursorWidth: 1,	  
				backgroundColor: "#4F4E65",
				height: wave_h,
				backend: "MediaElement"
			};		
		
		// get wave form image
		/*
		html += "<wave style='position: relative; width: "+wave_w+"px; height: "+wave_h+"px; background-color: #171A20; display: block;'>";
		html += "	<img id='wave_img' src='" + fft_url + "'/>";
		html += "	<wave style='position: absolute; top: 0; left: 0; bottom: 0; width: 0; overflow: hidden; border-right: 1px solid #FF3131; box-sizing: border-box; background-color: #666666; opacity: 0.8;'></wave>";
		html += "</wave>";
		*/
		//$("#waveform").html(html);
	} 
	else 
	{
		// get wave form data
		$.ajax({
			type: "GET",
			url: fft_url,
			async: false,
			dataType: "text",
			success:function(data){
				//console.log(data);
				if(data.toLowerCase().indexOf("error")<0) {
					wave_data = eval("[" + data + "]");
				} else {
					alert("미디어 서버에 오류가 발생하였습니다.");
					self.close();
					return false;
				}
			},
			error:function(req,status,err){
				alert("미디어 서버 연결에 실패했습니다.");
				self.close();
				return false;
			}
		});

		// wave form
		waveform = new Waveform({
			container: document.getElementById("waveform"),
			width: wave_w,
			height: wave_h,
			data: wave_data,
			innerColor: "#00FFFF",
			outerColor: "#171A20",
			progressColor: "#808080",
			cursorColor: "#FF3131",
			interpolate: true
		});
	}	
		
	waveform = WaveSurfer.create(wf_options);
	//waveform.load(file_url, wave_data);
	//waveform.load(file_url2, wave_data);
	//waveform.load(file_url2);
	waveform.load(file_url);
	
	waveform.on("ready", function () {
		// duration display
		duration = parseInt(waveform.getDuration());
		$(".jp-duration").html(getMsToSec(duration));
		waveform.play();
	});
	
	// play progress
	waveform.on("audioprocess", function (sec) {
		// current time display
		$(".jp-current-time").html(getMsToSec(parseInt(sec)));
		// progress bar move
		var perc = (sec/duration).toFixed(5);
		$(".jp-progress-slider").slider("value", perc);
	});	
	
	// play & pause button click
	$(".jp-playpause").click(function(){
		waveform.playPause();
	});
	
	// stop button click
	$(".jp-stop").click(function(){
		waveform.stop();
	});
	
	// repeat button click
	$(".jp-repeat").click(function(){
		$(this).toggleClass("ui-state-active");
	});		
		
	// play event
	waveform.on("play", function () {
		$(".jp-play").css("display", "none");
		$(".jp-pause").css("display", "block");
	});
	
	// pause event
	waveform.on("pause", function () {
		$(".jp-play").css("display", "block");
		$(".jp-pause").css("display", "none");		
	});	
	
	// play finish event
	waveform.on("finish", function () {
		if($(".jp-repeat").hasClass("ui-state-active")) {
			waveform.play(0);
		} else {
			$(".jp-play").css("display", "block");
			$(".jp-pause").css("display", "none");				
		}
	});
	
	// space bar keydown event
	$(document).keydown(function (event){
		if(event.which==32) {
			event.preventDefault();
			waveform.playPause();
		}
	});	
	
	// mute button click
	$(".jp-mute").click(function(){
		waveform.setVolume(0);
		$(".jp-volume-slider").slider("value", 0);
	});
	
	// volume-max button click
	$(".jp-volume-max").click(function(){
		waveform.setVolume(1);
		$(".jp-volume-slider").slider("value", 1);
	});	
	
	// create the progress slider control
	$(".jp-progress-slider").slider({
		animate: "fast",
		max: 1,			
		range: "min",
		step: 0.00001,
		value : 0,
		slide: function(event, ui) {
			var sec = parseInt((ui.value).toFixed(5)*duration);
			if(sec > 0) 
			{
				waveform.play(sec);
			}
		}
	});
	
	// create the volume slider control
	$(".jp-volume-slider").slider({
		animate: "fast",
		max: 1,
		range: "min",
		step: 0.01,
		value : 0.5,
		slide: function(event, ui) {
			waveform.setVolume(ui.value);
		}
	});
	
	// play rate change
	$("#ui-speed li").click(function(){
		var speed = $(this).attr("prop");
		
		waveform.setPlaybackRate(speed);
		$("#speed").html(speed + "x");
	});	
	
	// waveform click
	waveform.on("seek", function (progress) {
		if(progress==0) return;
					
		// marking
		if($("#ui-marking") && $("#ui-marking").hasClass("show")) 
		{
			var mk_name = $("#marking input[name=mk_name]");
			var mk_stime = $("#marking input[name=mk_stime]");
			var mk_etime = $("#marking input[name=mk_etime]");
			var cur_sec_his = getHmsToSec(parseInt(waveform.getCurrentTime()));
			
			if(mk_stime.val() == "") 
			{
				mk_stime.val(cur_sec_his);
			} 
			else 
			{
				mk_etime.val(cur_sec_his);
			}
		}
		
		// everlasting(영구녹취) - CJM(20190610)
		/*
		if($("#ui-everlasting") && $("#ui-everlasting").hasClass("show")) 
		{
			var ev_name = $("#everlasting input[name=mk_name]");
			var ev_stime = $("#everlasting input[name=mk_stime]");
			var ev_etime = $("#everlasting input[name=mk_etime]");
			var cur_sec_his = getHmsToSec(cur_sec);

			if(ev_stime.val() == "") 
			{
				ev_stime.val(cur_sec_his);
			} 
			else 
			{
				ev_etime.val(cur_sec_his);
			}
		}
		*/
		
	});
	
	// hover states of the buttons
	$(".jp-gui ul li").hover(
		function() { $(this).addClass('ui-state-hover'); },
		function() { $(this).removeClass('ui-state-hover'); }
	);	
});

// marking play
var playMarking = function(start_sec, end_sec) {	
	waveform.play(parseInt(start_sec), parseInt(end_sec));
};