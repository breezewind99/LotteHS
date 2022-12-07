<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.DatagramSocket" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="java.net.DatagramPacket" %>
<%@ page import="static com.cnet.crec.common.Finals.*" %>
<%@ include file="/common/common.jsp" %>
<%
	/* 소프트폰 Interface */
	//http://localhost:8080/app/sfp_interface.jsp?rec_mode=1&rec_datm=20220109&local_no=1111&rec_keycode=3333&store_code=1&mystery_code=2&customer_code=9999&ani=01098580428&user_id=1111
	//http://localhost:8080/app/sfp_interface.jsp?rec_mode=2&rec_datm=20220109&local_no=1111&rec_keycode=3333&store_code=1&mystery_code=2&customer_code=9999&ani=01098580428&user_id=1111

	//https://cs-rec.lotteimall.com/app/sfp_interface.jsp?rec_mode=1&rec_datm=20220109&local_no=19906&rec_keycode=3333&store_code=1&mystery_code=2&customer_code=9999&ani=01098580428&user_id=1111
	//https://cs-rec.lotteimall.com/app/sfp_interface.jsp?rec_mode=2&rec_datm=20220109&local_no=19906&rec_keycode=3333&store_code=1&mystery_code=2&customer_code=9999&ani=01098580428&user_id=1111

	DatagramSocket ds = null;
//	Db db = null;
	try
	{
		// get parameter
		String rec_mode = CommonUtil.getParameter("rec_mode");
		String rec_datm = CommonUtil.getParameter("rec_datm");
		String local_no = CommonUtil.getParameter("local_no");
		String rec_keycode = CommonUtil.getParameter("rec_keycode");
		String store_code = CommonUtil.getParameter("store_code");
		String mystery_code = CommonUtil.getParameter("mystery_code");
		String customer_code = CommonUtil.getParameter("customer_code");
		String ani = CommonUtil.getParameter("ani");
		String user_id = CommonUtil.getParameter("user_id");
		String DATA4 = CommonUtil.getParameter("DATA4");
		String DATA5 = CommonUtil.getParameter("DATA5");
		String DATA6 = CommonUtil.getParameter("DATA6");
		String DATA7 = CommonUtil.getParameter("DATA7");
		String DATA8 = CommonUtil.getParameter("DATA8");
		String DATA9 = CommonUtil.getParameter("DATA9");
		String DATA10 = CommonUtil.getParameter("DATA10");

		if(!CommonUtil.hasText(rec_datm)
				|| !CommonUtil.hasText(local_no)
				|| !CommonUtil.hasText(rec_keycode))
		{
			out.print("ERR_PARAM");
			return;
		}

//		db = new Db(true);
//		Map<String, Object> argMap = new HashMap<String, Object>();
//		//
//
//		argMap.clear();
//		argMap.put("rec_mode",rec_mode);
//		argMap.put("local_no",local_no);
//		argMap.put("cti_id"," ");
//		argMap.put("rec_keycode",rec_keycode);
//		argMap.put("rec_store_code",store_code);
//		argMap.put("rec_mystery_code",mystery_code);
//
//		int ins_cnt = db.insert("login.insertSoftphone",argMap);
//		logger.info("Insert Softphone Log : " + ins_cnt);

		logger.info("rec_mode : " + rec_mode);
		logger.info("rec_datm : " + rec_datm);
		logger.info("local_no : " + local_no);
		logger.info("rec_keycode : " + rec_keycode);
		logger.info("store_code : " + store_code);
		logger.info("mystery_code : " + mystery_code);
		logger.info("customer_code : " + customer_code);
		logger.info("ani : " + ani);
		logger.info("user_id : " + user_id);

		// UDP 통신 수신 전문
		ds = new DatagramSocket();

		// send data 설정
		InetAddress udp_main = InetAddress.getByName(UDP_MAIN);
		InetAddress udp_backup = InetAddress.getByName(UDP_BACKUP);
		InetAddress udp_image = InetAddress.getByName(UDP_IMAGE);
		String Mode = "";
		if(rec_mode.equals("1")) {
			Mode = "REC1";
		} else if (rec_mode.equals("3")){
			Mode = "REC2";
		} else {
			Mode = "REC3";
		}
        /*
        Linux용
         	헤더 |날짜	|내선번호 |상담원ID |상담원명|전화번호     |IN/OUT     |UUID|데이터1|데이터2|데이터3|데이터4|데이터5|데이터6|데이터7|데이터8|데이터9|데이터10
        	REC3|       |19906  |1111    |       |010985804   |          |2   |3     |4     |5     |6     |7     |8     |9     |10    |11    |12    |13|14|15|
		*/
		String msg;
		msg = String.format("%s| |%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|",
				Mode,
				local_no,
				(user_id.equals("") ? " " : user_id),
				" ",
				ani,
				" ",
				rec_keycode,
				(customer_code.equals("") ? " " : customer_code),
				(store_code.equals("") ? " " : store_code),
				(mystery_code.equals("") ? " " : mystery_code),
				(ani.equals("") ? " " : ani),
				(DATA5.equals("") ? " " : DATA5),
				(DATA6.equals("") ? " " : DATA6),
				(DATA7.equals("") ? " " : DATA7),
				(DATA8.equals("") ? " " : DATA8),
				(DATA9.equals("") ? " " : DATA9),
				(DATA10.equals("") ? " " : DATA10)
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
		if(ds != null)	ds.close();
//		if(db != null)	db.close();
	}
%>	