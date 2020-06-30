// Global Variable
let inspector = document.getElementById("inspect");
let overlay = document.getElementById("inspect-overlay");

// Enable Mini Inspect Element
function inspect_on() {
    document.onmousemove = function(e){
        elem = getInnermostHovered();
        pos = elem.getBoundingClientRect();
    
        overlay.style.width = pos["width"].toString() + "px";
        overlay.style.height = pos["height"].toString() + "px";
        overlay.style.top = pos["top"].toString() + "px";
        overlay.style.left = pos["left"].toString() + "px";
        overlay.style.display = "block";
    
        content = elem.outerHTML.toString()
        inspector.innerText = content.substr(0,content.indexOf(">")+1);
    
        inspector.style.display = "inline-block";
        inspector.style.top = e.clientY + 12 + "px";
        inspector.style.left = e.clientX + 10 + "px";
    }
}

// Disable Mini Inspect Element
function inspect_off() {
    overlay.style.display = "none";
    inspector.style.display = "none";
    document.onmousemove = null;
}

// Get element under mouse pointer
// Modified from https://stackoverflow.com/questions/24538450
function getInnermostHovered() {
    var n = document.querySelector(":hover");
    var nn;
    while (n) {
        nn = n;
        n = nn.querySelector(":hover");
    }
    return nn;
}

// Toggle Inspection
function toggleInspection(){
    if (document.onmousemove) {inspect_off();}
    else {inspect_on();}
}