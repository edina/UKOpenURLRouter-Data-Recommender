function getIEVersionNumber() {
    var ua = navigator.userAgent;
    var MSIEOffset = ua.indexOf("MSIE ");
    
    if (MSIEOffset == -1) {
        return 0;
    } else {
        return parseFloat(ua.substring(MSIEOffset + 5, ua.indexOf(";", MSIEOffset)));
    }
}

function isIE7(){
	if(navigator.appName=="Microsoft Internet Explorer" && getIEVersionNumber() < 8){
		return true;
	}else{		
		return false;
	}
	
}