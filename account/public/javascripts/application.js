
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
