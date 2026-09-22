// Caesar Rule Builder — embedded version for Rails asset pipeline
// Adapted from https://github.com/zooniverse/caesar-rules-ui
// Zero dependencies beyond the DOM. Renders into a mount point, syncs JSON to a hidden field.

(function(window) {
  'use strict';

  var CONNECTIVES = [
    { type: 'and',  type2: 'conjunction',  js: '&&' },
    { type: 'or',   type2: 'conjunction',  js: '||' },
    { type: 'lt',   type2: 'comparator',   js: '<' },
    { type: 'gt',   type2: 'comparator',   js: '>' },
    { type: 'lte',  type2: 'comparator',   js: '<=' },
    { type: 'gte',  type2: 'comparator',   js: '>=' },
    { type: 'eq',   type2: 'comparator',   js: '==' }
  ];

  var DROPDOWN_ITEMS = CONNECTIVES.filter(function(c) {
    return c.type2 === 'comparator' || c.type2 === 'conjunction';
  });

  // --- DOM helpers ---

  function el(tag, attrs) {
    var e = document.createElement(tag);
    var children = Array.prototype.slice.call(arguments, 2);
    if (typeof attrs === 'string') { e.textContent = attrs; return e; }
    if (attrs) {
      var keys = Object.keys(attrs);
      for (var i = 0; i < keys.length; i++) {
        var k = keys[i], v = attrs[k];
        if (k === 'class') e.className = v;
        else if (k.startsWith('on')) e.addEventListener(k.slice(2), v);
        else e.setAttribute(k, v);
      }
    }
    for (var j = 0; j < children.length; j++) {
      var c = children[j];
      if (typeof c === 'string') e.appendChild(document.createTextNode(c));
      else if (c) e.appendChild(c);
    }
    return e;
  }

  function btn(text, onclick) {
    return el('span', { class: 'crb-btn', onclick: onclick }, text);
  }

  // --- Builder state (per instance) ---

  function createBuilder(container, opts) {
    opts = opts || {};
    var rules = opts.initialRules || [];
    var onChange = opts.onChange || function() {};

    function fireChange() {
      onChange(rules);
    }

    function render() {
      container.innerHTML = '';
      container.appendChild(renderRules());
      container.appendChild(renderOutput());
      fireChange();
    }

    function renderOutput() {
      var div = el('div', { class: 'crb-output' });
      div.appendChild(el('strong', 'JSON Output:'));
      div.appendChild(el('pre', { class: 'crb-json' }, JSON.stringify(rules, null, 2)));
      return div;
    }

    function renderOutputOnly() {
      var pre = container.querySelector('.crb-json');
      if (pre) pre.textContent = JSON.stringify(rules, null, 2);
      fireChange();
    }

    function renderRules() {
      var div = el('div', { class: 'crb-rules' });
      for (var i = 0; i < rules.length; i++) {
        div.appendChild(renderRule(rules[i], rules, i));
      }
      div.appendChild(btn('+ Add Rule', function() { rules.push([]); render(); }));
      return div;
    }

    function renderRule(rule, parent, parentIndex) {
      var connective = null;
      for (var i = 0; i < CONNECTIVES.length; i++) {
        if (CONNECTIVES[i].type === rule[0]) { connective = CONNECTIVES[i]; break; }
      }

      var div = el('div', { class: 'crb-rule' });

      // Header row: condition dropdown + delete
      var row = el('div', { class: 'crb-row' });
      row.appendChild(renderCondition(connective, rule));
      row.appendChild(btn('Delete', function() { parent.splice(parentIndex, 1); render(); }));
      div.appendChild(row);

      // Body based on connective type
      if (connective && connective.type2 === 'conjunction') {
        div.appendChild(renderConjunction(rule));
      } else if (connective && connective.type2 === 'comparator') {
        div.appendChild(renderComparator(connective, rule));
      }

      return div;
    }

    function renderCondition(connective, rule) {
      var select = el('select', {
        class: 'form-control crb-select',
        onchange: function(e) {
          var val = e.target.value;
          var newConn = null;
          for (var i = 0; i < CONNECTIVES.length; i++) {
            if (CONNECTIVES[i].type === val) { newConn = CONNECTIVES[i]; break; }
          }
          var oldType2 = connective ? connective.type2 : null;
          var newType2 = newConn ? newConn.type2 : null;
          if (oldType2 !== newType2) {
            rule.length = 0;
            rule.push(val);
          } else {
            rule[0] = val;
          }
          render();
        }
      });

      select.appendChild(el('option', { value: '' }, 'Select Condition'));
      for (var i = 0; i < DROPDOWN_ITEMS.length; i++) {
        var item = DROPDOWN_ITEMS[i];
        var opt = el('option', { value: item.type }, item.js + ' (' + item.type + ')');
        if (item.type === rule[0]) opt.selected = true;
        select.appendChild(opt);
      }
      return select;
    }

    function renderComparator(connective, rule) {
      var values = rule.slice(1);
      var div = el('div', { class: 'crb-comparator' });
      div.appendChild(el('p', { class: 'crb-label' }, 'Value is ' + connective.js));

      for (var i = 0; i < values.length; i++) {
        if (values[i][0] === 'lookup') {
          div.appendChild(renderLookup(values[i], rule, i));
        } else {
          div.appendChild(renderConst(values[i], rule, i));
        }
      }

      var addSelect = el('select', {
        class: 'form-control crb-select crb-add-value',
        onchange: function(e) {
          if (!e.target.value) return;
          rule.push([e.target.value]);
          render();
        }
      });
      addSelect.appendChild(el('option', { value: '' }, 'Add Value...'));
      addSelect.appendChild(el('option', { value: 'lookup' }, 'lookup'));
      addSelect.appendChild(el('option', { value: 'const' }, 'const'));
      div.appendChild(addSelect);
      return div;
    }

    function renderConst(value, rule, valueIndex) {
      var div = el('div', { class: 'crb-value' });
      div.appendChild(el('span', { class: 'label label-info' }, 'const'));
      div.appendChild(el('input', {
        type: 'text', class: 'form-control crb-input',
        placeholder: 'value', value: value[1] || '',
        oninput: function(e) { value[1] = e.target.value; renderOutputOnly(); }
      }));
      div.appendChild(btn('Remove', function() { rule.splice(valueIndex + 1, 1); render(); }));
      return div;
    }

    function renderLookup(value, rule, valueIndex) {
      var div = el('div', { class: 'crb-value' });
      div.appendChild(el('span', { class: 'label label-primary' }, 'lookup'));
      div.appendChild(el('input', {
        type: 'text', class: 'form-control crb-input',
        placeholder: 'lookup.variable.path', value: value[1] || '',
        oninput: function(e) { value[1] = e.target.value; renderOutputOnly(); }
      }));
      div.appendChild(el('input', {
        type: 'text', class: 'form-control crb-input',
        placeholder: 'default value', value: value[2] || '',
        oninput: function(e) { value[2] = e.target.value; renderOutputOnly(); }
      }));
      div.appendChild(btn('Remove', function() { rule.splice(valueIndex + 1, 1); render(); }));
      return div;
    }

    function renderConjunction(rule) {
      var childRules = rule.slice(1);
      var div = el('div', { class: 'crb-conjunction' });
      for (var i = 0; i < childRules.length; i++) {
        div.appendChild(renderRule(childRules[i], rule, i + 1));
      }
      div.appendChild(btn('+ Add Sub-Rule', function() { rule.push([]); render(); }));
      return div;
    }

    // Initial render
    render();
  }

  // --- Public API ---

  window.CaesarRuleBuilder = {
    mount: function(container, opts) {
      if (!container) {
        console.error('CaesarRuleBuilder.mount: container element not found');
        return;
      }
      createBuilder(container, opts);
    }
  };

})(window);
