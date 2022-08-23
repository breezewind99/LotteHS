<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.net.InetAddress"%>
<%@page import="java.net.DatagramPacket"%>
<%@page import="java.net.DatagramSocket"%>
<%@ include file="/common/common.jsp" %>
<%
	/* 소프트폰 로그인 */
	DatagramSocket ds = null;

	try
	{
		// get parameter
		String cti_id = CommonUtil.getParameter("cti_id");
		String local_no = CommonUtil.getParameter("local_no");

//		String toDay = DateUtil.getToday("yyyyMMddHHmmss");



		if(!CommonUtil.hasText(cti_id) || !CommonUtil.hasText(local_no))
		{
			out.print("ERR_PARAM");
			return;
		}

		logger.info("cti_id : " + cti_id);
		logger.info("local_no : " + local_no);

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
		String header = cti_id+"|"+local_no+"|";

		logger.info("address : "+address);
		logger.info("header : "+header);
		/*
		 */
		byte[] buf = header.getBytes();
		//byte[] buf = header.getBytes("UTF-8");

		// send
		DatagramPacket packet = new DatagramPacket(buf, buf.length, address, port);
		ds.send(packet);
		out.print("OK");
		//Site.writeJsonResult(out,true);

	}
	catch(Exception e)
	{
		logger.error(e.getMessage());
		out.print(e.getMessage());
	}
	finally
	{
		//socket close
		if(ds != null)	ds.close();
	}
%>	