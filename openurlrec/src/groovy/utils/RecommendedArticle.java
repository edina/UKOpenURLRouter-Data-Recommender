package utils;

public class RecommendedArticle {
	private String url;
	private String title;
	private String date;
	private String authors;
	
	public RecommendedArticle(String url, String title, String date, String authors){
		this.url = url;
		this.title = title;
		this.date = date;
		this.authors = authors;
	}
	
	public void setUrl(String url){
		this.url = url;
	}
	
	public void setTitle(String title){
		this.title = title;
	}
	
	public void setDate(String date){
		this.date = date;
	}
	
	public void setAuthors(String authors){
		this.authors = authors;
	}
	
	public String getUrl(){
		return this.url;
	}
	
	public String getTitle(){
		return this.title;
	}
	
	public String getDate(){
		return this.date;
	}
	
	public String getAuthors(){
		return this.authors;
	}
}
