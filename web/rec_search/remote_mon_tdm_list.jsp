<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="java.net.DatagramSocket"%>
<%@ page import="java.net.DatagramPacket"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="java.net.SocketTimeoutException"%>
<%
	/*
		해양도시가스 TDM용 개발 - CJM(20181026)
		기존 개발된 것과 전문 형식이 다름 추가 개발
	*/
	if(!Site.isPmss(out,"mon_list","")) return;

	DatagramSocket ds = null;

	try {
		// get parameter
		String system_ip = CommonUtil.getParameter("system_ip");
		String stLocalNo = CommonUtil.getParameter("local_no");

		// 파라미터 체크
		if(!CommonUtil.hasText(system_ip)) {
			out.print(CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// UDP 통신 수신 전문
		ds = new DatagramSocket();

		// send data 설정
		InetAddress address = InetAddress.getByName(system_ip);
		int port = 5003;
		String header = "MON000000X";

		byte[] buf = header.getBytes();

		// send
		DatagramPacket packet = new DatagramPacket(buf, buf.length, address, port);
		ds.send(packet);
		// timeout
		ds.setSoTimeout(2000);

		// receive
		buf = new byte[40000];
		packet = new DatagramPacket(buf, buf.length);
		String recv = "";
		/*
		while(true) {
			try {
				ds.receive(packet);
				recv = new String(packet.getData(), "EUC-KR").trim();
				break;
			} catch (SocketTimeoutException se) {
				out.print("소켓 데이터 수신에 실패했습니다.");
				ds.close();
				throw new Exception(se);
			}
		}
		*/
		
		//recv = "MON113754X101100002D19004081888444  11964E 842194 841469    725032/001.1.3000.3100.3101. .1216      .박경화    .2327    .X.033247.            /002.1.3000.3100.3101. .1338      .장혜화    .2303    .X.113411.            /003.1.3000.3100.3101. .1199      .김진겸    .2304    .X.015013.            /004.2.3000.3100.3101. .1268      .설윤혜    .2305    .X.113623.01084574387 /005.1.3000.3100.3101. .2306      .이소미    .2306    .X.113335.            /006.2.3000.3100.3101. .1201      .박세현    .2307    .X.113549.01088254083 /007.2.3000.3100.3101. .2308      .김민애    .2308    .X.113459.01073405889 /008.1.3000.3100.3101. .1043      .김주희    .2309    .X.100958.            /009.1.3000.3100.3101. .836       .윤이나    .2310    .X.113402.            /010.2.3000.3100.3101. .2311      .김용희    .2311    .X.113647.01050514731 /011.1.3000.3100.3101. .1339      .공석      .2312    .X.015014.            /012.1.3000.3100.3101. .1327      .장은숙    .2313    .X.113622.            /013.2.3000.3100.3101. .1341      .이영란    .2314    .X.113650.0625120571  /014.1.3000.3100.3101. .1340      .이선정    .2328    .X.113628.            /015.1.3000.3100.3101. .1321      .김유미    .2329    .X.113544.            /016.1.3000.3100.3101. .1367      .공석1     .2315    .X.113616.            /017.2.3000.3100.3101. .1297      .윤지원    .2335    .X.113700.01026614988 /018.2.1000.2000.2001. .3980      .3980      .3980    .X.113715.901036405069/019.1.3000.3100.3101. .2318      .이초록    .2318    .X.113628.            /020.2.3000.3100.3101. .1250      .나윤희    .2319    .X.113634.01046158259 /021.1.3000.3100.3101. .1212      .김민희    .2320    .X.113525.            /022.1.3000.3100.3101. .2321      .박나영    .2321    .X.113729.            /023.2.3000.3100.3101. .1205      .서지혜    .2322    .X.113644.01093240022 /024.1.3000.3100.3101. .2309      .김지향    .2323    .X.112851.            /025.2.3000.3100.3101. .1342      .김민지    .2324    .X.113720.01049404492 /026.1.3000.3100.3101. .1305      .박경인    .2325    .X.095220.            /027.1.    .    .    . .          .          .        .X.015016.            /028.1.    .    .    . .          .          .        .X.015017.            /029.1.3000.3100.3101. .1269      .이영애    .2301    .X.015017.            /030.1.    .    .    . .          .          .        .X.015017.            /031.1.    .    .    . .          .          .        .X.015017.            /032.1.3000.3100.3101. .2334      .2334      .2334    .X.015017.";

		// receive data
		//logger.debug("receive data : " + recv);

		String ctiDate = "";		//CTI 연결 상태 정보
		String ctiVal = "연동안됨";	//CTI 연결 상태 정의 값
		String chData = "";			//채널 정보
		
		int cpuDate = 0;			//CPU 부하상태 정보
		int memDate = 0;			//메모리 부하상태 정보
		int totalHddCnt = 0;		//총 하드 수량
		int chCnt = 0;				//채널 수
		
		
		ctiDate = recv.substring(11, 12);
		//logger.debug("ctiDate : " + ctiDate);
		
		if(ctiDate.equals("1"))	ctiVal = "연동됨";
		else					ctiVal = "연동안됨";
		
		cpuDate = Integer.parseInt(recv.substring(11, 14));
		memDate = Integer.parseInt(recv.substring(14, 17));
		
		//하드 수량
		totalHddCnt = Integer.parseInt(recv.substring(17, 19));
		
		//헤더 정보 삭제 
		recv = recv.substring(19);

		//하드 데이터
		String hddData = recv.substring(0, (totalHddCnt*22));
		
		//하드 데이터 삭제 (D 718278 176349 541929E 165277 158941   6336)
		recv = recv.substring((totalHddCnt*22));
		
		//채널 수
		chCnt = Integer.parseInt(recv.substring(0,3));
		
		// 채널 데이터 (채널 데이터 삭제, 061)
		chData = recv.substring(3);
		
		int p = 0;
		
%>
	<!--HDD 데이터 table-->
	<div class="tableSize2">
		<table class="table top-line1 table-bordered">
			<thead>
				<tr>
					<th style="width:10%;">디스크 명</th>
					<th style="width:25%;">사용량 / 총 용량</th>
					<th style="width:15%;">사용률</th>
					<th style="width:10%;">디스크 명</th>
					<th style="width:25%;">사용량 / 총 용량</th>
					<th style="width:15%;">사용률</th>
				</tr>
			</thead>
			<tbody>
<%
	if(totalHddCnt > 0) 
	{
		out.print("<tr>\n");
		String hdd_name = "";
		Float hdd_total = 0.0f;
		Float hdd_use = 0.0f;
		Float hdd_free = 0.0f;
		for(int i=0; i < totalHddCnt; i++) 
		{
			if(i!=0 && i%2==0) 
			{
				out.print("</tr><tr class='odd'>");
			}

			hdd_name = hddData.substring(p+0, p+1);
			hdd_total = Float.parseFloat(hddData.substring(p+1, p+8).trim());
			hdd_free = Float.parseFloat(hddData.substring(p+8, p+15).trim());
			hdd_use = Float.parseFloat(hddData.substring(p+15, p+22).trim());

			out.print("<td>" + hdd_name + " Drive</td>");
			out.print("<td>" + Math.round(hdd_use/1024*100)/100.0 + "G / " + Math.round(hdd_total/1024*100)/100.0 + "G</td>");
			out.print("<td>" + Math.round(hdd_use/hdd_total*100*100)/100.0 + "%</td>");

			p+=22;
		}
		
		if(totalHddCnt %2 == 1) 
		{
			out.print("<td></td>");
			out.print("<td></td>");
			out.print("<td></td>");
		}
		
		out.print("</tr>\n");
	}
%>
			</tbody>
		</table>
	</div>
	<!--내선번호 영역 시작-->
	<div class="grey_back1">
<%
	if(chCnt > 0) 
	{
		String[] chRows = chData.split("/");
		p = 0;
		int hCnt = 0;
		// 채널 1개당 문자열 수
		int per_ch_cnt = 76;
		
		String chNo = "";
		String userName = "";
		String userId = "";
		String localNo = "";
		String chStatus = "";
		String statusCls = "";

		for(int i=1; i<chRows.length; i++) 
		{
			String[] mRows = chRows[i].split("\\.");
			
			chNo = mRows[0].trim();
			userId = mRows[6].trim();
			userName = mRows[7].trim();
			localNo = mRows[8].trim();
			chStatus = mRows[1].trim();

			// 상태별 색상 설정
			if("1".equals(chStatus)) 								// 대기
			{
				statusCls = "1";
			} 
			else if("2".equals(chStatus) || "3".equals(chStatus))	// 녹취 상태 
			{		
				statusCls = "2";
			} 
			else													// 녹취 불량 
			{
				statusCls = "3";
			}

			if("".equals(stLocalNo) || (!"".equals(stLocalNo) && localNo.equals(stLocalNo))) 
			{
				out.print("<div class=\"ext_frame\">\n");
				out.print("	<div class=\"ext_number ext_bg0" + statusCls + "\" style=\"cursor: pointer;\" onclick=\"playRlisten('" + statusCls + "','" + chNo + "','" + localNo + "','01','" + userId + "','" + userName + "')\">" + chNo + "</div>\n");
				out.print("	<div class=\"ext_name\">\n");
				out.print("		<span>" + userName + "</span>\n");
				out.print("		<span style=\"font-size:12px;color:#666;\">" + localNo + "</span>\n");
				out.print("	</div>\n");
				out.print("</div>\n");
			}

			//p+=per_ch_cnt-h_cnt;
		}
	}
%>
	</div>
	<!--HDD 데이터 table 끝-->
	<div class="grey_back2">
		<div class="colLeft"><span class="ext_squre01 colLeft"></span><span class="ext_text">대기상태</span></div>
		<div class="colLeft"><span class="ext_squre02 colLeft"></span><span class="ext_text">녹취상태</span></div>
		<div class="colLeft"><span class="ext_squre03 colLeft"></span><span class="ext_text">녹취불량</span></div>
	</div>
<%
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		// socket close
		if (ds != null) ds.close();
	}
%>