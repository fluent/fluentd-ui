// See: http://codemirror.net/doc/manual.html#modeapi
// and sample mode files: https://github.com/codemirror/CodeMirror/tree/master/mode


CodeMirror.defineMode('fluentd', function(){
  return {
    startState: function(aa){
      return { "context" : null };
    },
    token: function(stream, state){
      if(stream.eatWhile(/[ \t]/)){
        // ignore indenting spaces
        stream.skipTo(stream.peek());
        return;
      }
      if(stream.eol()){
        // reached end of line
        return;
      }

      switch(stream.peek()){
        case "#":
          stream.skipToEnd();
          return "comment";
          break;
        case "<":
          state.context = "inner-bracket";
          stream.pos += 1;
          return "keyword";
          break;
        case ">":
          stream.pos += 1;
          state.context = "inner-definition";
          return "keyword";
          break;
        default:
          switch(state.context){
            case "inner-bracket":
              stream.eat(/[^#<>]+/);
              return "keyword";
              break;
            case "inner-definition":
              var key = stream.eatWhile(/[^ \t#]/);
              state.context =  "inner-definition-keyword-appeared";
              return "variable";
              break;
            case "inner-definition-keyword-appeared":
              var key = stream.eatWhile(/[^#]/);
              state.context = "inner-definition";
              return "builtin";
              break;
            default:
              stream.eat(/[^<>#]+/);
              return "string";
          }
      }
    }
  };
});
