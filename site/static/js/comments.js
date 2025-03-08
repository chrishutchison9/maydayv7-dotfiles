var buttons = document.getElementsByClassName("comments-collapsible");
for (var i = 0; i < buttons.length; i++) {
  buttons[i].addEventListener("click", function () {
    this.classList.toggle("active");
    var content = this.nextElementSibling;
    if (content.style.maxHeight) {
      content.style.maxHeight = null;
      this.innerHTML = "Show Comments";
    } else {
      content.style.maxHeight = content.scrollHeight + "px";
      this.innerHTML = "Hide Comments";
    }
  });
}
