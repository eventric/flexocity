Flexocity
=========

Flexocity is a Flex/AS3 port of the Apache Velocity template engine for Java.

For more information about Velocity see http://velocity.apache.org/

Flexicity supports a subset of Velocity features:

* variable assignment
* conditional statements using if, else, elsif < > = !=
* enumeration using foreach

Usage
=====

*Since Flexocity/Velocity is a template engine there are two parts to the code.  First is the AS3 code in which Flexocity is used to compiled/merged templates with assigned variables.  The second part consists of the actual template files themselves which can be of any type.*

**AS3 code:**

```as3

/**
 * The TEMPLATE_GENERATED event is fired when a template has been sucessfully parsed
 */
Flexocity.addEventListener(FlexocityEvent.TEMPLATE_GENERATED, function(e:FlexocityEvent) {
    
    // the template has been parsed, now we can use it to generate a file
    var template:Template = e.data as Template;
        
    // use a "context" to assign values to the template
    var context:FlexocityContext = new FlexocityContext();
    
    // add some dummy objects to a variable called "customers"
    context.put("customers", [
        {firstName:'Joe',lastName:'Smith',isPublic: true},
        {firstName:'Jim',lastName:'Doe',isPublic: false}
    ]);
        
    var fs:FileStream = new FileStream();
    fs.open("/path/to/output.file", FileMode.WRITE
        
    // merge the context variables into the template file
    template.merge(context, fs);
        
    fs.close();
    
});

/**
 * The TEMPLATE_ERROR is fired when a template cannot be parsed, usually due to syntax errors
 */
Flexocity.addEventListener(FlexocityEvent.TEMPLATE_ERROR, function(e:FlexocityEvent) {
    var errorMessage:String = event.data as String;
    // handle the error as appropriate...
});
    
// PARSING STARTS HERE:
// initialize the generation process.  note that the UIComponent param
// is used only for it's callLater method
Flexocity.generateTemplate("/path/to/template.file",parentUiComponent);

// template generation is asychronous so wait for the events to fire...
```

**Template Code:**

*This is an example snippet of a template that produces HTML.  Note that Flexocity is not limited to producing HTML and does not really care what type of file is being generated.  This is only an example of one potential type of output:*

```html
<html>
<body>
#{foreach(${customer} in ${customers})}
    #{if(${customer.isPublic}==true)}
        <div>Customer Name: ${customer.firstName} ${customer.lastName}</div>
    #{end}
#{end}
</body>
</html>
```

License
=======

Released under the same terms as Velocity, the [Apache Software License V2](http://velocity.apache.org/engine/devel/license.html)

Flexocity includes a copy of [AS3CoreLib](https://github.com/mikechambers/as3corelib ) which is released under the [BSD License](http://opensource.org/licenses/bsd-license.php)
