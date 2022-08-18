package com.cnet.crec.common;

import java.util.HashMap;

public class Finals
{
	//개발 여부 (개발에 필요한 여러 세팅을 한다) 운영 false
	public static boolean 			isDev = true;

	//프로그램 메인 타이틀
	public static final String		MAIN_TITLE_LOGIN = "<img alt='image' src='img/logo/main_title_login.png' />";
	public static final String		MAIN_TITLE_TOP   = "<img alt='image' src='../img/logo/main_tile_top.png' />";
	//public static final String	MAIN_TITLE_TOP   = "<span style='font-size:24px;font-weight:bold;'>CNETTECH</span>";

	//백업 DB 존재 유무
	public static final boolean		isExistBackupServer = false;
	//서버 URL
	public static String 			SERVER_URL = (!isDev) ? "http://127.0.0.1" : "http://127.0.0.1"; //운영 : 개발

	/* :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 녹취 이력 설정 START ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

	//미디어 서버 URL
	public static String 			MEDIA_SERVER_URL = (!isDev) ? "http://127.0.0.1:8888" : "http://127.0.0.1:8888"; //운영 : 개발

	/**
	 * HTTPS 일 경우 문제 발생
	 * 미디어 서버 URL 다운로드
	 */
	public static String 			MEDIA_SERVER_URL_D = (!isDev) ? "http://127.0.0.1:8888" : "http://127.0.0.1:8888"; //운영 : 개발

	/**
	 * 청취/다운 사유 입력 유무
	 * 사유 입력 팝업 미노출	: false
	 * 사유 입력 팝업 노출		: true
	 */
	public static final boolean		isExistPlayDownReason = true;

	/**
	 * 다운로드 확장자 선택 유무
	 * 팝업 미노출	: false
	 * 팝업 노출		: true
	 */
	public static final boolean		isDownloadExt = false;

	//다중다운로드
	public static final boolean		isExistMultiDownload = false;

	/**
	 * 녹취 다운로드 여부 미노출 및 기능 사용 여부
	 * 다운로드 기능 사용 권한에 대한 설정
	 * 등급별 다운로드 부여에서 추가로 상담원별 다운로드 사용 권한 부여
	 * 녹취 다운로드 선택 창 미노출	: true
	 * 녹취 다운로드 선택 창 노출	: false
	 */
	public static final boolean		isRecDownload = true;

	/**
	 * 부분 녹취 기능 사용 여부 설정
	 * 청취 플레이어 부분녹취 기능
	 * 부분 녹취 버튼 미노출	: false
	 * 부분 녹취 버튼 노출		: true
	 */
	public static final boolean		isExistPartRecord = false;

	/**
	 * 고객 정보 수정 기능 사용 여부 설정
	 * 청취 플레이어 고객 정보 수정 기능
	 * 고객정보수정 버튼 미노출	: false
	 * 고객정보수정 버튼 노출	: true
	 */
	public static final boolean		isExistRegiPart = false;

	/**
	 * 마킹 기능 사용 여부 설정
	 * 청취 플레이어 마킹 기능
	 * 마킹 버튼 노출		: true
	 * 마킹 버튼 미노출	: false
	 */
	public static final boolean		isExistMarking = true;

	/**
	 * 영구 녹취 기능 사용 여부 설정
	 * 청취 플레이어 영구 녹취 기능
	 * 영구 버튼 미노출	: false
	 * 영구 녹취 버튼 노출	: true
	 */
	public static final boolean		isExistEverlasting = false;

	//필수중단
	public static final boolean		isExistPilsooJungdan = false;

	/* :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 녹취 이력 설정 END   ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

	/* :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 기본관리 설정 START  ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

	//녹취파일 보관일수 미노출 여부
	//미노출 : true 노출 : false
	public static final boolean		isRecFileKeep = true;

	/**
	 * 채널 노출 여부
	 * 조직도 관리에 상담원 조회시 채널번호 입력창 활성화 여부 설정
	 * IP 일 경우 내선번호 입력시 채널 관리에 등록된 채널 번호 자동 등록
	 * TDM 일 경우 채널 관리 X 조직도 관리 상담원 조회에서 채널 번호 수동 입력 필요
	 * 채널 입력창 미 활성화(IP) : true
	 * 채널 입력창 활성화(TDM)  : false
	 */
	public static final boolean		isChannel = true;

	/**
	 * 비밀번호 사용 기간 미노출 및 기능 사용 여부
	 * 비밀번호 사용 기간 관련 내용 노출, 미노출 설정
	 * 비밀번호 사용 기간 미노출	: true
	 * 비밀번호 사용 기간 노출	: false
	 */
	public static final boolean		isPassChgTerm = true;

	/* :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 기본관리 설정 END    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

	/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::   이력 설정 START    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

	//TA 유무 미노출 여부
	//외부에 다운로드시 다운로드 이력 요청시 필요
	//미노출 : false 노출 : true
	public static final boolean		isTa = false;

	/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::   이력 설정 END      ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

	/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::   평가 설정 START    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

	//평가관리 관련 기능 미노출 여부
	//미노출 : true 노출 : false
	public static final boolean		isEval = true;
	//평가 최대 차수
	public static int 				EVAL_ORDER_MAX = 16;
	//평가수행 프로그램명 (평가자가 아니면 평가수행 메뉴 안보이게 하기 위함 (top.jsp)
	public static final String		EVAL_PROGRAM = "/eval.jsp";
	//평가 완료하기 버튼
	public static final boolean		isExistEvalFinish = false;
	//평가 상태 정보
	public static HashMap<String, String> hEvalStatus			= new HashMap<String, String>();
	public static HashMap<String, String> hEvalStatusHtml		= new HashMap<String, String>();
	public static HashMap<String, String> hEvalStatusOption1	= new HashMap<String, String>();
	//평가 이의신청 상태 정보
	public static HashMap<String, String> hClaimStatus			= new HashMap<String, String>();
	public static HashMap<String, String> hClaimStatusHtml		= new HashMap<String, String>();
	public static HashMap<String, String> hUsedCode				= new HashMap<String, String>();

	/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::   평가 설정 END      ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::  */

	/**
	 * S : 공통코드
	 * 공통코드 의 값 구하기
	 * @param h
	 * @param key
	 * @return
	 */
	public static String getValue(HashMap<String, String> h, Object key)
	{
		return (h == null || h.get(key) == null) ? "" : h.get(key).toString();
	}

	/**
	 * 공통코드 및 값 로딩
	 */
	public static void setApplicationVariable()
	{
		setApplicationVariable(false);
	}

	/**
	 * setApplicationVariable
	 * @param isForce
	 */
	public static void setApplicationVariable(boolean isForce){
		if(hEvalStatus.isEmpty() || isForce)
		{
			//평가상태 : tbl_eval_event_agent_list.eval_status
			//평가수행 > 평가대상자 목록 : 평가상태
			//평가수행 > 상담이력 목록, 평가결과 조회 목록
			//평가결과 조회 목록 > 검색조건 : 평가상태
			hEvalStatus.put("","미평가");		hEvalStatusHtml.put("","-");
			hEvalStatus.put("0","미평가");		hEvalStatusHtml.put("0","-");
			hEvalStatus.put("1","진행중");		hEvalStatusHtml.put("1","<font color=gray>진행</font>");		hEvalStatusOption1.put("1","진행");
			hEvalStatus.put("2","평가저장");		hEvalStatusHtml.put("2","저장");								hEvalStatusOption1.put("2","평가");
			hEvalStatus.put("9","평가완료");		hEvalStatusHtml.put("9","<font color=blue>완료</font>");		hEvalStatusOption1.put("9","완료");
			hEvalStatus.put("a","이의대기");		hEvalStatusHtml.put("a","<font color=red>이의</font>대기");	hEvalStatusOption1.put("a","이의대기");
			hEvalStatus.put("d","이의접수");		hEvalStatusHtml.put("d","<font color=red>이의접수</font>");	hEvalStatusOption1.put("d","이의접수");

			hClaimStatus.put("a", "이의대기");				hClaimStatusHtml.put("a", "<font color=red>이의</font>대기");
			hClaimStatus.put("b", "접수자 이의신청 반려");		hClaimStatusHtml.put("b", "접수자 이의신청 <font color=red>반려");
			hClaimStatus.put("d", "이의접수");				hClaimStatusHtml.put("d", "<font color=red>이의접수</font>");
			hClaimStatus.put("f", "평가자 이의신청 반려");		hClaimStatusHtml.put("f", "평가자 이의신청 <font color=red>반려</font>");
			hClaimStatus.put("g", "평가자 이의신청 접수");		hClaimStatusHtml.put("g", "평가자 이의신청 <font color=blue>접수</font>");

			hUsedCode.put("0", "사용안함");
			hUsedCode.put("1", "사용");
		}
	}
}