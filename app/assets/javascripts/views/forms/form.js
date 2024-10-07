document.addEventListener("DOMContentLoaded", function () {
  var form = document.querySelector("form");
  var prefix = 'reducer';
  var is_reducer_form = false
  if(form){
    is_reducer_form = form.id.includes(prefix);
  }


  var toggle_input = function(value){
    var is_subject = value.includes('subject');
    var hidden_input_id = is_subject ? 'user_reducer_keys' : 'subject_reducer_keys';
    var visible_input_id = hidden_input_id.includes('user_reducer_keys') ?  'subject_reducer_keys' : 'user_reducer_keys';

    var hidden_input = document.getElementById(hidden_input_id);

    if(hidden_input){
        hidden_input.classList.remove('hidden');
    }

    var visible_input = document.getElementById(visible_input_id);
    if(visible_input){
        visible_input.classList.add('hidden');
    }
  };

  if (is_reducer_form) {
    var reducer_topic = document.getElementById("reducer_topic");

    toggle_input(reducer_topic.value);

    reducer_topic.addEventListener("change", function (e) {
      toggle_input(e.target.value);
    });
  }
});
