$(function(){
	// wave form mousemove 시 현재 play 시간 표시
	$("#outer_waveform").unbind("mousemove").bind("mousemove", function(event){
		var ex = event.pageX;
		var offset = $(this).offset();
		var w = ex-offset.left;

		if(duration>0) {
			var sec = ((duration) * (w/wave_w).toFixed(5)).toFixed(0);

			$("#curtime").css({"display": "block", "left": w, "top": event.pageY-24});
			$("#curtime").html(getHmsToSec(sec));
		}
	});

	// wave form mouseout 시 play 시간 표시 hide
	$("#outer_waveform").unbind("mouseout").bind("mouseout", function(e) {
		$("#curtime").css({"display": "none"});
	});

	// eval form close 버튼 클릭
	$("#ui-evaluation button.close").click(function(){
		$("#ui-evaluation").removeClass("show").addClass("hidden");
	});

	// marking form close 버튼 클릭
	$("#ui-marking button.close").click(function(){
		$("#ui-marking").removeClass("show").addClass("hidden");
	});

	// part form close 버튼 클릭
	$("#ui-part button.close").click(function(){
		$("#ui-part").removeClass("show").addClass("hidden");
	});
	
	// everlasting form close 버튼 클릭
	$("#ui-everlasting button.close").click(function(){
		$("#ui-everlasting").removeClass("show").addClass("hidden");
	});
	
	// marking 버튼 클릭
	$("button[name=btn_view_marking], .jp-marking").on("click", function(){
		$("#marking input[name=mk_name]").val("");
		$("#marking input[name=mk_stime]").val("");
		$("#marking input[name=mk_etime]").val("");

		$("#ui-marking").removeClass("hidden").addClass("show");
	});

	// 부분녹취 버튼 클릭
	$("button[name=btn_view_part], .jp-part").on("click", function(){
		$("#part input[name=pa_stime]").val("");
		$("#part input[name=pa_etime]").val("");

		$("#ui-part").removeClass("hidden").addClass("show");
	});
	
	// 고객정보 수정 버튼 클릭 - CJM(20181119)
	$("button[name=btn_view_regi]").on("click", function()
	{
		var info = getEncData(rec_datm.replace(/\s|-|:|\./gi,"")+"|" + local_no + "|" + rec_filename, "1");

		openPopup("rec_omission_info.jsp?step=r&info="+encodeURIComponent(info),"_omission","556","310","yes","center");
	});
	
	// 영구녹취 버튼 클릭 - CJM(20190612)
	$("button[name=btn_view_everlasting]").on("click", function(){
		$("#everlasting input[name=mk_name]").val("");
		$("#everlasting input[name=mk_stime]").val("");
		$("#everlasting input[name=mk_etime]").val("");

		$("#ui-everlasting").removeClass("hidden").addClass("show");
	});	

	// marking hist
	if(rec_datm!="" && local_no!="" && rec_filename!="") 
	{
		//console.log("isExistMarking : "+isExistMarking);
		//console.log("isExistEverlasting : "+isExistEverlasting);
		getMarkingList();
	}

	// auto win resize
	popResize("container");
});

//get marking hist
var mk_height = 0;
var getMarkingList = function() {
	$("#marking_hist").load("remote_marking_list.jsp", { rec_datm: rec_datm, local_no: local_no, rec_filename: rec_filename }, function(response, status, xhr){
		if(status=="error") {
			$(this).html("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
		}

		var row_cnt = parseInt($("#marking_hist").find("table").attr("row_cnt"));
		if(row_cnt > 0) 
		{
			var h = ($("#marking_hist").find("div").height() + 30) - mk_height;
			mk_height += h;
			window.resizeBy(0, h);
		} 
		else 
		{
			window.resizeBy(0, -mk_height);
			mk_height = 0;
		}
	});
};



var ev_height = 0;
var getEverlastingList = function() {
	$("#everlasting_hist").load("remote_marking_list.jsp", { rec_datm: rec_datm, local_no: local_no, rec_filename: rec_filename }, function(response, status, xhr){
		if(status=="error") {
			$(this).html("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
		}

		var row_cnt = parseInt($("#everlasting_hist").find("table").attr("row_cnt"));
		if(row_cnt > 0) 
		{
			var h = ($("#everlasting_hist").find("div").height() + 30) - ev_height;
			ev_height += h;
			window.resizeBy(0, h);
		} 
		else 
		{
			window.resizeBy(0, -ev_height);
			ev_height = 0;
		}
	});
};

//부분녹취 등록 - CJM(20180905)
var regiPart = function(){

	if(!$("#part input[name=pa_stime]").val().trim()) {
		alert("시작 시간을 입력해 주십시오.");
		$("#part input[name=pa_stime]").focus();
		return false;
	}
	if(!isValidHms($("#part input[name=pa_stime]").val().trim())) {
		alert("시작 시간의 형식이 일치하지 않습니다.");
		$("#part input[name=pa_stime]").focus();
		return false;
	}
	if(!$("#part input[name=pa_etime]").val().trim()) {
		alert("종료 시간을 입력해 주십시오.");
		$("#part input[name=pa_etime]").focus();
		return false;
	}
	if(!isValidHms($("#part input[name=pa_etime]").val().trim())) {
		alert("종료 시간의 형식이 일치하지 않습니다.");
		$("#part input[name=pa_etime]").focus();
		return false;
	}
	if($("#part input[name=pa_stime]").val()>=$("#part input[name=pa_etime]").val()) {
		alert("종료시간이 시작시간보다 작습니다. 다시 입력해 주십시오.");
		$("#part input[name=pa_etime]").focus();
		return false;
	}
	
	//alert(rec_datm+"|" + local_no + "|" + rec_filename + "|" + $("#part input[name=pa_stime]").val() + "|" + $("#part input[name=pa_etime]").val());
	//alert(rec_datm.replace(/\s|-|:|\./gi,"")+"|" + local_no + "|" + rec_filename + "|" + $("#part input[name=pa_stime]").val() + "|" + $("#part input[name=pa_etime]").val());
	//console.log(rec_datm.replace(/\s|-|:|\./gi,"")+"|" + local_no + "|" + rec_filename + "|" + $("#part input[name=pa_stime]").val() + "|" + $("#part input[name=pa_etime]").val());
	var info = getEncData(rec_datm.replace(/\s|-|:|\./gi,"")+"|" + local_no + "|" + rec_filename + "|" + $("#part input[name=pa_stime]").val() + "|" + $("#part input[name=pa_etime]").val(), "1");

	openPopup("rec_omission_info.jsp?info="+encodeURIComponent(info),"_omission","556","310","yes","center");
	//openPopup("rec_omission_info.jsp?rec_datm="+rec_datm+"&local_no="+local_no+"&rec_filename="+rec_filename,"_memo","478","590","yes","center");
};

// marking 등록
var regiMarking = function(){
	if(!$("#marking input[name=mk_name]").val().trim()) {
		alert("마킹 구분을 입력해 주십시오.");
		$("#marking input[name=mk_name]").focus();
		return false;
	}
	if(!$("#marking input[name=mk_stime]").val().trim()) {
		alert("시작 시간을 입력해 주십시오.");
		$("#marking input[name=mk_stime]").focus();
		return false;
	}
	if(!isValidHms($("#marking input[name=mk_stime]").val().trim())) {
		alert("시작 시간의 형식이 일치하지 않습니다.");
		$("#marking input[name=mk_stime]").focus();
		return false;
	}
	if(!$("#marking input[name=mk_etime]").val().trim()) {
		alert("종료 시간을 입력해 주십시오.");
		$("#marking input[name=mk_etime]").focus();
		return false;
	}
	if(!isValidHms($("#marking input[name=mk_etime]").val().trim())) {
		alert("종료 시간의 형식이 일치하지 않습니다.");
		$("#marking input[name=mk_etime]").focus();
		return false;
	}
	if($("#marking input[name=mk_stime]").val()>=$("#marking input[name=mk_etime]").val()) {
		alert("종료시간이 시작시간보다 작습니다. 다시 입력해 주십시오.");
		$("#marking input[name=mk_etime]").focus();
		return false;
	}
	//alert(rec_datm);
	// set value
	$("#marking input[name=rec_datm]").val(rec_datm);
	$("#marking input[name=local_no]").val(local_no);
	$("#marking input[name=rec_filename]").val(rec_filename);

	$.ajax({
		type: "POST",
		url: "remote_marking_proc.jsp",
		async: false,
		data: "step=insert&"+$("#marking").serialize(),
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="OK") {
				alert("정상적으로 등록되었습니다.");
				//마킹 숨김 처리 - CJM(20190527)
				//$("#ui-marking").hide();
				$("#ui-marking").removeClass("show").addClass("hidden");
				getMarkingList();
			} else {
				alert(dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alertJsonErr(req,status,err);
			return false;
		}
	});
};

// marking 이력 삭제
var deleteMarking = function(mkSeq) {
	if(confirm("정말로 삭제하시겠습니까?")) {
		if(!mkSeq.trim()) {
			alert("필수 파라미터가 없습니다.");
			return;
		}

		var param = {
			step: "delete",
			mk_seq: mkSeq,
			rec_datm: rec_datm,
			local_no: local_no,
			rec_filename: rec_filename,
			rec_cls: "M"
		};

		$.ajax({
			type: "POST",
			url: "remote_marking_proc.jsp",
			async: false,
			data: param,
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code=="OK") {
					alert("정상적으로 삭제되었습니다.");
					getMarkingList();
				} else {
					alert(dataJSON.msg);
					return false;
				}
			},
			error:function(req,status,err){
				alertJsonErr(req,status,err);
				return false;
			}
		});
	}
};

var tta = function(getInfo, getVal, getReason_code, getReason_text) {
	var param = getInfo.replace("_RX.wav",".wav");
		param = param.replace("_RX.wav",".wav");

	if (getVal=="RX"){
		param = getEncData(param.replace(".WAV","_RX.WAV"));
	} else if (getVal=="TX"){
		param = getEncData(param.replace(".WAV","_TX.WAV"));
	} else {
		param = getEncData(param);
	}

	location.replace("../rec_search/player.jsp?info="+encodeURIComponent(param)+"&reason_code="+getReason_code+"&reason_text="+getReason_text+"&setType="+getVal);
	//alert(param);
}
