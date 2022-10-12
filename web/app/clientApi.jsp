<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.net.InetAddress"%>
<%@page import="java.net.DatagramPacket"%>
<%@page import="java.net.DatagramSocket"%>
<%@ include file="/common/common.jsp" %>
<%
	DatagramSocket ds = null;
	
	/*
	80130:1111:콜인덱스:[ConnID]
	80060:1111:부서코드:[DepartCode]
	70020:1111:고객명:[CustName]
	80050:1111:보험료조회유무:[PremiumAgreeYN]
	70030:1111:내선번호:[DN]
	70040:1111:상담일시:[CallDateTime]
	70050:1111:업무구분:[BsnsType]
	70060:1111:고객번호:[CustNo]
	70070:1111:증권번호:[PolicyNo]
	70080:1111:접촉이력순번:[CallHistorySeq]
	70090:1111:사고접수번호:[AccidentNo]
	70100:1111:고객전화:[CalledDN]
	70110:1111:업체구분:[ContractorType]
	70120:1111:대리점코드:[ContractorNo]
	70130:1111:상품코드:[ProductCode]
	70140:1111:상담원명:[ClerkName]
	70150:1111:임시:
	70160:1111:계약녹취구분:[RecordYN]
	70170:1111:상담유형코드:[ConsultType]
	70010:1111:상담원사번:[ClerkNo]
	70180:1111:연속구분:[SeqYN]
	*/
	try 
	{
		// get parameter
		String rec = CommonUtil.getParameter("REC");
		String dn = CommonUtil.getParameter("DN");
		String data1 = CommonUtil.getParameter("DATA1", " ");
		String data2 = CommonUtil.getParameter("DATA2", " ");
		String data3 = CommonUtil.getParameter("DATA3", " ");
		String data4 = CommonUtil.getParameter("DATA4", " ");
		String data5 = CommonUtil.getParameter("DATA5", " ");
		String data6 = CommonUtil.getParameter("DATA6", " ");
		String data7 = CommonUtil.getParameter("DATA7", " ");
		String data8 = CommonUtil.getParameter("DATA8", " ");
		String data9 = CommonUtil.getParameter("DATA9", " ");
		
		String toDay = DateUtil.getToday("yyyyMMddHHmmss");
		/*
		logger.info("rec : "+rec);
		logger.info("dn : "+dn);
		
		logger.info("data1 : ||"+data1+"||");
		logger.info("data2 : ||"+data2+"||");
		logger.info("data3 : ||"+data3+"||");
		logger.info("data4 : ||"+data4+"||");
		logger.info("data5 : ||"+data5+"||");
		logger.info("data6 : ||"+data6+"||");
		logger.info("data7 : ||"+data7+"||");
		logger.info("data8 : ||"+data8+"||");
		
		logger.info("toDay : "+toDay);
		*/
		if(!CommonUtil.hasText(rec) || !CommonUtil.hasText(dn)) 
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
		/*
		String systemIp = "192.168.0.21";
		int port = 8900;
		*/
		String systemIp = "127.0.0.1";
		int port = 5050;
		/*
		logger.info("systemIp : "+systemIp);
		logger.info("port : "+port);
		*/
		// UDP 통신 수신 전문
		ds = new DatagramSocket();
		
        // send data 설정
		InetAddress address = InetAddress.getByName(systemIp);
        /*
        	헤더|날짜	|내선번호|상담원ID|상담원명|전화번호|IN/OUT|	SVC1|SVC2|SVC3|CTI Ref (Key Code)|데이터1|데이터2|데이터3|데이터4|데이터5|데이터6|데이터7|데이터8|데이터9
		*/
		String header = rec+"|"+toDay+"|"+dn+"| | | | |01|KBI|00| |"+data1+"|"+data2+"|"+data3+"|"+data4+"|"+data5+"|"+data6+"|"+data7+"|"+data8+"|"+data9+"|";
		/*
		logger.info("address : "+address);
		logger.info("header : "+header);
		*/
		byte[] buf = header.getBytes();
		//byte[] buf = header.getBytes("UTF-8");
		
		// send
		DatagramPacket packet = new DatagramPacket(buf, buf.length, address, port);
		ds.send(packet);
		out.print("OK");
		//Site.writeJsonResult(out,true);

	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		//socket close
		if(ds != null)	ds.close();
	}
%>	