// add/remove a text string from an input box
function alter_text(category_name, text_input, link_ref) {
  var current_value = text_input.value;
  var link_element = document.getElementById(link_ref);
  if (current_value.indexOf(category_name) == -1) {
    current_value += " " + category_name;
    link_element.style.color = 'red';
  }
  else {
    var regExp = new RegExp("[ ]*" + category_name);
    current_value = current_value.replace(regExp, "");
    link_element.style.color = 'blue';
  }
  text_input.value = current_value;
}