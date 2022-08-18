<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%

	Db db = null;

	try {
		db = new Db(true);

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("business_code", _BUSINESS_CODE);
		
		// 사용자 권한에 따른 조직도 조회
		argMap.put("_user_level", _LOGIN_LEVEL);
		argMap.put("_bpart_code",_BPART_CODE);
		argMap.put("_mpart_code",_MPART_CODE);
		argMap.put("_spart_code",_SPART_CODE);
		argMap.put("_default_code",_PART_DEFAULT_CODE);
		
		//녹음중(rs), RTP누락(rp), Onway(ow), 전화기 IP 비매칭(tp), 장시간 미녹취(rl), 대기중(rw)  
		int rs_cnt = 0, rp_cnt = 0, ow_cnt = 0
			,tp_cnt = 0, rl_cnt = 0, rw_cnt = 0;
		
		// 채널 모니터링 상태 별 건수
		Map<String, Object> cntmap  = db.selectOne("dashboard.selectRecStateCount", argMap);
		rs_cnt = ((Integer)cntmap.get("rs_cnt")).intValue();
		rp_cnt = ((Integer)cntmap.get("rp_cnt")).intValue();
		ow_cnt = ((Integer)cntmap.get("ow_cnt")).intValue();
		tp_cnt = ((Integer)cntmap.get("tp_cnt")).intValue();
		rl_cnt = ((Integer)cntmap.get("rl_cnt")).intValue();
		rw_cnt = ((Integer)cntmap.get("rw_cnt")).intValue();
		
		// 채널 모니터링 조회
		List<Map<String, Object>> list = db.selectList("dashboard.selectChannelList", argMap);
%>
<form id="frm" name="frm">
	<div class="cont_middle clearfix">
		<div class="nav">
			<img class="chimage" src="../img/icon/CH_RS.png"/> 녹취중  <span>[<%=rs_cnt%>건]</span> &nbsp;&nbsp;
			<img class="chimage" src="../img/icon/CH_RW.png"/> 대기중  <span>[<%=rw_cnt%>건]</span> &nbsp;&nbsp;
			<img class="chimage" src="../img/icon/CH_RP.png"/> 오류(RTP누락) <span>[<%=rp_cnt%>건]</span> &nbsp;&nbsp;
			<img class="chimage" src="../img/icon/CH_IW.png"/> 오류(Oneway) <span>[<%=ow_cnt%>건]</span> &nbsp;&nbsp;
			<img class="chimage" src="../img/icon/CH_RL.png"/> 장시간 미녹취 <span>[<%=rl_cnt%>건]</span> &nbsp;&nbsp;
			<img class="chimage" src="../img/icon/CH_TP.png"/> 전화기 비매칭 <span>[<%=tp_cnt%>건]</span> &nbsp;&nbsp;
		</div>
	</div>
	<div class="cont_cont">
		<ul class="chl_list list-inline">
<%
		// 채널 모니터링
		for(Map<String, Object> item : list) 
		{
			
			String state = item.get("state").toString();
			String ch_state = item.get("ch_state").toString();
			String channel = item.get("channel").toString();	//channel 제거 요청 - CJM(20180817)
			String phone = item.get("phone").toString();
%>
				<li>
					<div class="chl_img">
						<div class="svr_ch">&nbsp;</div>
						<img src="../img/icon/CH_<%=ch_state%>.png"/>
						<div class="svr_ch"><%=phone%></div>
					</div>
				</li>
<%		
		}
%>
		</ul>

		<div class="clearfix"></div>
	</div>
</form>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>