// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function get_window_height() {
  var myWidth = 0, myHeight = 0;
  if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  return myHeight;  
}

function setSize(dom_id) {
  var window_height = get_window_height() * 0.75;
  var iframeElement = parent.document.getElementById(dom_id); 
  iframeElement.style.height = window_height + "px"; //100px or 100% 
  iframeElement.style.width = "98%"; //100px or 100%
}

YAHOO.util.Event.onContentReady("mainmenubar", function () {

    /*
         Instantiate a MenuBar:  The first argument passed to the 
         constructor is the id of the element in the page 
         representing the MenuBar; the second is an object literal 
         of configuration properties.
    */
    var oMenuBar = new YAHOO.widget.MenuBar("mainmenubar", { 
                                                autosubmenudisplay: true, 
                                                hidedelay: 750, 
                                                lazyload: true });
    oMenuBar.render();

    shutdownPanel = new YAHOO.widget.Panel("shutdown", {
      width:"400px", 
      fixedcenter: true, 
      constraintoviewport: true, 
      underlay:"shadow",
      modal:true, 
      close:true, 
      visible:false, 
      draggable:false} );
    shutdownPanel.setHeader("Shutdown or Reboot");
    shutdownPanel.setFooter("The system will stop responding after shutdown and during reboot");
    shutdownPanel.render();
    YAHOO.util.Event.addListener("shutdownLink", "click", shutdownPanel.show, shutdownPanel, true);

    var oSubmitButton1 = new YAHOO.widget.Button("save", { value: "save" });
});

YAHOO.util.Event.onContentReady("content", function () {
  var oSubmitButton0 = new YAHOO.widget.Button("submit", { value: "submit" });
});

function password_strength(password) {
  var desc = new Array();
  desc[0] = "Invalid";
  desc[1] = "Weak";
  desc[2] = "Better";
  desc[3] = "Medium";
  desc[4] = "Strong";
  desc[5] = "Strongest";

  var points = 0;

  //---- if password is bigger than 4 , give 1 point.
  if (password.length > 5) points++;

  //---- if password has both lowercase and uppercase characters , give 1 point.  
  if ( ( password.match(/[a-z]/) ) && ( password.match(/[A-Z]/) ) ) points++;

  //---- if password has at least one number , give 1 point.
  if (password.match(/\d+/)) points++;

  //---- if password has at least one special caracther , give 1 point.
  if ( password.match(/.[!,@,#,$,%,^,&,*,?,_,~,-,(,)]/) ) points++;

  //---- if password is bigger than 12 ,  give 1 point.
  if (password.length > 10) points++;

  //---- Showing  description for password strength.
  if (password.length < 1) {
    document.getElementById("password_description").innerHTML = "";
    document.getElementById("password_strength").className = "strength0";
  }

  if ((password.length > 0) && (password.length < 6)) {
    document.getElementById("password_description").innerHTML = "Invalid";
    document.getElementById("password_strength").className = "strength0";
  }

  if (password.length > 5) {
    document.getElementById("password_description").innerHTML = desc[points];
    document.getElementById("password_strength").className = "strength" + points;
  }
}

function moveOption( fromID, toID, idx ) {
  if (isNaN(parseInt(idx))) {
    var i = document.getElementById( fromID ).selectedIndex;
  } else {
    var i = idx;
  }

  var o = document.getElementById( fromID ).options[ i ];
  var theOpt = new Option( o.text, o.value, false, false );
  document.getElementById( toID ).options[document.getElementById( toID ).options.length] = theOpt;
  document.getElementById( fromID ).options[ i ] = null;
}
function moveOptions( fromID, toID ) {
  for (var x = document.getElementById( fromID ).options.length - 1; x >= 0 ; x--) {
    if (document.getElementById( fromID ).options[x].selected == true) {
      moveOption( fromID, toID, x );
    }
  }
}
function selectAllOptions(selStr) {
  var selObj = document.getElementById(selStr);
  for (var i=0; i<selObj.options.length; i++) {
    selObj.options[i].selected = true;
  }
}
