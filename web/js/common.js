/** ===============================================================
 *	on load
 ** ===============================================================
 */

// grid	전역변수
var $grid;
//기본 데이터 모델 속성 실행 여부 체크 - CJM(20190116)
var baseGridChk = false;

//datepicker option
var dp_option = {
		dateFormat: 'yy-mm-dd',
		prevText: '이전 달',
		nextText: '다음 달',
		monthNames: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		monthNamesShort: ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'],
		dayNames: ['일','월','화','수','목','금','토'],
		dayNamesShort: ['일','월','화','수','목','금','토'],
		dayNamesMin: ['일','월','화','수','목','금','토'],
		showMonthAfterYear: true,
		yearSuffix: '년',
		//showOn: "button",
		//buttonText: "<i class='fa fa-calendar'></i>",
};

/**
 * jquery on load
 * @returns
 */
$(function() 
{
	// Add body-small class if window less than 768px
	if($(this).width() < 769) 
	{
		$('body').addClass('body-small');
	} 
	else 
	{
		$('body').removeClass('body-small');
	}
	
	// Minimalize menu when screen is less than 768px
	$(window).bind("resize", function() {
		if($(this).width() < 769) 
		{
			$('body').addClass('body-small');
		} 
		else 
		{
			$('body').removeClass('body-small');
		}
	});
	
	// MetsiMenu (left menu)
	$('#side-menu').metisMenu();

	// Collapse ibox function (검색창 열기/닫기)
	$('.collapse-link').click( function() {
		var ibox = $(this).closest('div.ibox');
		var button = $(this).find('i');
		var content = ibox.find('div.ibox-content');
		content.slideToggle(200);
		button.toggleClass('fa-chevron-up').toggleClass('fa-chevron-down');
		//ibox.toggleClass('').toggleClass('border-bottom');
		setTimeout(function () {
			//ibox.resize();
			//ibox.find('[id^=map-]').resize();
		}, 50);
	});
	
	// Collapse ibox function (검색창 열기/닫기)
	$('.collapse-link2').click( function() {
		var ibox = $(this).closest('div.ibox');
		var button = $(this).find('i');
		var content = ibox.find('div.ibox-content-util-buttons');
		//var content = ibox.find('div.ibox-content');
		content.slideToggle(200);
		button.toggleClass('fa-caret-up').toggleClass('fa-caret-down');
		ibox.toggleClass('').toggleClass('border-bottom');  
	});

	// Close ibox function
	$('.close-link').click( function() {
		var content = $(this).closest('div.ibox');
		content.remove();
	});

	// Close menu in canvas mode
	$('.close-canvas-menu').click( function() {
		$("body").toggleClass("mini-navbar");
		SmoothlyMenu();
	});
	
	// Minimalize menu (left menu 줄이기)
	$('.navbar-minimalize').click(function () {
		$("body").toggleClass("mini-navbar");
		/*
		// left mini menu 여부 쿠키 생성
		if($("body").hasClass("mini-navbar")) {			
			$.cookie("ck_mini_var_yn", "1", { path: "/" });			
		} else {
			$.cookie("ck_mini_var_yn", "0", { path: "/" });
		} 
		*/	   
		SmoothlyMenu(); 
		
		// 0.5초 후 grid size 변경
		window.setTimeout( function(){
			$("#grid").pqGrid("refreshDataAndView");
		}, 500);						
	});
	
	/*
	// 이전에 left menu가 mini-var 형태라면 기존대로 유지
	if($.cookie("ck_mini_var_yn")=="1") { 
		$('body').addClass('mini-navbar');
		$('#side-menu').removeAttr('style');			
	}
	*/

	// Move modal to body
	// Fix Bootstrap backdrop issue with animation.css
	$('.modal').appendTo("body");  
	
	// grid가 리플레시 될때 height 조정
	/*$("#grid").on("pqgridload", function() {
		fix_height("");
	});*/
	
	// height auto resize
	$(".wrapper-content").resize(function() {
		fix_height($(".wrapper-content").height());
	});
	   
	// load ajax를 사용했을 경우 height 조정
	/*$("#treeDiv1, #treeDiv2").resize(function() {
		var heigh = ($("#treeDiv1").height()>$("#treeDiv2").height()) ? $("#treeDiv1").height() : $("#treeDiv2").height();		
		fix_height($(".wrapper-content").height() + heigh);
	});*/

	// tooltips
	$('.tooltip').tooltip({
		selector: "[data-toggle=tooltip]",
		container: "body"
	});
	
	// popover
	$("[data-toggle=popover]").popover();   
	
	// template color 변경
	$("select[name=template_color]").on("change", function(){
		var color = $(this).val();		
		// color cookie 생성
		$.cookie("ck_template_color", color, { path: "/" });
		
		location.reload();
	});
	
	// template color 설정
	$("select[name=template_color]").val($.cookie("ck_template_color"));
	
	// 달력 제어
	try{$(".datepicker").datepicker(dp_option);}catch(e){return "";};

	// 달력 아이콘 클릭 시 오픈
	$(".btn-datepicker").click(function() {
		$(this).parents(".input-group").children(".datepicker").datepicker("show");
	});

	// 검색 영역에서 조직도 조회
	$("#search select[name=bpart_code], #search select[name=mpart_code]").change(function(){chgPartCode($(this));});
	
	// 조회 버튼 클릭 시 데이터 조회
	$("#search button[name=btn_search]").click(function() {
		searchs();
	});
	
	// 엔터키가 눌러졌을 경우 데이터 조회 실행
	$("#search input, #search select").keyup(function(e) {
		if(e.keyCode == 13) 
		{
			searchs();
		}
	});

	// 취소 버튼 클릭 시 페이지 재연결
	$("#search button[name=btn_cancel]").click(function() {
		var url = $(location).attr("href").replace("#none", "");
		location.replace(url);
	});
	
	//공통 비밀번호 변경시
	$("#passwdUpd button[name=modal_regi]").click(function() {
		
		var type = $(this).attr("prop");
		changePasswd(type);
	});

});

/** ===============================================================
 *	util
 ** ===============================================================
 */

/**
 * Full height of sidebar
 */
var fix_height = function(heigh) {
	if((heigh+169) < $(window).height()) 
	{
		var agent = navigator.userAgent.toLowerCase();
		var add_heigh = 0;

		/*if($(window).height()-heigh<80) {
			if(agent.indexOf("trident")!=-1) {
				add_heigh = 100 + (80-($(window).height()-heigh));
			} else {
				//add_heigh = 105;
				add_heigh = 100 + (80-($(window).height()-heigh));
			}
		}*/
				
		$("#page-wrapper").css("min-height", ($(window).height()+add_heigh) + "px");
	} 
	else 
	{
		$("#page-wrapper").css("min-height", (heigh+169) + "px");
	}
};

/**
 * For demo purpose - animation css script
 */
var animationHover = function(element, animation) {
	element = $(element);
	element.hover(
		function() {
			element.addClass('animated ' + animation);
		},
		function(){
			//wait for animation to finish before removing classes
			window.setTimeout( function(){
				element.removeClass('animated ' + animation);
			}, 2000);
		});
};

/**
 * SmoothlyMenu
 * @returns
 */
var SmoothlyMenu = function() {
	if(!$('body').hasClass('mini-navbar') || $('body').hasClass('body-small')) 
	{
		// Hide menu in order to smoothly turn on when maximize menu
		$('#side-menu').hide();
		// For smoothly turn on menu
		setTimeout(
			function () {
				$('#side-menu').fadeIn(500);
			}, 100);
	} 
	else if ($('body').hasClass('fixed-sidebar')) 
	{
		$('#side-menu').hide();
		setTimeout(
			function () {
				$('#side-menu').fadeIn(500);
			}, 300);
	} 
	else 
	{
		// Remove all inline style from jquery fadeIn function to reset menu state
		$('#side-menu').removeAttr('style');
	}
};

/**
 * trim
 */
String.prototype.trim = function() {
	return this.replace(/(^\s*)|(\s*$)/g, "");
};

/**
 * checked form value 추출
 */
var getCheckedValue = function(obj) {
	var val = "";
	obj.each(function() {
		if($(this).prop("checked")) 
		{
			val += ","+$(this).val();
		}
	});

	return val.substring(1);
};

/**
 * form serializeArray() 데이터를 json data로 변환
 */
var arrToJson = function(form){
	var json = {};
	$.each(form, function(idx, ele){
		json[ele.name] = ele.value;
	});

	return json;
};

/**
 * json value count
 */
var getJsonValCnt = function(data) {
	var cnt = 0;
	$.each(data, function(key, val){
		if(val != "")	cnt++;
	});
	return cnt;
};

/**
 * 문자열이 cipher 자릿수만큼 연속된 문자열인지 여부 확인
 */
var checkStraightStr = function(str, cipher) {
	str = str.toLowerCase();

	// 문자열 길이 - 연속되는 자릿수 + 1 만큼만 loop --> 비교할 대상이 있는 만큼만 loop
	for(var i=0; i<(str.length-cipher+1); i++) 
	{
		var cnt = 0;
		var o = "";
		// 현재 문자의 achii 값과 이전 achii 값을 뺀 값이 1이면 연속되는 문자열
		for(var j=0; j<cipher; j++) 
		{
			var ac = str.substr(i+j, 1).charCodeAt(0);

			if(j>0 && ac-o==1) 
			{
				cnt = cnt+1;
			}
			o = ac;
		}

		// 연속되는 문자열이 cipher-1만큼 있다면 비교 기준 문자에서 지정한 자릿수만큼 연속되는 문자열로 판명
		if(cnt-cipher+1==0) 
		{
			return true;
			break;
		}
	}
	return false;
};

/**
 * 문자열 역순 정렬
 */
var getReverseStr = function(str)
{
	var reverse_str = "";
	for(var i = str.length; 0<=i; i--) 
	{
		reverse_str = reverse_str + str.charAt(i);
	}
	return reverse_str;
};

/**
 * 입력값이 null인지 체크
 */
var gf_isNull = function(sValue){
	if(new String(sValue).valueOf() == "undefined") 
		return true;
	if(new String(sValue).valueOf() == undefined)  
		return true;
	if(sValue == null )
		return true;
	if(("x"+sValue == "xNaN") && (new String(sValue).valueOf() == "undefined"))
		return true;
	if(sValue.toString().trim().length == 0)
		return true;
		
	return false;
};

/**
 * open popup 추가 필요함.
 */
//open popup
var openPopup = function (mypage, myname, w, h, scroll, pos){
	var win = null;
	// if(pos == 'random'){
	// 	var array = new Uint32Array(1);
	// 	window.crypto.getRandomValues(array);
	// 	var secureNumber = (array[0] % 100) + 1;
	//
	// 	LeftPosition=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;
	// 	TopPosition=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;
	// }
	if(pos == 'center'){LeftPosition=(screen.width)?(screen.width-w)/2:100;TopPosition=(screen.height)?(screen.height-h-100)/2:100;}
	else if((pos!='center' && pos!='random') || pos == null){LeftPosition = 0;TopPosition = 0;}

	settings = 'width='+w+',height='+h+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',location=no,directories=no,status=no,menubar=no,toolbar=no,resizable=no';
	win = window.open(mypage, myname, settings);

	if(win == null){ alert("팝업 차단기능을 해제한 후 다시 시도해 주십시오."); }
	if(win.focus){win.focus();}
};

/**
 * popup window auto resize
 */
var popResize = function (divId) {
	var strWidth;
	var strHeight;

	//innerWidth / innerHeight / outerWidth	/ outerHeight 지원 브라우저
	if (window.innerWidth && window.innerHeight && window.outerWidth && window.outerHeight) 
	{
		strWidth = $("#"+divId).outerWidth() + (window.outerWidth - window.innerWidth);
		strHeight = $("#"+divId).outerHeight() + (window.outerHeight - window.innerHeight);
	} 
	else 
	{
		var strDocumentWidth = $(document).outerWidth();
		var strDocumentHeight = $(document).outerHeight();

		window.resizeTo(strDocumentWidth, strDocumentHeight);

		var strMenuWidth = strDocumentWidth - $(window).width();
		var strMenuHeight = strDocumentHeight - $(window).height();

		strWidth = $("#"+divId).outerWidth() + strMenuWidth;
		strHeight = $("#"+divId).outerHeight() + strMenuHeight;
	}

	//resize
	window.resizeTo(strWidth, strHeight);
	window.focus();
};

/**
 * bar graph
 */
var barChart = function(chartID, chartNm, chartTick, chartData) {
	$.jqplot(chartID, [chartData], {
		title: chartNm,
		animate: true,
		seriesDefaults: {
			renderer:$.jqplot.BarRenderer,
			rendererOptions: {
				varyBarColor: true,
				barMargin: 10
			},
			pointLabels: {
				show: true
			}
		},
		grid: {
			//background: "#FFFFFF",
			gridLineColor: "#BFBFBF",
			drawBorder: false
		},
		axes:{
			xaxis:{
				renderer:$.jqplot.CategoryAxisRenderer,
				ticks: chartTick,
				drawMajorGridlines: true,
				tickOptions:{
					textColor: "#333333",
					showMarker: false
				}
			},
			yaxis:{
				min: 0,
				drawMajorGridlines: true,
				tickOptions: {
					formatString: "%'d",
					textColor: "#333333",
					showMarker: false
				}
			}
		}
	});
};

/**
 * 조직도 대분류/중분류/소분류 조회
 */
var chgPartCode = function(obj) {
	var form_obj = obj.parents("form");
	var field_name = obj.attr("name");
	var perm_check = (form_obj.find("input[name=perm_check]")) ? form_obj.find("input[name=perm_check]").val() : "";
	var it_business_code = (form_obj.find("input[name=it_business_code]")) ? form_obj.find("input[name=it_business_code]").val() : "";
	//var perm_check = ($("#search input[name=perm_check]")) ? $("#search	input[name=perm_check]").val() : "";
	
	var part_depth		= (field_name == "bpart_code") ? 2 : (field_name == "business_code") ? 1 : 3;
	var target_field	= (part_depth == 2) ? "mpart_code" : (part_depth == 1) ? "bpart_code" : "spart_code";
	var target_name		= (part_depth == 2) ? "중분류" : (part_depth == 1) ? "대분류" : "소분류";

	var bpart_code		= toNN((part_depth != 1) ? form_obj.find("select[name=bpart_code]").val() : "");
	var mpart_code		= toNN((part_depth == 3) ? form_obj.find("select[name=mpart_code]").val() : "");

	form_obj.find("select[name=" + target_field	+ "]").html("<option value=''>"	+ target_name +	"</option>");
	
	//대분류 바꾸는 경우 소분류도 초기화 한다.
	if(part_depth == 2)
	{
		form_obj.find("select[name=spart_code]").html("<option value=''>소분류</option>");
	}
	
	//조직도 관리 수정 기능 추가
	if(part_depth != 1 && gf_isNull(bpart_code))	bpart_code = toNN(form_obj.find("input[name=bpart_code]").val());
	if(part_depth == 3 && gf_isNull(mpart_code))	mpart_code = toNN(form_obj.find("input[name=mpart_code]").val());
	
	if(obj.val() == "") return;
	
	var fvData = "bpart_code="+bpart_code+"&mpart_code="+mpart_code+"&part_depth="+part_depth+"&perm_check="+perm_check;
	if(!gf_isNull(it_business_code))	fvData = "bpart_code="+bpart_code+"&mpart_code="+mpart_code+"&part_depth="+part_depth+"&perm_check="+perm_check+"&business_code="+it_business_code;	

	$.ajax({
		type: "POST",
		url: "../common/get_user_group_code_list.jsp",
//		data: "bpart_code="+bpart_code+"&mpart_code="+mpart_code+"&part_depth="+part_depth+"&perm_check="+perm_check,
		data: fvData,
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code != "ERR") 
			{
				if(dataJSON.data.length > 0) 
				{
					var html = "";
					var code = "";
					for(var i=0;i<dataJSON.data.length;i++) 
					{
						//code = (target_field=="mpart_code")	? dataJSON.data[i].mpart_code :	dataJSON.data[i].spart_code;
						code = (target_field=="mpart_code") ? dataJSON.data[i].mpart_code : (target_field=="bpart_code") ? dataJSON.data[i].bpart_code : dataJSON.data[i].spart_code;
						html += "<option value='" + code + "'>" + dataJSON.data[i].part_name + "</option>";
					}
					form_obj.find("select[name=" + target_field	+ "]").append(html);
				} 
				else 
				{
					alert(target_name + "가 데이터가 없습니다.");
					return false;
				}
			} 
			else 
			{
				alert(dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alert("에러가 발생하였습니다. [" + req.responseText + "]");
			return false;
		}
	});
};

/**
 * 공통코드 조회 후 select box setting
 */
var getCommCodeToForm = function(parent_code, targ_fn_name, targ_fd_name) {
	if(parent_code == "") 
	{
		return;
	}

	// 청취/다운로드 사유 코드
	$.ajax({
		type: "POST",
		url: "../common/get_common_code_list.jsp",
		data: "parent_code="+parent_code+"&code_depth=2",
		async: false,
		dataType: "json",
		success:function(dataJSON){
			var obj	= $("#" + targ_fn_name + " select[name=" + targ_fd_name + "]");

			obj.html("<option value=''>선택</option>");

			if(dataJSON.code != "ERR") 
			{
				if(dataJSON.data.length > 0) 
				{
					var html = "";
					for(var i=0;i<dataJSON.data.length;i++) 
					{
						html += "<option value='" +	dataJSON.data[i].comm_code + "'>" + dataJSON.data[i].code_name + "</option>";
					}
					obj.append(html);
				} 
				else 
				{
					alert("코드 데이터가 없습니다.");
					return false;
				}
			} 
			else 
			{
				alert(dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alert("에러가 발생하였습니다. [" + req.responseText + "]");
			return false;
		}
	});
};

/**
 * 평가 카테고리 조회 후 select box setting
 */
var getEvalCateToForm = function(targ_fn_name, targ_fd_name) 
{
	//평가 카테고리
	$.ajax({
		type: "POST",
		url: "../common/get_eval_cate_list.jsp",
		data: "cate_depth=1",
		async: false,
		dataType: "json",
		success:function(dataJSON){
			var obj	= $("#" + targ_fn_name + " select[name=" + targ_fd_name + "]");

			obj.html("<option value='_parent'>상위 카테고리 없음</option>");

			if(dataJSON.code != "ERR") 
			{
				if(dataJSON.data.length > 0) 
				{
					var html = "";
					for(var i=0;i<dataJSON.data.length;i++) 
					{
						html += "<option value='" +	dataJSON.data[i].cate_code + "'>" + dataJSON.data[i].cate_name + "</option>";
					}
					obj.append(html);
				} 
				else 
				{
					return false;
				}
			} 
			else 
			{
				alert(dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alert("에러가 발생하였습니다. [" + req.responseText + "]");
			return false;
		}
	});
};

/**
 * 파라미터 암호화
 */
var getEncData = function(str, flag) {
	var enc_data = "";

	$.ajax({
		type: "POST",
		url: "../common/get_enc_data.jsp",
		data: "info="+encodeURIComponent(str)+"&flag="+flag,
		//data:	"info="+str+"&flag="+flag,
		async: false,
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code == "OK") 
			{
				enc_data = dataJSON.data;
			} 
			else 
			{
				enc_data = "";
			}
		},
		error:function(req,status,err){
			enc_data = "";
		}
	});

	return enc_data;
};

/**
 * 청취 플레이어
 */
var playRecFile = function(rec_datm, local_no, rec_filename, rec_keycode, loc){
	rec_datm = rec_datm.replace(/\s|-|:|\./gi,"");
	var info = getEncData(rec_datm + "|" + local_no + "|" + rec_filename + "|" + rec_keycode, "1");

	if(isExistPlayDownReason)
	{
		openPopup("../rec_search/player_reason.jsp?loc="+toNN(loc)+"&info="+encodeURIComponent(info),"_player","556","260","yes","center");//사유입력
	}
	else
	{
		openPopup("../rec_search/player.jsp?loc="+toNN(loc)+"&info="+encodeURIComponent(info),"_player","556","376","yes","center");
	}
};

/**
 * 청취 플레이어(IDX) 
 */
var playRecFileByIdx = function(rowIndx, loc){
	var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
	playRecFile(rowData["rec_datm"],rowData["local_no"],rowData["rec_filename"],rowData["rec_keycode"],loc);
};

/**
 * 청취 플레이어(SEQ)
 */
var playRecFileByRecSeq = function(rec_seq, loc){
	if(isExistPlayDownReason)
	{
		openPopup("../rec_search/player_reason.jsp?loc="+loc+"&rec_seq="+rec_seq,"_player","556","260","yes","center");//사유입력
	}
	else
	{
		openPopup("../rec_search/player.jsp?loc="+loc+"&rec_seq="+rec_seq,"_player","556","376","yes","center");
	}
};

/**
 * 다중청취 플레이어
 */
var playRecFileMulti = function(loc) {
	var selarray = $grid.pqGrid('selection', { type: 'row', method: 'getSelection' });
	var len = selarray.length;
	if(len == 0)
	{
		alert("먼저 왼쪽체크박스를 선택 후 다중청취를 클릭하세요!");
		return;
	}

	var info = "";
	for(var i=0; i < len; i++) 
	{
		var rowData = selarray[i].rowData;
		var rec_datm = rowData["rec_datm"].replace(/\s|-|:|\./gi,"");
		//다중 구분자는 탭문자임
		// 녹취일시 | 내선번호 | 녹취파일명 | 녹취 CON ID | 통화시간 | 상담원명
		info += "\t" + getEncData(rec_datm + "|" + rowData["local_no"] + "|" + rowData["rec_filename"] + "|" + rowData["rec_keycode"] + "|" + rowData["rec_call_time"] + "|" + rowData["user_name"], "1");
	}
	info = info.substr(1);

	if(isExistPlayDownReason)
	{
		//openPopup("../rec_search/player_reason.jsp?loc="+loc+"&info="+encodeURIComponent(info),"_player","556","260","yes","center");//사유입력
		openPopup("about:blank","_player","556","260","yes","center");//사유입력
		makeFormAndGo("fPlay","../rec_search/player_reason.jsp","_player",{"loc":toNN(loc), "info":info})
	}
	else
	{
		//openPopup("../rec_search/player.jsp?loc="+loc+"&info="+encodeURIComponent(info),"_player","556","376","yes","center");
		openPopup("about:blank","_player","556","376","yes","center");
		makeFormAndGo("fPlay","../rec_search/player.jsp","_player",{"loc":toNN(loc), "info":info})
	}
};

/**
 * 연관콜 청취 플레이어 연결
 */
var playRecFileLink = function(rec_datm, local_no, rec_filename, rec_keycode) {
	rec_datm = rec_datm.replace(/\s|-|:|\./gi,"");
	var info = getEncData(rec_datm + "|" + local_no + "|" + rec_filename + "|" + rec_keycode, "1");
	if(isExistPlayDownReason)
	{
		location.replace("../rec_search/player_reason.jsp?info="+encodeURIComponent(info));
	}
	else
	{
		location.replace("../rec_search/player.jsp?info="+encodeURIComponent(info));
	}
};

/**
 * 다운로드
 */
var downloadRecFile = function(rowIndx) {
	var rowData	= $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});
	var rec_datm = rowData["rec_datm"].replace(/\s|-|:|\./gi,"");
	//20170908 현원희 수정 : custom_fld_04 추가
	// var info = getEncData(rec_datm + "|" + rowData["local_no"] + "|" + rowData["rec_filename"] + "|" + toNN(rowData["custom_fld_04"]), "1");
	
	var info = '';
	info += rec_datm;
	info += "|" + rowData["local_no"];
	info += "|" + rowData["rec_filename"];
	info += "|" + toNN(rowData["custom_fld_04"]);
	
	//alert(info);
	info = getEncData(info, "1");
	
	//사유 입력 유무
	if(isExistPlayDownReason)
	{
		openPopup("../rec_search/download_reason.jsp?info="+encodeURIComponent(info),"_download","556","260","yes","center");
	}
	else
	{
		//확장자 선택 유무
		if(isDownloadExt)
		{
			openPopup("../rec_search/download_ext.jsp?info="+encodeURIComponent(info),"_downloadExt","400","180","yes","center");
		}
		else
		{
			hiddenFrame.location = "../rec_search/download.jsp?info="+encodeURIComponent(info);	
		}
	}
	//$("#hiddenFrame").prop("src",	"download.jsp?rec_datm="+rec_datm+"&local_no="+rowData["local_no"]+"&rec_filename="+rowData["rec_filename"]);
	//openPopup("../rec_search/download_reason.jsp?rec_datm="+rec_datm+"&local_no="+rowData["local_no"]+"&rec_filename="+encodeURIComponent(rowData["rec_filename"]),"_download","556","260","yes","center");
};

/**
 * 다운로드2
 */
var downloadRecFile2 = function(getRowIndx) {

	var info = getEncData(getRowIndx, "1");

	if(isExistPlayDownReason)
	{
		openPopup("../rec_search/download_reason2.jsp?info="+encodeURIComponent(info),"_download","556","260","yes","center");
	}
	else
	{
		hiddenFrame.location = "../rec_search/download2.jsp?info="+encodeURIComponent(info);
	}

};

/**
 * 다운로드3
 */
var downloadRecFile3 = function(arg_rec_datm, arg_local_no, arg_rec_filename, arg_custom_fld_04) {
	
	/*
		var ids = [];
		ids.push(arg_rec_datm.replace(/\s|-|:|\./gi,"")+"|" + arg_local_no + "|" + arg_rec_filename);
		downloadRecFile2(ids);
	*/
	var rec_datm = arg_rec_datm.replace(/\s|-|:|\./gi,"");

	var info = '';
	info += rec_datm;
	info += "|" + arg_local_no;
	info += "|" + arg_rec_filename;
	// info += "|" + arg_custom_fld_04;
	info = getEncData(info, "1");

	if(isExistPlayDownReason)
	{
		openPopup("../rec_search/download_reason.jsp?info="+encodeURIComponent(info),"_download","556","260","yes","center");
	}
	else
	{
		hiddenFrame.location = "../rec_search/download.jsp?info="+encodeURIComponent(info);
	}
};

/** ===============================================================
 *  grid
 ** =============================================================== 
 */

/**
 * 기본 데이터 모델 속성 리턴
 */
var getBaseGridDM = function(page_id) {
	
	var dataModel = {
		location: "remote",
		sorting: "remote",
		//sortDir: "down",
		dataType: "JSON",
		method: "POST",
		curPage: "1",
		getUrl: function(ui){
			var data = arrToJson($("#search").serializeArray());
			data.cur_page = ui.pageModel.curPage;
			data.top_cnt = ui.pageModel.rPP;
			data.sort_idx = toNN(ui.dataModel.sortIndx);
			data.sort_dir = toNN(ui.dataModel.sortDir,"up");
			
			/*
			console.log("data : "+JSON.stringify(arrToJson($("#search").serializeArray())));
			console.log("ui : "+JSON.stringify(ui.pageModel));
			console.log("cur_page : "+ui.pageModel.curPage + "|top_cnt : "+ui.pageModel.rPP+ "|sort_idx : "+ui.pageModel.sortIndx+ "|sortDir : "+ui.pageModel.sortDir);
			*/
			return { url: "remote_"+page_id+".jsp",	data: data }
		},
		getData: function (dataJSON, textStatus, jqXHR) {
			console.log("code : "+dataJSON.code);
			if(dataJSON.code == "ERR") 
			{
				alert(dataJSON.msg);
				return false;
			} else if (dataJSON.code == "ERRLOGIN") {
				alert(dataJSON.msg);
				top.location.replace('/index.jsp');
				return false;
			} else {
				//alert(objToStr(dataJSON));
				//console.log("dataJson : "+objToStr(dataJSON));
				var $tit = $(this).find(".pq-toolbar input[name=toolbar_title]");
				$tit.val("전체: " + dataJSON.totalRecords);
				//Grid(기본) 속성 정의가  정상적으로 실행 될 경우 - CJM(20190117)
				baseGridChk = true;
				//$(this).closest('tr').addClass('cls_clicked');
				//console.log($(this));
//				console.log("getBaseGridDM 실행");
				
				//$("#grid .pq-grid-table .pq-grid-row").addClass("cls_clicked");
				//$("table tbody tr").addClass("cls_clicked");
				//$('.pq-td-div').closest('tr').addClass('cls_clicked');
				//$grid.pqGrid("addClass", { rowIndx: 1, cls: 'cls_clicked' });
				//console.log("data : "+objToStr(dataJSON.data));
				return { totalPages: dataJSON.totalPages, curPage: dataJSON.curPage, totalRecords: dataJSON.totalRecords, data:	dataJSON.data };
			}
		}
	};

	return dataModel;
};

/**
 * 기본 grid option 리턴 (페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부)
 */
var getBaseGridOption = function(page_id, paging_yn, excel_yn, new_yn, edit_yn) {
	var gridOpt = {
		width: "100%",
		flexHeight: true,
		scrollModel: { autoFit: true },
		numberCell: { show: false },
		editable: false,
		collapsible: false,
		wrap: false,
		showTitle: false,
		toolbar : { items: [
						// 전체 건수 표시
						{ type: "textbox", attr: "name='toolbar_title'" }
				  ]},
	};
	
	// 페이징 사용여부
	if(paging_yn == "Y") 
	{
		gridOpt.pageModel = { type:	"remote", rPP: 20, strRpp: "{0}", strDisplay:"{0} to {1} of {2}" };
	}

	// 엑셀다운로드 사용여부
	if(excel_yn == "Y") 
	{
		gridOpt.toolbar.items.push(
			// 엑셀다운로드 버튼 추가
			{ type: "button", icon: "ui-icon-excel", label: "엑셀", style: 'float: right; margin-right: 5px;', listeners: [{
					"click": function () {
						var cur_page = $grid.pqGrid("option","pageModel.curPage");
						var top_cnt	= $grid.pqGrid("option","pageModel.rPP");
						var sort_idx = $grid.pqGrid("option","dataModel.sortIndx");
						var sort_dir = $grid.pqGrid("option","dataModel.sortDir");
						$("#hiddenFrame").prop("src", "excel_" + page_id + ".jsp?"+$("#search").serialize()+"&cur_page="+cur_page+"&top_cnt="+top_cnt+"&sort_idx="+sort_idx+"&sort_dir="+sort_dir);
					}
				}]
			}
		);
	}
	else if(excel_yn == "YY") 
	{
		//페이징이 없는 모든 데이터가 그리드에 존재하는 경우 엑셀은 이 것을 사용한다.(예 : 통계)
		gridOpt.toolbar.items.push(
			// 엑셀다운로드 버튼 추가
			{ type: "button", icon: "ui-icon-excel", label: "엑셀", style: 'float: right; margin-right: 5px;', listeners: [{
					"click": function () {
						var data = $grid.pqGrid("option","dataModel.data");
						var args = {"data":objToStr(data)};
						makeFormAndGo("fExcel", "excel_" + page_id + ".jsp", "hiddenFrame", args);
					}
				}]
			}
		);
	}

	if(edit_yn == "Y") 
	{
		gridOpt	= $.extend({}, gridOpt, {
			editable: true,
			track: true,
			hoverMode: "cell",
			editModel: {
				saveKey: $.ui.keyCode.ENTER,
			},
			quitEditMode: function (evt, ui) {
				if (evt.keyCode != $.ui.keyCode.ESCAPE) {
					$grid.pqGrid("saveEditCell");
				}
			},
			refresh: function () {
				$("#grid").find(".btn_delete")
				.unbind("click")
				.bind("click", function (evt) {
					var $tr = $(this).closest("tr");
					var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;

					deleteRow(page_id, rowIndx);
				});
			},
			cellBeforeSave: function (evt, ui) {
				var isValid = $grid.pqGrid("isValid", ui);
				if (!isValid.valid) {
					evt.preventDefault();
					return false;
				}
			},
		});

		gridOpt.toolbar.items.push(
			{ type: 'button', icon: 'ui-icon-cancel', label: '취소', style: 'float: right; margin-right: 5px;', listeners: [{
					"click": function () {
							$grid.pqGrid("rollback");
						}
				}]
			},
			{ type: 'button', icon: 'ui-icon-disk',	label: '일괄수정', style: 'float: right; margin-right: 5px;', listeners: [{
				"click": function () {
						updateChanges(page_id);
					}
				}]
			}
		);
	}

	// 신규등록 사용여부
	if(new_yn == "Y") 
	{
		gridOpt.toolbar.items.push(
			{ type: "button", icon: "ui-icon-document", label: "신규등록", style: 'float: right; margin-right: 5px;',	attr: "data-toggle='modal'", listeners: [{
					"click": function () {
						$("#modalRegiForm form")[0].reset();	// 기존 입력값 reset
						$("#modalRegiForm").modal("toggle");
					}
				}]
			}
		);
	}

	return gridOpt;
};

/**
 * 일괄수정 버튼 클릭시 실행
 */
var updateChanges = function(page_id) {
	//attempt to save editing cell.
	if($grid.pqGrid("saveEditCell") === false) 
	{
		return false;
	}

	var isDirty	= $grid.pqGrid("isDirty");
	if(!isDirty) 
	{
		alert("수정된 내용이 없습니다.");
		return false;
	}

	if(confirm("정말로 수정하시겠습니까?")) 
	{
		var changes = $grid.pqGrid("getChanges", { format: "byVal" });

		$.ajax({
			type: "POST",
			url: "remote_" + page_id + "_proc.jsp",
			async: false,
			dataType: "json",
			data: { step: "update", data_list: JSON.stringify(changes.updateList) },
			success: function (dataJSON) {
				//alert(objToStr(dataJSON));
				if(dataJSON.code == "OK") 
				{
					if(dataJSON.msg!="") {alert(dataJSON.msg);}
					$grid.pqGrid("commit", { type: "update", rows: changes.updateList });

					// tree가 존재한다면 데이터 수정 후	tree reload
					//if($("#tree").length>0) {
					if(dataJSON.tree != undefined && dataJSON.tree.refresh == "true") 
					{
						$("#tree").jstree(true).refresh();
					}
					//오류 발생으로 위치 변경 - CJM(20200630)
					$grid.pqGrid("refreshDataAndView");
				} 
				else 
				{
					alert(dataJSON.msg);
					$grid.pqGrid("refreshDataAndView");
					//rollback 주석 해제 - CJM(20190114)
					$grid.pqGrid("rollback");
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다.\n\nreq : " + req.responseText+"\nerr : "+err+"\nstatus : "+status);
				$grid.pqGrid("rollback");
			},
			beforeSend:	function () {
				$grid.pqGrid("showLoading");
			},
			complete: function () {
				$grid.pqGrid("hideLoading");
			},
		});
	} 
	else 
	{
		$grid.pqGrid("rollback");
	}
};

/**
 * delete row
 */
var deleteRow = function(page_id, rowIndx) {
	$grid.pqGrid("addClass", { rowIndx:	rowIndx, cls: 'pq-row-delete' });

	if (confirm("정말로 삭제하시겠습니까?")) 
	{
		var recIndx	= $grid.pqGrid("getRecId", { rowIndx: rowIndx });
		var rowData	= $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});

		$.ajax({
			type: "POST",
			url: "remote_" + page_id + "_proc.jsp",
			async: false,
			dataType: "json",
			data: { step: "delete",	row_id:	recIndx },
			success:function(dataJSON){
				if(dataJSON.code == "OK") 
				{
					$grid.pqGrid("deleteRow", {	rowIndx: rowIndx, effect: true });
					alert("정상적으로 삭제되었습니다.");
					$grid.pqGrid("commit");
					$grid.pqGrid("refreshDataAndView");

					// tree가 존재한다면 데이터 삭제 후	tree reload
					//if($("#tree").length>0) {
					if(dataJSON.tree != undefined && dataJSON.tree.refresh == "true") 
					{
						$("#tree").jstree(true).refresh();
					}
				} 
				else 
				{
					alert(dataJSON.msg);
					$grid.pqGrid("refreshDataAndView");
					//$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
					//$grid.pqGrid("rollback");
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다. [" + req.responseText + "]");
				$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
				$grid.pqGrid("rollback");
			},
			/*beforeSend: function () {
				$grid.pqGrid("showLoading");
			},
			complete: function () {
				$grid.pqGrid("hideLoading");
			},*/
		});
	}
	else 
	{
		$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
	}
};

/**
 * 위 평션 에서 recIndx 가 제대로 안구해 지는 현상이 있는 페이지 있음 (예 : 평가결과조회 (eval_result.jsp))
 * 해당 row의 모든 Data 를 구해서 parameter로 삭제 페이지에 넘긴다.
 */
var deleteRowByData = function(page_id, rowIndx) {
	$grid.pqGrid("addClass", { rowIndx: rowIndx, cls: 'pq-row-delete' });

	if (confirm("정말로 삭제하시겠습니까?")) 
	{
		var data = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
		data.step = "delete";

		$.ajax({
			type: "POST",
			url: "remote_" + page_id + "_proc.jsp",
			async: false,
			dataType: "json",
			data: data,
			success:function(dataJSON){
				if(dataJSON.code == "OK") 
				{
					$grid.pqGrid("deleteRow", { rowIndx: rowIndx, effect: true });
					alert("정상적으로 삭제되었습니다.");
					$grid.pqGrid("commit");
					$grid.pqGrid("refreshDataAndView");

					// tree가 존재한다면 데이터 삭제 후 tree reload
					//if($("#tree").length>0) {
					if(dataJSON.tree != undefined && dataJSON.tree.refresh == "true") 
					{
						$("#tree").jstree(true).refresh();
					}
				} 
				else 
				{
					alert(dataJSON.msg);
					$grid.pqGrid("refreshDataAndView");
					//$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
					//$grid.pqGrid("rollback");
				}
			},
			error:function(req,status,err){
				alert("에러가 발생하였습니다. [" + req.responseText + "]");
				$grid.pqGrid("removeClass", { rowIndx: rowIndx,	cls: 'pq-row-delete' });
				$grid.pqGrid("rollback");
			},
		});
	}
	else 
	{
		$grid.pqGrid("removeClass", { rowIndx: rowIndx, cls: 'pq-row-delete' });
	}
};

/**
 * grid 데이터 조회 함수
 */
var searchs = function() 
{
	//공통모듈 실행하기 전에 해당페이지 펑션 체크 (유효성 체크등..)
	//on load시 자동 조회 기능 제거후 두번 조회되는 현상 현상 발생하여 예외 처리 - CJM(20190107)
	//var dataChek = $grid.pqGrid("option", "dataModel.data");
	//var sortingChek = $grid.pqGrid("option","dataModel.sorting");
	//console.log("공통조회1 : |"+dataChek+"|");
	//console.log("공통조회 sorting  : "+sortingChek);
	
	//console.log("baseGridChk : "+baseGridChk);
	
	//if(sortingChek != "remote" || dataChek != null)
	//if(dataChek != null)
	if(baseGridChk)
	{
		//조회 조건 일자 체크 - CJM(20190715)
		/*
		var date1 = $("#search input[name=rec_date1]");
		var date2 = $("#search input[name=rec_date2]");
		if(!recSearchChk(date1 ,date2)) return;
		*/
		
		//Validation 체크 기능 추가(메뉴별 구분) - CJM(20200728)
		var fvId = this.location.pathname;
		fvId = fvId.substring(fvId.lastIndexOf("/")+1, fvId.lastIndexOf("."));
		console.log("fvId : "+fvId);
		if(!fnValidation(fvId))	return;
		
		var isContinue = true;
		try{isContinue = beforeSearchFunc()}catch(e){console.log("Not Found Searchfunctioin")}
		if(!isContinue) return;
		
		// 1번 page로	초기화
		$grid.pqGrid("option", "pageModel.curPage", 1);
		$grid.pqGrid("refreshDataAndView");
	}
};

/** ===============================================================
 *	date
 ** ===============================================================
 */

/**
 * 8자리 숫자 -> yyyy.mm.dd
 */
var getDateToNum = function(str, delimeter) {
	if(str.length != 8) 
	{
		return str;
	}
	return str.substr(0,4) + delimeter + str.substr(4,2) + delimeter + str.substr(6,2);
};

/**
 * 초 ->	HH:mm:ss
 */
var getHmsToSec = function(sec) {
	var h = Math.floor(sec/3600);
	var m = Math.floor(sec%3600/60);
	var s = Math.floor(sec%60);

	return ((h<10) ? "0"+h : h) + ":" + ((m<10) ? "0"+m : m) + ":" + ((s<10) ? "0"+s : s);
};

/**
 * 초 -> mm:ss
 */
var getMsToSec = function(sec) {
	var m = Math.floor(sec/60);
	var s = Math.floor(sec%60);

	return ((m<10) ? "0"+m : m) + ":" + ((s<10) ? "0"+s : s);
};

/**
 * 시분초 유효성 체크
 */
var isValidHms = function(str) {
	var arr	= str.split(":");

	if(arr.length != 3)	return false;

	var h = parseInt(arr[0]);
	var m = parseInt(arr[1]);
	var s = parseInt(arr[2]);

	return (h>=0 && h<=24) && (m>=0 && m<60) && (s>=0 && s<60);
};

/** ===============================================================
 *  validation check
 ** =============================================================== 
 */

/**
 * 공통 validation 체크 기능
 */
var fnValidation = function(id)
{
	var fDt = "";
	var tDt = "";
	var fScDt = "";
	var tScDt = "";
	
    switch (id) 
    {
		case "rec_search":
		case "user_dept_stat":
		case "system_stat":
			fDt = $("#search input[name=rec_date1]");
			tDt = $("#search input[name=rec_date2]");
			
			if(!fnDateNullChk(fDt, tDt))	return;
			if(!fnFtDateChk(fDt, tDt))		return;
		break;
		
    	case "eval_user_list": 
    	case "sheet":
			fDt = $("#search input[name=regi_date1]");
			tDt = $("#search input[name=regi_date2]");

			if(!fnFtDateChk(fDt, tDt))		return;
    	break;

    	case "eval_result":
    	case "event_stat":
    	case "user_stat":
    	case "user_item_stat":
    	case "user_comment_stat":
    	case "dept_stat":
    	case "average_stat":
			fDt = $("#search input[name=eval_date1]");
			tDt = $("#search input[name=eval_date2]");

			if(!fnFtDateChk(fDt, tDt))		return;
    	break;
    		
		case "login_hist":
			fDt = $("#search input[name=login_date1]");
			tDt = $("#search input[name=login_date2]");

			if(!fnDateNullChk(fDt, tDt))	return;
			if(!fnFtDateChk(fDt, tDt))		return;
		break;
		
		case "user_change_hist":
			fDt = $("#search input[name=change_date1]");
			tDt = $("#search input[name=change_date2]");

			if(!fnDateNullChk(fDt, tDt))	return;
			if(!fnFtDateChk(fDt, tDt))		return;
		break;

		case "excel_hist":
			fDt = $("#search input[name=excel_date1]");
			tDt = $("#search input[name=excel_date2]");

			if(!fnDateNullChk(fDt, tDt))	return;
			if(!fnFtDateChk(fDt, tDt))		return;
		break;
		
		case "listen_hist":
			fDt = $("#search input[name=rec_date1]");
			tDt = $("#search input[name=rec_date2]");
			fScDt = $("#search input[name=listen_date1]");
			tScDt = $("#search input[name=listen_date2]");

			if(!fnDateNullChk(fScDt, tScDt))	return;
			if(!fnFtDateChk(fScDt, tScDt))		return;
			if(!fnFtDateChk(fDt, tDt))			return;
		break;
		
		case "down_hist":
			fDt = $("#search input[name=rec_date1]");
			tDt = $("#search input[name=rec_date2]");
			fScDt = $("#search input[name=down_date1]");
			tScDt = $("#search input[name=down_date2]");
			
			if(!fnDateNullChk(fScDt, tScDt))	return;
			if(!fnFtDateChk(fScDt, tScDt))		return;
			if(!fnFtDateChk(fDt, tDt))			return;
		break;
		
		default:
			break;
    }
    return true;
};

/**
 * 일자 조건 NULL 체크
 */
var fnDateNullChk = function(d1, d2)
{
	if(d1.val() == "" || d2.val() == "")
	{
		alert("조회 일자를 선택하세요.");
		d1.focus();
		return false;
	}
	return true;
};

/**
 * 시작, 종료 일자 조건 체크
 */
var fnFtDateChk = function(d1, d2)
{
	var datePattern = /^(19|20)\d{2}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[0-1])$/;
	
	if(!gf_isNull(d1.val()) && !datePattern.test(d1.val()))
	{
		alert("시작 일자를 잘못 입력하였습니다."); 
		d1.focus();
		return false;
	}

	if(!gf_isNull(d2.val()) && !datePattern.test(d2.val()))
	{
		alert("종료 일자를 잘못 입력하였습니다."); 
		d2.focus();
		return false;
	}
	
	if((!gf_isNull(d1.val()) && !gf_isNull(d2.val()))  && (d1.val() > d2.val()))
	{
		alert("조회 종료일자가 시작일자보다 과거일자입니다.\n다시 입력해 주십시오.");
		d2.focus();
		return false;
	}

	/*
	if(dateDiff(d1.val(), d2.val()) > 7) 
	{
		alert('일자 조회 범위가 너무 큽니다. \n일주일 이하 조회 가능합니다.');
		d2.focus();
		return false;
	}
	*/
	return true;
};

/**
 * 녹취 조회 조회 조건 체크
 */
var recSearchChk = function(d1, d2)
{
	if(d1.val() == "" || d2.val() == "")
	{
		alert("조회 일자를 선택하세요.");
		d1.focus();
		return false;
	}
	
	if(d1.val() > d2.val())
	{
		alert("조회 종료일자가 시작일자보다 과거일자입니다.\n다시 입력해 주십시오."); 
		d2.focus();
		return false;
	}

	/*
	if(dateDiff(d1.val(), d2.val()) > 7) 
	{
		alert('일자 조회 범위가 너무 큽니다. \n일주일 이하 조회 가능합니다.');
		d2.focus();
		return false;
	}
	*/
	return true;
};

/**
 * 비밀번호 변경
 */
var changePasswd = function(tp) {
	if(!$("#passwdUpd input[name=user_id]").val().trim())
	{
		alert("상담원ID를 입력해 주십시오.");
		$("#passwdUpd input[name=user_id]").focus();
		return false;
	}
	if(!$("#passwdUpd input[name=user_pass]").val().trim())
	{
		alert("현재 비밀번호를 입력해 주십시오.");
		$("#passwdUpd input[name=user_pass]").focus();
		return false;
	}
	if(!$("#passwdUpd input[name=new_pass]").val().trim())
	{
		alert("변경 비밀번호를 입력해 주십시오.");
		$("#passwdUpd input[name=new_pass]").focus();
		return false;
	}
	if(!$("#passwdUpd input[name=new_pass_re]").val().trim())
	{
		alert("변경 비밀번호 (재확인)을 입력해 주십시오.");
		$("#passwdUpd input[name=new_pass_re]").focus();
		return false;
	}
	if($("#passwdUpd input[name=new_pass]").val().trim()!=$("#passwdUpd input[name=new_pass_re]").val().trim())
	{
		alert("변경 비밀번호와 변경 비밀번호 (재확인)이 일치하지 않습니다.");
		$("#passwdUpd input[name=new_pass]").focus();
		return false;
	}
	if($("#passwdUpd input[name=user_pass]").val().trim()==$("#passwdUpd input[name=new_pass]").val().trim())
	{
		alert("현재 비밀번호와 동일한 비밀번호 입니다.");
		$("#passwdUpd input[name=new_pass]").focus();
		return false;
	}
	if(!checkPasswd($("#passwdUpd input[name=user_id]").val().trim(), $("#passwdUpd	input[name=new_pass]").val().trim(), false))
	{
		$("#passwdUpd input[name=new_pass]").focus();
		return false;
	}

	// 호출되는	페이지에 따른	경로 설정 (top / index)
	//var type = $(this).attr("prop");
	var url_prefix = (tp == "U") ? "../" : "./";
	
	$.ajax({
		type: "POST",
		url: url_prefix + "common/passwd_update.jsp",
		async: false,
		data: "step=update&type="+tp+"&"+$("#passwdUpdEn").serialize(),
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code == "OK") 
			{
				alert("정상적으로 변경되었습니다.");
				if(tp == "U" || tp == "C")
				{
					$("#modalPasswdForm").modal("hide");
					
					//비밀번호 변경 입력창 초기화 - CJM(20190524)
					if(tp == "C")	$("#passwdUpd")[0].reset();
				}
				else
				{
					$("#modalPasswdForm").dialog("close");
				}
			}
			else
			{
				alert(dataJSON.msg);
				return false;
			}
		},
		error:function(req,status,err){
			alert("에러가 발생하였습니다. [" + req.responseText + "]");
			return false;
		}
	});
};

/**
 * 비밀번호 유효성 검사
 */
var checkPasswd = function(id, pass, rtnMsg) {
	// 비밀번호 유효성 검사 추가
	var exp_space = /[\s]/gi;
	var exp_en = /[a-zA-Z]/gi;
	var exp_num = /[0-9]/gi;
	var exp_eq = /(\w)\1{2}/gi;
	//var exp_sp = /[\{\}\[\]\/?.,;:|\)*~`!^\-_+<>@\#$%&\\\=\(]/gi;
	var exp_sp = /[\{\}\[\]\/?.,|\)*~`!^\-_+@\#$&\\\(]/gi;
	var exp_no_sp = /["':;<>%\=]/gi;
	var cb_cnt = 0;
	var msg = "";

	if(pass.length < 10 || pass.length > 30 || exp_space.test(pass)) 
	{
		msg = "비밀번호를 공백없이 10자리 이상 30자리 이하로 입력해 주십시오.";
	} 
	else if(pass.indexOf(id) > -1) 
	{
		msg = "비밀번호에 아이디를 사용할 수 없습니다.";
	} 
	else if(exp_no_sp.test(pass)) 
	{
		msg = "특정 특수문자는 사용하실 수 없습니다. [ \" % ' : ; < = > ]";
	} 
	else if(exp_eq.test(pass)) 
	{
		msg = "비밀번호는 동일 문자/숫자를 3회 이상 사용하실 수 없습니다.";
	} 
	else if(checkStraightStr(pass, 3)) 
	{
		msg = "비밀번호는 연속된 문자/숫자를 3회 이상 사용하실 수 없습니다.";
	} 
	else if(checkStraightStr(getReverseStr(pass), 3)) 
	{
		msg = "비밀번호는 역순으로 연속된 문자/숫자를 3회 이상 사용하실 수 없습니다.";
	} 
	else 
	{
		if(exp_en.test(pass)) {		cb_cnt++; }
		if(exp_num.test(pass)) {	cb_cnt++; }
		if(exp_sp.test(pass)) {		cb_cnt++; }

		if(cb_cnt < 2) 
		{
			msg = "비밀번호를 영문/숫자/특수문자	중 2가지 이상을 조합하여 입력해 주십시오.";
		}
	}

	if(rtnMsg) 
	{
		return msg;
	} 
	else 
	{
		if(msg != "") 
		{
			alert(msg);
			return false;
		} 
		else 
		{
			return true;
		}
	}
};

/**
 * 브라우저 언어 체크
 */
var getLanguage = function() {
	var userLang = navigator.language || navigator.userLanguage;
	return userLang;
};
