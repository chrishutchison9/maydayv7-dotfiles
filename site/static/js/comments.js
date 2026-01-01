var buttons = document.getElementsByClassName("comments-collapsible");
for (var i = 0; i < buttons.length; i++) {
  buttons[i].addEventListener("click", function () {
    this.classList.toggle("active");
    var content = this.nextElementSibling;
    if (content.style.maxHeight) {
      // Closing
      content.style.maxHeight = content.scrollHeight + "px";
      void content.offsetHeight;
      content.style.maxHeight = null;
      this.innerHTML = "Show Comments";
    } else {
      // Opening
      content.style.maxHeight = content.scrollHeight + "px";
      this.innerHTML = "Hide Comments";
      setTimeout(() => {
        if (content.style.maxHeight) content.style.maxHeight = "none";
      }, 200);
    }
  });
}
