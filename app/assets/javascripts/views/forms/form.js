document.addEventListener("DOMContentLoaded", function () {
  const form = document.querySelector("form");
  const prefix = 'reducer';
  const is_reducer_form = form?.id.includes(prefix);
  
  const toggle_input = function(value){
    const is_subject = value.includes('subject');
    let hidden_input_id = is_subject ? 'user_reducer_keys' : 'subject_reducer_keys';
    let visible_input_id = hidden_input_id.includes('user_reducer_keys') ?  'subject_reducer_keys' : 'user_reducer_keys';

    document.getElementById(hidden_input_id)?.classList.remove('hidden');

    document.getElementById(visible_input_id)?.classList.add('hidden');
  }

  if (is_reducer_form) {
    const reducer_topic = document.getElementById("reducer_topic");

    toggle_input(reducer_topic.value);

    reducer_topic.addEventListener("change", function (e) {
      toggle_input(e.target.value);
    });
  }
});
