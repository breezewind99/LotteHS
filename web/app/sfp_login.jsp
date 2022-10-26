<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.net.InetAddress"%>
<%@page import="java.net.DatagramPacket"%>
<%@page import="java.net.DatagramSocket"%>
<%@ page import="static com.cnet.crec.common.Finals.*" %>
<%@ include file="/common/common.jsp" %>
<%
	/* 소프트폰 로그인 */
	DatagramSocket ds = null;
	Db db = null;
	//http://localhost:8080/app/sfp_login.jsp?cti_id=29906&local_no=19906
	//https://cs-rec.lotteimall.com/app/sfp_login.jsp?cti_id=29906&local_no=19906
	try
	{
		// get parameter
		String cti_id = CommonUtil.getParameter("cti_id");
		String local_no = CommonUtil.getParameter("local_no");

		if(!CommonUtil.hasText(cti_id) || !CommonUtil.hasText(local_no))
		{
			out.print("ERR_PARAM");
			return;
		}

		logger.info("cti_id : " + cti_id);
		logger.info("local_no : " + local_no);


		db = new Db(true);
		Map<String, Object> argMap = new HashMap<String, Object>();
		//
		argMap.clear();
		argMap.put("rec_mode","0");
		argMap.put("local_no",local_no);
		argMap.put("cti_id",cti_id);
		argMap.put("rec_keycode"," ");
		argMap.put("rec_store_code"," ");
		argMap.put("rec_mystery_code"," ");

		int ins_cnt = db.update("login.updateClearLocalno", argMap);
		logger.info("update Clear local no " + ins_cnt);

		ins_cnt = db.insert("login.insertSoftphone",argMap);
		logger.info("Insert Softphone Log : " + ins_cnt);

		ins_cnt = db.update("login.updateLocalno", argMap);
		logger.info("update local no " + ins_cnt);

		// UDP 통신 수신 전문
		ds = new DatagramSocket();

		// send data 설정
		InetAddress udp_main = InetAddress.getByName(UDP_MAIN);
		InetAddress udp_backup = InetAddress.getByName(UDP_BACKUP);
		InetAddress udp_image = InetAddress.getByName(UDP_IMAGE);
		String Mode = "";

		Mode = "REC0";


		String msg;
		msg = String.format("%s| |%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|", Mode, local_no, (cti_id.equals("") ? " " : cti_id), " ", " ", " ", " ",
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " "),
				("".equals("") ? " " : " ")
		);

		logger.info("main_address : "+udp_main);
		logger.info("backup_address : "+udp_backup);
		logger.info("msg : "+msg);

		byte[] buf = msg.getBytes();

		// send
		DatagramPacket packet_main = new DatagramPacket(buf, buf.length, udp_main, UDP_PORT);
		ds.send(packet_main);
		DatagramPacket packet_backup = new DatagramPacket(buf, buf.length, udp_backup, UDP_PORT);
		ds.send(packet_backup);
		DatagramPacket packet_image = new DatagramPacket(buf, buf.length, udp_image, UDP_PORT_IMAGE);
		ds.send(packet_image);
		out.print("OK");
	}
	catch (NullPointerException ne) {
		logger.error(ne.getMessage());
	}
	catch(Exception e) {
		logger.error(e.getMessage());
	}
	finally	{
		//socket close
		if(ds != null)	ds.close();
		if(db != null)	db.close();
	}
%>	