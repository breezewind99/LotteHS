<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="com.cnet.crec.util.CommonUtil"%>
<%@ page import="com.cnet.crec.util.DateUtil"%>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%@ page import="java.net.DatagramSocket"%>
<%@ page import="java.net.DatagramPacket"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="java.net.SocketTimeoutException"%>
<%@ page import="java.io.*"%>
<%!
public static void UDPSocketApp(String ip, int port, String data) {
	try {
		InetAddress is = InetAddress.getByName(ip);
		DatagramSocket ds = new DatagramSocket(port);
		
		byte[] buffer = data.getBytes();
		
		DatagramPacket dp = new DatagramPacket(buffer, buffer.length, is, port);
		
		ds.send(dp);
		
		ds.close();
	} catch(IOException ioe) {
		ioe.printStackTrace();
	}
}
%>