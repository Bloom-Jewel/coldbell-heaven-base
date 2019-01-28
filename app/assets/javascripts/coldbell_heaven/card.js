(function(){
  var path_frag = window.location.pathname.split('/');
  var fun_to_glob = {};
  function anti_constructor(cls) {
    if (this instanceof arguments.callee) throw new TypeError();
    delete cls.constructor;
  }
  function expect_constructor(obj, cls) {
    if (this instanceof arguments.callee) throw new TypeError();
    if (obj instanceof cls) return;
    throw new TypeError('cannot call constructor without new');
  }
  function expect_function(obj, cls) {
    if (this instanceof arguments.callee) throw new TypeError();
    if (obj instanceof cls) throw new TypeError('cannot call as constructor');
  }
  [anti_constructor, expect_constructor, expect_function].forEach(function(f){anti_constructor(f);});
  
  function class_inherit(parentClass,childClass) {
    expect_function(this, class_inherit);
    childClass.prototype = Object.create(parentClass.prototype);
    childClass.prototype.constructor = childClass;
  }
  switch(path_frag[2]){
  case 'card':
    function Card(id) {
      expect_constructor(this, Card);
      this.id = id;
    }
    function ProduceCard(id) {
      Card.apply(this,arguments);
    }
    function SupportCard(id) { 
      Card.apply(this,arguments);
      this.level = 1;
      this.tier = {};
    }
    class_inherit(Card, ProduceCard);
    class_inherit(Card, SupportCard);
    ['vocal','dance','visual','mental','skill_point'].forEach(function(stat){
      SupportCard.prototype['get_'+stat] = function linear_stat(level) {
        var tier_list = Object.keys(this.tier).map(Number).sort();
        var c_tier = tier_list[0], n_tier = tier_list[0];
        level = Number(level || this.level);
        c_tier = tier_list.filter(function(lv){return lv < level}).sort(function(a,b){return b-a;})[0] || c_tier || 0;
        n_tier = tier_list[Math.max(tier_list.indexOf(c_tier) + 1,0)] || 1;
        return Math.floor((this.tier[c_tier][stat] | 0) + (this.tier[n_tier][stat] | 0) * (level - c_tier)/(n_tier - c_tier));
      }
    });
    
    window.addEventListener('load',function(){
      var
        cardtabs = document.querySelectorAll('.card-detail-tab');
        seltabs  = document.querySelectorAll('#card-detail-tabs li[data-key]');
      seltabs.forEach(function(self){
        var elm = null;
        cardtabs.forEach(function(other){
          (!elm)&&(other.id==self.dataset.key)&&(elm=other);
        });
        var cardothers = [];
        cardtabs.forEach(function(other){
          (other != elm) && (cardothers.push(other));
        });
        self.parentNode.addEventListener('click',function(e){
          e.preventDefault();
          if(
            (elm.style.display == 'block') ||
            (seltabs.length <= 1) ||
            false
          ) {
            return false;
          }
          var repl = !cardothers.some(function(other){other.style.display=='none';}), hmet;
          cardothers.forEach(function(other){other.style.display='none';});
          seltabs.forEach(function(tab){tab.classList.remove('active');});
          self.classList.add('active');
          elm.style.display='block';
          hmet = repl ? 'replaceState' : 'toString';
          window.history[hmet](window.history.state, window.title, '#' + self.dataset.key);
        },true);
      });
      (function(){
        var
          hash = window.location.hash.slice(1),
          seltab = null;
        seltabs.forEach(function(elm){
          ((!seltab)&&(elm.dataset.key==hash))&&(seltab=elm);
        });
        seltab || (seltab = seltabs[0]);
        seltab.classList.add('active');
        seltab.parentNode.click();
      }).call(this);
    },true);
    
    fun_to_glob['ShinymasPCard'] = ProduceCard;
    fun_to_glob['ShinymasSCard'] = SupportCard;
    break;
  };
  Object.keys(fun_to_glob).forEach(function(glob_key){
    window[glob_key] = fun_to_glob[glob_key];
  });
}).call(this);
