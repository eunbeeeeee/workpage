<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, javax.sql.*, javax.naming.*" %>
<!-- 
	=> 현재 페이지 번호
	1. 전체 컬럼의 갯수 300
	2. 한 화면에 보여줄 페이지 수 10
	3. 현재 리스트 번호
	4. 한번에 보여줄 리스트 번호 maxlist (15)
	
	예) 현재 페이지 번호 없거나 page = 2
		minlist = ((page-1) * maxlist)
		limit minlist, maxlist
 -->
<%!

	int listNum = 12;
	int PageNum = 15;	
	PreparedStatement pstmt = null;
	Statement stmt = null;
	ResultSet rs = null, row = null;
	String sql= null, query =null;
	int maxColumn = 0;
	
	DataSource ds;
	public void jsInit(){
		try{
			Context initCnt = new InitialContext();
			Context env = (Context) initCnt.lookup("java:comp/env");
			ds = (DataSource) env.lookup("jdbc/mywork");
		}catch(Exception e){
			e.printStackTrace();
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
	table{
		width: 900px;
		border-collapse: collapse;
		margin: auto;
		color: #888;
	}
	table, td, th{
		border: 1px solid lightpink;
		color: #888;
	}
	th, td{
		padding: 15px;
		white-space: nowrap;
	}
	th{
		background: pink;
	}
	.page{
		width: 900px;
		margin: 15px auto;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}
	.page a{
		border-radius:50%;
		border: 1px solid pink;
		text-decoration: none;
		color: #fff;
		font-size: 14px;
		display:inline-block;
		width: 25px;
		height: 25px;
		text-align: center;
		line-height: 29px;
		transtion:all 300ms;
		background-color: pink;
		
	}
	.page a.etc{
		border-radius: 5px;
		width: 45px;
	}
	.page a.act:active,
	.page a:hover{
		background: #ddd;
	}
</style>
</head>
<body>
<%
	jsInit();
	java.sql.Connection conn = ds.getConnection();
	String pg = request.getParameter("page");
	int mypg = 1;
	try{
		mypg = Integer.parseInt(pg);
		if(mypg < 1){
			mypg = 1;
		}
	}catch(Exception e){
		mypg = 1;
	}
	int limitNum = (mypg-1)*listNum;
	
	query = "select count(*) from best_restaurant";
	stmt = conn.createStatement();
	row = stmt.executeQuery(query);
	if(row.next()){
		maxColumn = row.getInt(1);
	}
	
	sql = "select * from best_restaurant order by num desc limit ?, ?";
	try{
		pstmt = conn.prepareStatement(sql);
		pstmt.setInt(1, limitNum);
		pstmt.setInt(2, listNum);
		rs = pstmt.executeQuery();
%>
<p>전체 게시물  : <%= maxColumn%></p>
<table>
<colgroup>
	<col width="5%">
	<col width="25%">
	<col width="45%">
	<col width="30%">
</colgroup>
	<tr>
		<th>번호</th>
		<th>상점이름</th>
		<th>종류 </th>
		<th>전화번호 </th>
	</tr>

<%
		while(rs.next()){
%>
		<tr>
			<td>
				<%= rs.getInt("num") %>
			</td>
			<td>
				<%= rs.getString("title") %>
			</td>
			<td>
				<%= rs.getString("sectors") %>(<%=rs.getString("sectordetail") %>)
			</td>
			<td>
				<%= rs.getString("tel") %>
			</td>
		</tr>
<%
		}
%>
	</table>
<%
	}catch(SQLException e){
		out.print("DB연결에 실패했습니다.");
	}finally{
		if(rs != null) rs.close();
		if(pstmt != null) pstmt.close();
		if(conn != null) conn.close();
	}
%>
<%
	//전체 페이지 수 = 전체 데이터 수 /페이지당 목록 수   13/12 올림 Math.ceil
	int totalPage = (int)Math.ceil( maxColumn / (double)listNum);

	//전체 블럭수 = 전페ㅠㅔ이지 /블럭당 보여줄 페이지 수 
	int totalBlock = (int)Math.ceil(totalPage/ (double)PageNum);
	
	//현재 블럭 번호 = 현재 ㅠㅔ이지 번호/블럭 당 페이지 수 
	int nowBlock = (int)Math.ceil(mypg /(double)PageNum);
	//블럭당 시작페이지 번호 = (현재 블럭 번호 -1 ) * 블럭 당 페이지 수  + 1
	int sPageNum = (nowBlock - 1)*PageNum + 1;	
	
	//블록 당 마지막 페이지번호 = 현재 블럭번호 * 블럭당 페이지 수 
	int ePageNum = nowBlock * PageNum;
	if(ePageNum > totalPage){ePageNum = totalPage;}
	
%>

	전체 페이지 수 : <%=totalPage%>
	전체 블럭 수 : <%=totalBlock%>
	전체 블럭 번 : <%=nowBlock%>	
	
<div class="page">
		
		<%
			//이전  페이지 출력 
			if(sPageNum <= 1){
				out.print("<a href=\"?page=1\" class=\"etc\">이전</a>");
			}else{
				int prevPage = sPageNum -1;
				out.print("<a href=\"?page="+prevPage+"\" class=etc>이전 </a>");
			}
			
			//페이지 출력
			for(int i = sPageNum; i<= ePageNum; i++){
				String active = "";	
				if(mypg == i){
					active = "active";
				}
				out.print("<a href=\"?page="+i+"\" class="+active+">"+i+"</a>");
			}
			//다음페이지 출력 
			if(ePageNum >= totalPage){
				out.print("<a href=\"?page="+totalPage+"\" class=\"etc\">다음 </a>");
			}else{
				int nextPage = ePageNum + 1;
				out.print("<a href=\"?page="+nextPage+"\" class=etc>다음  </a>");
			}
		%>
</div>


</html>