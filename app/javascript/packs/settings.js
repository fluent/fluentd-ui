$(document).ready(() => {
  const SettingSection = {
    template: '#vue-setting-section',
    props: ['id', 'content', 'type', 'name', 'arg', 'settings'],
    data: function() {
      return {
        mode: 'default',
        processing: false,
        editContent: null
      };
    },
    created: function() {
      this.initialState();
    },
    computed: {
      endpoint: function() {
        return '/api/setting/' + this.id;
      }
    },
    methods: {
      onCancel: function(event) {
        this.initialState();
      },
      onEdit: function(ev) {
        this.mode = "edit";
      },
      onDelete: function(ev) {
        if (!confirm("really?")) {
          return;
        }
        this.destroy();
      },
      onSubmit: function(ev) {
        this.processing = true;
        $.ajax({
          url: this.endpoint,
          method: "POST",
          data: {
            _method: "PATCH",
            id: this.id,
            content: this.editContent
          }
        }).then((data)=> {
          _.each(data, function(v,k){
            this[k] = v;
          });
          this.initialState();
        }).always(()=> {
          this.processing = false;
        });
      },
      initialState: function(){
        this.processing = false;
        this.mode = 'default';
        this.editContent = this.content;
      },
      destroy: function(){
        $.ajax({
          url: this.endpoint,
          method: "POST",
          data: {
            _method: "DELETE",
            id: this.id
          }
        }).then(()=> {
          this.$parent.update();
        });
      }
    }
  };

  new Vue({
    el: "#vue-setting",
    data: function(){
      return {
        loaded: false,
        loading: false,
        sections: {
          sources: [],
          matches: []
        }
      };
    },
    mounted: function() {
      this.$nextTick(() => {
        this.update();
      })
    },
    components: {
      'setting-section': SettingSection
    },
    methods: {
      update: function() {
        this.loading = true;
        $.getJSON("/api/settings", (data)=> {
          var sources = [];
          var matches = [];
          data.forEach((v)=> {
            if(v.name === "source"){
              sources.push(v);
            }else{
              matches.push(v);
            }
          });
          this.sections.sources = sources;
          this.sections.matches = matches;
          this.loaded = true;
          setTimeout(()=> {
            this.loading = false;
          }, 500);
        });
      }
    }
  });
})
