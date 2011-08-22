package utils;

public class DropdownItem {
	private String id;
	private String value;
	
	public DropdownItem(String id, String value){
		this.id = id;
		this.value = value;
	}
	
	public String getId(){
		return this.id;
	}
	
	public String getValue(){
		return this.value;
	}
	
	public void setId(String id){
		this.id = id;
	}
	
	public void setValue(String value){
		this.value = value;
	}
}
