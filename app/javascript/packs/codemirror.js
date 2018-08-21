/* global _ */
"use strict";
import CodeMirror from "codemirror/lib/codemirror";
import "lodash/lodash";

// See: http://codemirror.net/doc/manual.html#modeapi
// and sample mode files: https://github.com/codemirror/CodeMirror/tree/master/mode

CodeMirror.defineMode("fluentd", function() {
  return {
    startState: function(aa) {
      return { "context" : null };
    },
    token: function(stream, state) {
      if (stream.eatWhile(/[ \t]/)) {
        // ignore indenting spaces
        stream.skipTo(stream.peek());
        return;
      }
      if (stream.eol()) {
        // reached end of line
        return;
      }

      switch (stream.peek()) {
      case "#":
        stream.skipToEnd();
        return "comment";
      case "<":
        state.context = "inner-bracket";
        stream.pos += 1;
        return "keyword";
      case ">":
        stream.pos += 1;
        state.context = "inner-definition";
        return "keyword";
      default:
        switch (state.context) {
        case "inner-bracket":
          stream.eat(/[^#<>]+/);
          return "keyword";
        case "inner-definition":
          stream.eatWhile(/[^ \t#]/);
          state.context =  "inner-definition-keyword-appeared";
          return "variable";
        case "inner-definition-keyword-appeared":
          let eatBuiltin = function(stream, state) {
            stream.eatWhile(/[^#]/);
            if (stream.current().match(/\\$/)) {
              stream.next() && eatBuiltin(stream, state);
            } else {
              return;
            }
          };
          eatBuiltin(stream, state);
          state.context = "inner-definition";
          return "builtin";
        default:
          stream.eat(/[^<>#]+/);
          return "string";
        }
      }
    }
  };
});

function codemirrorify(el) {
  return CodeMirror.fromTextArea(el, {
    theme: "neo",
    lineNumbers: true,
    viewportMargin: Infinity,
    mode: "fluentd"
  });
}

$(function(){
  $(".js-fluentd-config-editor").each(function(_, el) {
    codemirrorify(el);
  });
});

Vue.directive("config-editor", {
  bind: function(el, binding, vnode, oldVnode) {
    // NOTE: needed delay for waiting CodeMirror setup
    _.delay(function(textarea) {
      let cm = codemirrorify(textarea);
      // textarea.codemirror = cm; // for test, but doesn't work for now (working on Chrome, but Poltergeist not)
      cm.on("change", function(code_mirror) {
        // bridge Vue - CodeMirror world
        el.dataset.content = code_mirror.getValue();
      });
    }, 0, el);
  }
});
