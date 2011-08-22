package recommenderprototype

import java.sql.*;
import java.util.HashMap;
import java.net.URI;
import java.net.URL;

import org.apache.commons.lang.StringUtils;

import utils.DropdownItem
import utils.RecommendedArticle

class IndexController {
	ArrayList<DropdownItem> dropdownList;
	ArrayList<RecommendedArticle> recommendations;
	RecommendedArticle reqArticle;	

    String username = "yourDBuser";
    String passwd = "yourDBpassword";
    String url = "jdbc:mysql://127.0.0.1:3306/openurlrec";
  
	Connection conn = null;
	
	def index = {				
		String articleID = params.article;
		
		try{
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			conn = DriverManager.getConnection(url, username, passwd);
			//System.out.println("-------- Database connection established! --------");
			Statement s = conn.createStatement ();
			s.executeQuery("SELECT * from (SELECT * FROM aweights ORDER BY weight DESC LIMIT 100) AS t1 ORDER BY atitle;");
			ResultSet rs = s.getResultSet();
			String aTitle="";
			String aID;
			dropdownList = new ArrayList<DropdownItem>();
			
			while(rs.next()){
				aTitle = rs.getString("atitle");
				aID = rs.getString("artid");
				dropdownList.add(new DropdownItem(aID, aTitle));				
			}
						
		}catch(Exception E){
			System.err.println("Cannot connect to database server '"+url+"', username: "+username);
			E.printStackTrace();
		}finally{
			if(conn != null){
				try{
					conn.close();
					//System.out.println("--Database connection terminated--");
				}catch(Exception e){
					e.printStackTrace();
				}
			}
		}						
				
		// get recommendations
		if(articleID != null){			
			recommendations = new ArrayList<RecommendedArticle>();
						
			if(articleID != ""){
				try{
					Class.forName("com.mysql.jdbc.Driver").newInstance();
					conn = DriverManager.getConnection(url, username, passwd);
					Statement s = conn.createStatement ();
					String auLast="", au="", aTitle="", jTitle="", date="", vol="", issue="", sPage="";
					String issn="", eIssn="", isbn="", doi="", genre="", urlString="";
					URI uri;
					URL urlStr;					
					
					//first get the article that the user has selected and display it
					s.executeQuery("SELECT * FROM articles WHERE id='"+articleID+"'");
					ResultSet rs = s.getResultSet();
					
					while(rs.next()){
						auLast = rs.getString("aulast");
						au = rs.getString("au");
						aTitle = rs.getString("atitle");
						jTitle = rs.getString("jtitle");
						date = rs.getString("adate");
						vol = rs.getString("vol");
						issue = rs.getString("issue");
						sPage = rs.getString("spage");
						issn = rs.getString("issn");
						eIssn = rs.getString("eissn");
						isbn = rs.getString("isbn");
						doi = rs.getString("doi");
						genre = rs.getString("genre");
						uri = new URI("http", null, "//openurl.ac.uk", "", "rft.aulast="+auLast+"&rft.au="+au+"&rft.atitle="+aTitle+"&rft.jtitle="+jTitle+"&date="+date+"&volume="+vol+"&issue="+issue+"&spage="+sPage+"&issn="+issn+"&eissn="+eIssn+"&isbn="+isbn+"&doi="+doi+"&genre="+genre);
						urlStr = uri.toURL();
						urlString = urlStr.toString();
						
						urlString = urlString.substring(0, 21)+urlString.substring(22, urlString.length());
						
						// authors come back in the format: Dinsdale, DDyer, MCohen, G
						// and we want to display them in: Dinsdale D.; Dyer M.; Cohen G.
						if(au.length()>0){
							//System.out.println(au);
							au = au.trim();
							
							if(StringUtils.countMatches(au, ",") > 1){
								String[] authors = au.split(",");
								String tempStr;
								
								au = authors[0].trim();
								
								for(int i=1;i<authors.length-1;i++){
									tempStr = authors[i].trim();
									//System.out.println(tempStr);
									au += " "+tempStr.substring(0, 1)+".; "+tempStr.substring(1, tempStr.length());
								}
								au += authors[authors.length-1];
							}else{
								au = au.replaceAll(",", "");
							}
							au += ".";
							//System.out.println(au);
							//System.out.println("-------------------------");
						}
						// we now have the requested article
						reqArticle = new RecommendedArticle(urlString, aTitle, date.subSequence(0, 4), au);						
					}
					
					
					// now get the recommendations
					s.executeQuery("SELECT aSameSession.aulast, aSameSession.au, aSameSession.atitle, aSameSession.jtitle, aSameSession.adate, aSameSession.vol, aSameSession.issue, aSameSession.spage, aSameSession.issn, aSameSession.eissn, aSameSession.isbn, aSameSession.doi, aSameSession.genre, count(*) As Weight FROM articles a INNER JOIN sessions s ON a.id = s.artid INNER JOIN sessions sSameArticle ON sSameArticle.sessionid = s.sessionid INNER JOIN articles aSameSession ON sSameArticle.artid = aSameSession.id WHERE a.id = '"+articleID+"' AND aSameSession.id <> '"+articleID+"' GROUP BY aSameSession.id ORDER BY Weight DESC");
					rs = s.getResultSet();					
					
					while(rs.next()){
						auLast = rs.getString("aulast");
						au = rs.getString("au");
						aTitle = rs.getString("atitle");
						jTitle = rs.getString("jtitle");
						date = rs.getString("adate");
						vol = rs.getString("vol");
						issue = rs.getString("issue");
						sPage = rs.getString("spage");
						issn = rs.getString("issn");
						eIssn = rs.getString("eissn");
						isbn = rs.getString("isbn");
						doi = rs.getString("doi");
						genre = rs.getString("genre");
						uri = new URI("http", null, "//openurl.ac.uk", "", "rft.aulast="+auLast+"&rft.au="+au+"&rft.atitle="+aTitle+"&rft.jtitle="+jTitle+"&date="+date+"&volume="+vol+"&issue="+issue+"&spage="+sPage+"&issn="+issn+"&eissn="+eIssn+"&isbn="+isbn+"&doi="+doi+"&genre="+genre);
						urlStr = uri.toURL();
						urlString = urlStr.toString();
						
						urlString = urlString.substring(0, 21)+urlString.substring(22, urlString.length());
						
						// authors come back in the format: Dinsdale, DDyer, MCohen, G
						// and we want to display them in: Dinsdale D.; Dyer M.; Cohen G.
						if(au.length()>0){
							//System.out.println(au);
							au = au.trim();
							
							if(StringUtils.countMatches(au, ",") > 1){
								String[] authors = au.split(",");							
								String tempStr;
								
								au = authors[0].trim();
								
								for(int i=1;i<authors.length-1;i++){					
									tempStr = authors[i].trim();
									//System.out.println(tempStr);
									au += " "+tempStr.substring(0, 1)+".; "+tempStr.substring(1, tempStr.length()); 									
								}
								au += authors[authors.length-1];								
							}else{
								au = au.replaceAll(",", "");
							}
							au += ".";
						}else{
							au = auLast;
						}						
						
						recommendations.add(new RecommendedArticle(urlString, aTitle, date.subSequence(0, 4), au));						
					}
				}catch(Exception E){
					System.err.println("Could not get recommendations. Connect to database server '"+url+"', username: '"+username+"', looking for id: '"+articleID+"'");
				}finally{
					if(conn != null){
						try{
							conn.close();							
						}catch(Exception e){
							System.err.println("Could not close connection to database server '"+url+"', username: '"+username)
						}
					}
				}
			}else{
				//System.out.println("no article selected");
			}
			
		}
	}
	
	
	
	
}
