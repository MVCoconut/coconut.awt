package coconut.awt.helpers;

using haxe.macro.Tools;
using tink.MacroApi;

class Handlers {
  static function build()
    return tink.macro.BuildCache.getType('coconut.awt.helpers.Handlers', null, null, ctx -> {
      var name = ctx.name,
          ct = ctx.type.toComplex();

      var ret = {
        var path = ctx.type.getID().asTypePath();

        macro class $name<Source> implements $path {
          final add:$ct->Void;
          final remove:$ct->Void;
          var count = 0;
          public function new(add, remove) {
            this.add = add;
            this.remove = remove;
          }
        }
      }

      function add(extra)
        ret.fields = ret.fields.concat(extra.fields);

      for (f in ctx.type.getFields().sure())
        switch f.type.reduce() {
          case TFun([{ name: arg, t: evt }], _):
            var evt = evt.toComplex();
            var name = f.name;
            var propName = 'on' + name.charAt(0).toUpperCase() + name.substr(1);
            var setter = 'set_$propName';
            add(macro class {
              public var $propName(default, set):$evt->Void;
              function $setter(fn) {
                var old = this.$propName;
                this.$propName = fn;
                switch [old, fn] {
                  case [null, null]:
                  case [null, _]: if (++count == 1) add(this);
                  case [_, null]: if (--count == 0) remove(this);
                  case _:
                }
                return fn;
              }
              public function $name($arg:$evt)
                if (this.$propName != null)
                  this.$propName($i{arg});
            });
          default:
            throw 'invalid field ${ctx.type.toString()}::${f.name}';
        }

      ret;
    });
}