<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/common.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%!	static Logger logger = Logger.getLogger("player_stream.jsp"); %>
<%	
	try {	
		// get parameter
		String info = CommonUtil.getParameter("info");
		
		// 파라미터 체크
		if(!CommonUtil.hasText(info)) {
			out.print(CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}
		
		// 파라미터 복호화
		CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());
		info = aes.Decrypt(info);
		
		// 요청시간|파일경로
		String tmp_arr[] = info.split("\\|");
		
		// 요청시간 비교
		Date req_datm = DateUtil.getDate(DateUtil.getDateFormatByIntVal(tmp_arr[0], "yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");
		Date now_datm = DateUtil.getDate(DateUtil.getToday("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");
		
		// 경과시간 체크
		// date diff
		int min = DateUtil.getDateDiff(req_datm, now_datm, "M");
		
		if(min>5) {
			out.print("요청시간이 초과하였습니다.");
			return;			
		}
		
		//
		response.sendRedirect(tmp_arr[1]);
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {

    }
%>		