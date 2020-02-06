package coconut.awt.macros;

#if macro
import tink.hxx.Tag.*;
class Decorator {

  static function build() {
    var t = getLocalType();
    var cls = t.getClass();

    if (cls.meta.has(Wrapper.MARKER)) return null;

    function disallow(reason:String) {
      if (!cls.meta.has(DISALLOW))
        cls.meta.add(DISALLOW, [macro $v{reason}], (macro null).pos);
      return null;
    }

    if (cls.isFinal)
      return disallow('class is final');

    if (cls.isPrivate)
      return disallow('class is private');

    var cur = cls,
        isContainer = false;

    while (!isContainer)
      switch cur {
        case { name: 'Window', pack: ['java', 'awt' ]}:
          return disallow('it is a window');
        case { name: 'Container', pack: ['java', 'awt' ]}:
          isContainer = true;
        case { superClass: null }: break;
        default:
          cur = cur.superClass.t.get();
      }

    var self = t.toComplex(),
        name = if (isContainer) 'WrapContainer' else 'WrapComponent';
    cls.meta.add(DELEGATE, [macro (_:coconut.awt.helpers.$name<$self>)], (macro null).pos);

    return null;
  }
}
#end