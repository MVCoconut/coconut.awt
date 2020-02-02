# coconut.awt

**EXPERIMENTAL** coconut backend for awt/swing. 

This backend allows using all subclasses of `java.awt.Component`. This includes swing (please do note that in Haxe the `javax` package is presented as `java.javax` at compile time).

## Attributes

Any pair of `get${CamelCaseOp}` / `set${CamelCaseOp}` and `is${CamelCaseOp}` / `set${CamelCaseOp}` with the right arities is considered an attribute. So this works: 

```jsx
<java.awt.Button label="You cannot click me!" enabled=${false} />
```

## Children

Anything that is a subclass of `java.awt.Container` is allowed to have children, which are added/removed via the corresponding API.

## Events

For any methods of the form `add${EventType}Listener`, coconut.awt will scan all the required methods for the listener and expose them as attributes, prefixed with `on`. A button with a click listener would look like so: 

```jsx
<java.awt.Button label="Click Me!" onMouseClicked=${Sys.println("yeah!")} />
```

If the handler you provide is not a function, it is implicitly wrapped in `event -> $handlerBody`. The event is the regular Java object, wrapped in a special abstract that forwards the full underlying API while adding a `source` property that is typed to the specific component type. E.g.:

```jsx
<java.awt.TextInput onTextValueChanged=${Sys.println(event.source.getText())}/>
```
