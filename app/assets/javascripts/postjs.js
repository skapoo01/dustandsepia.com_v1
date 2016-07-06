$(document).ready(function(){
    var preview = $(".cover_image_preview img");

    $("#cover_image_uploader").change(function(event){
       var input = $(event.currentTarget);
       var file = input[0].files[0];
       var reader = new FileReader();
       var ht = preview.attr("height");
       var wd = preview.attr("width");
       reader.onload = function(e){
           image_base64 = e.target.result;
           preview.attr("src", image_base64);
           preview.attr("width", $(".cover_image_preview").width());
           preview.attr("height", ($(".cover_image_preview").width() / wd) * ht);
       };
       reader.readAsDataURL(file);
    });
});

// problem w/ img dimensions for horz longer images, width not capped at 300
// attach img, then no file chosen, img still displays in preview
// how to do a remove attachment button