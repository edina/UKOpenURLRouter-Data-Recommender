<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head><meta content="text/html; charset=utf-8" http-equiv="content-type"></meta>

<meta content="openurl, openurl router, openurl router data, recommender, prototype recommender" name="Keywords"></meta>
<meta content="A prototype article recommender developed based on the OpenURL Router Data - Home Page" name="Description"></meta>

<script src="/js/ie.js" type="text/javascript"></script>


<title>OpenURL Router Data Recommender Prototype</title>
<link rel="stylesheet" href="/css/openurlrec.css" />
</head>
<body>
<div id="container">
<div id="header"></div>
<div id="content">
<div id="text">
<p>This web page has been developed as part of the JISC-funded <a href="http://edina.ac.uk/projects/Using_OpenURL_Activity_data_summary.html">Using OpenURL Activity Data Project</a>. This is a <strong>prototype article recommender</strong> that was developed based on the <a href="http://openurl.ac.uk/doc/data/data.html">OpenURL Router Data</a>. This page will be made available for a limited time following completion of the project.</p>
<p>The drop-down below contains a list of 100 articles that were requested between April - June 2011 and logged in the OpenURL Router Data to demonstrate that OpenURL Data can be used to make recommendations. The recommendations are based on other articles that were requested during the same user session, i.e. someone who looked at the article in the drop-down list also looked at one of the articles shown in the list below. Please select an article from the drop-down and click 'Get Recommendations' to see a demonstration of this.</p>
<p>Note: a significant amount of analysis was performed to determine what constituted a user session and how to group requests into sessions. Further details of this and the project, including the work to release the OpenURL Router Data, can be found in Using OpenURL Activity Data - Final Report (coming soon).</p>
</div>


<g:form action="index">
	<div>
	<g:select onmousedown="javascript:if(isIE7()){this.style.position='absolute';this.style.width='auto'}" onchange="javascript:if(isIE7()){this.style.position=''; this.style.width=''}" id="articleselect" name="article" from="${dropdownList}" optionKey="id" optionValue="value" noSelection="['':'- Select an article -']"/>
	</div>
	<div>
	<input type="submit" name="submit" value="Get Recommendations" />
	</div>
</g:form>

<div id="recommendations">
	<g:if test="${(reqArticle != null)}">
	<div id="requestedarticle">
		<h2>You selected article:</h2>
		<ul><li>
		<a href="${reqArticle.url}">${reqArticle.title}</a>
		</li></ul>		
		<div class="artmeta">${reqArticle.date}
			<g:if test="${!(reqArticle.title.equals(''))}">
				<g:if test="${!(reqArticle.authors.equals('')) }">
					-
				</g:if>
			</g:if>
			${reqArticle.authors}
		</div>
	</div>
	<h2>Users interested in this article also indicated an interest in the following:</h2>
	<ul>
	</g:if>	
		<g:each var="recommendeditem" in="${recommendations}">
			<li>
				<a href="${recommendeditem.url}">${recommendeditem.title}</a>
				<div class="artmeta">${recommendeditem.date}
				<g:if test="${!(recommendeditem.title.equals(''))}">
					<g:if test="${!(recommendeditem.authors.equals('')) }">
						-
					</g:if>
				</g:if>
					${recommendeditem.authors}</div>
			</li>
		</g:each>
	<g:if test="${(reqArticle != null)}">
	</ul>
	</g:if>
</div>

</div>

<div id="footer">
<p>This is a recommendation prototype based on OpenURL Router data. Please see the <a href="http://edina.ac.uk/projects/Using_OpenURL_Activity_data_summary.html">project page</a> for more information.<br/>Images copyright iStockphoto 2011</p> 
<div id="footerlogos">
	<a href="http://www.jisc.ac.uk"><img src="/images/jisclogo.gif" alt="jisc"/></a>
	<a href="http://edina.ac.uk"><img src="/images/edinalogo.gif" alt="edina"/></a>
</div>



</div>
</div>
</body>

</html>