package coconut.awt.macros;

#if macro
class Wrapper {
  static public inline var MARKER = ':coconut.wrapper';
  static function build(isContainer:Bool)
    return BuildCache.getType('coconut.awt.helpers.${if (isContainer) 'WrapContainer' else 'WrapComponent'}', null, null, ctx -> {

      var wrapped = ctx.type,
          name = ctx.name;

      var fields = wrapped.getFields(false).sure(),
          target = wrapped.toComplex(),
          path = {
            var cls = wrapped.getClass();
            cls.module + '.' + cls.name;
          };

      var self = name.asComplexType(),
          attributes = [],
          applicators = [];

      var attrCt = TAnonymous(attributes);
      var ret =
        macro class $name {
          static final TYPE = new coconut.awt.helpers.NodeType<$attrCt, $self>($i{name}.new, cast ${EObjectDecl(applicators).at()});
          function new() super();
        }

      ret.kind = TDClass(path.asTypePath(), [], false, true);
      ret.meta = [
        { name: MARKER, params: [], pos: (macro null).pos },
        { name: ':native', params: [macro $v{'coconut.$path'}], pos: (macro null).pos },
      ];

      function add(extra)
        ret.fields = ret.fields.concat(extra.fields);

      add(
        if (isContainer)
          macro class {
            static public function fromHxx(hxxMeta:coconut.awt.helpers.HxxMeta<$target>, attr:$attrCt, ?children:coconut.ui.Children) {
              return coconut.ui.RenderResult.native(TYPE, hxxMeta.ref, hxxMeta.key, attr, children);
            }
          }
        else
          macro class {
            static public function fromHxx(hxxMeta:coconut.awt.helpers.HxxMeta<$target>, attr:$attrCt) {
              return coconut.ui.RenderResult.native(TYPE, hxxMeta.ref, hxxMeta.key, attr);
            }
          }
      );

      var added = new Map();

      function addAttr(name, pos, ct, expr) {
        if (added[name])
          return;
        added[name] = true;
        attributes.push({
          name: name,
          pos: pos,
          kind: FVar(ct),
          access: [AFinal],
          meta: [{ name: ':optional', params: [], pos: pos }],
        });

        applicators.push({
          field: name,
          expr: macro function (target:$self, nu:$ct, ?old:$ct) $expr,
        });
      }

      {//plain properties
        var candidates = new Map(),
            prefixes = ['get', 'is'];

        for (f in fields)
          for (p in prefixes)
            if (f.name.startsWith(p))
              switch f.type.reduce() {
                case TFun([], ret):
                  candidates.set(f.name.substr(p.length), { name: f.name, type: ret });
                default:
              }

        var log = path == 'java.javax.swing.JTextField.JTextField';

        for (f in fields)
          if (f.name.startsWith('set'))
            switch f.type.reduce() {
              case TFun([{ t: t }], TAbstract(_.get() => { pack: [], name: 'Void' }, _)) if (candidates.exists(f.name.substr(3)) && !f.meta.has(':deprecated')):
                var name = f.name.substr(3);
                var setter = f.name,
                    getter = candidates[name].name;

                addAttr(
                  f.name.charAt(3).toLowerCase() + f.name.substr(4), f.pos, t.toComplex(),
                  macro if (nu != target.$getter()) {
                    // if ($v{log}) trace($v{path} + '::' + $v{name} + [nu, old, target.$getter()]);
                    target.$setter(nu);
                  }
                );
              default:
            }
      }

      {//events
        for (f in fields)
          if (f.name.startsWith('add') && f.name.endsWith('Listener'))
            switch f.type.reduce() {
              case TFun([{ t: t }], _):
                var handlers = '_coco_' + f.name.charAt(3).toLowerCase() + f.name.substr(4),
                    ct = t.toComplex();

                var handlersType = f.pos.getOutcome((macro : coconut.awt.helpers.Handlers<$ct>).toType());
                var handlersCt = handlersType.toComplex();

                var getter = 'get_$handlers';

                add(macro class {
                  var $handlers(get, null):$handlersCt;
                  function $getter():$handlersCt {
                    if ($i{handlers} == null)
                      $i{handlers} = new coconut.awt.helpers.Handlers<$ct>($i{f.name}, $i{'remove' + f.name.substr(3)});
                    return $i{handlers};
                  }
                });

                switch handlersType.reduce() {
                  case TInst(_.get() => cls, _):
                    for (f in cls.fields.get())
                      if (f.kind.match(FVar(_)) && f.isPublic) {
                        var name = f.name;
                        var evt = switch f.type.reduce() {
                          case TFun([{ t: t }], _): t.toComplex();
                          default: throw 'assert';
                        }
                        addAttr(name, f.pos, macro : tink.core.Callback<coconut.awt.EventFrom<$target, $evt>>, macro target.$handlers.$name = nu);
                      }
                  default:
                }
              default:
            }
      }



      return ret;
    });
}
#end