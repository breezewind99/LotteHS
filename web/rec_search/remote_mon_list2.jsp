<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="java.net.DatagramSocket"%>
<%@ page import="java.net.DatagramPacket"%>
<%@ page import="java.net.InetAddress"%>
<%@ page import="java.net.SocketTimeoutException"%>
<%
	if(!Site.isPmss(out,"mon_list","")) return;

	try 
	{
		CommonUtil.getRunTimeExec();
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	}
%>