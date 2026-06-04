---
name: sail-markup
description: Master Sail, Hoon's embedded HTML templating language for building server-rendered web UIs with type-safe dynamic content generation, forms, styling, and Gall integration. Use when creating web interfaces, admin panels, server-side rendered pages in Gall agents, or building HTML responses.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Sail Markup Skill

Master Sail, Hoon's HTML templating language for building server-rendered web UIs. Use when creating web interfaces, admin panels, or server-side rendered pages in Gall agents.

## Overview

Sail (stylized as "~[]") is Hoon's embedded HTML templating language, allowing you to write HTML directly in Hoon with type safety and dynamic content generation.

## Learning Objectives

1. Write basic Sail markup
2. Generate dynamic HTML
3. Handle forms and user input
4. Build reusable components
5. Style with inline CSS
6. Integrate with Gall agents
7. Optimize Sail rendering

## 1. Sail Basics

### Hello World

```hoon
;html
  ;head
    ;title: My Page
  ==
  ;body
    ;h1: Hello, World!
    ;p: This is Sail markup.
  ==
==
```

### Sail Syntax Rules

- `;tag` - Start tag
- `;tag: content` - Tag with text content (inline)
- `==` - Close tag
- `;tag;` - Self-closing tag
- `tag-name` - Hyphenated names (becomes tag-name in HTML)

### Basic Tags

```hoon
;div
  ;h1: Heading
  ;p: Paragraph
  ;br;
  ;hr;
  ;span: Inline text
==
```

## 2. Attributes

### Static Attributes

```hoon
;div(class "container")
  ;a(href "https://example.com"): Link
  ;img(src "/image.png", alt "Description");
  ;input(type "text", placeholder "Enter text");
==
```

### Dynamic Attributes

```hoon
=/  url  "https://example.com"
=/  title  "Example Site"
;a(href url, title title): {title}
```

### ID and Class

```hoon
;div(id "main", class "container")
  ;p(class "text-large"): Content
==
```

### Boolean Attributes

```hoon
;input(type "checkbox", checked "");
;button(disabled ""): Disabled
```

## 3. Dynamic Content

### Interpolation

```hoon
=/  name  "Alice"
=/  count  42

;div
  ;h1: Hello, {name}!
  ;p: Count: {(a-co:co count)}
==
```

### Conditional Rendering

```hoon
=/  logged-in  %.y
=/  username  "alice"

;div
  ;+  ?:  logged-in
        ;p: Welcome, {username}!
      ;p: Please log in.
==
```

### Loop/Map

```hoon
=/  items  ~["Apple" "Banana" "Cherry"]

;ul
  ;*  %+  turn  items
      |=  item=@t
      ;li: {(trip item)}
==
```

### Multiple Elements

```hoon
=/  show-header  %.y
=/  show-footer  %.y

;div
  ;*  ?.  show-header  ~
      :~  ;header
            ;h1: My Site
          ==
      ==
  ;main: Content
  ;*  ?.  show-footer  ~
      :~  ;footer
            ;p: Copyright 2024
          ==
      ==
==
```

## 4. Forms

### Basic Form

```hoon
;form(method "post", action "/submit")
  ;label(for "name"): Name:
  ;input(type "text", name "name", id "name");
  ;br;
  ;label(for "email"): Email:
  ;input(type "email", name "email", id "email");
  ;br;
  ;button(type "submit"): Submit
==
```

### Form with Validation

```hoon
=/  error  `(unit @t)`~

;form(method "post")
  ;*  ?~  error  ~
      :~  ;div(class "error"): {(trip u.error)}
      ==
  ;input(type "text", name "username", required "");
  ;button(type "submit"): Login
==
```

### Select Dropdown

```hoon
=/  options  ~["Red" "Green" "Blue"]
=/  selected  "Green"

;select(name "color")
  ;*  %+  turn  options
      |=  opt=@t
      =/  is-selected  =(opt selected)
      ;option(value (trip opt), selected ?:(is-selected "" ~)): {(trip opt)}
==
```

## 5. Styling

### Inline Styles

```hoon
;div(style "color: blue; font-size: 16px;")
  ;p: Styled text
==
```

### CSS Classes

```hoon
=/  is-active  %.y

;div(class ?:(is-active "active" "inactive"))
  ;p: Status
==
```

### Style Block

```hoon
;html
  ;head
    ;style
      ; .container { max-width: 1200px; margin: 0 auto; }
      ; .active { color: green; }
      ; .inactive { color: red; }
    ==
  ==
  ;body
    ;div(class "container active"): Content
  ==
==
```

## 6. Components (Reusable Sail)

### Simple Component

```hoon
++  card-component
  |=  [title=@t content=@t]
  ^-  manx
  ;div(class "card")
    ;h2: {(trip title)}
    ;p: {(trip content)}
  ==

::  Usage
;div
  ;+  (card-component 'Title' 'Content text')
==
```

### List Component

```hoon
++  item-list
  |=  items=(list @t)
  ^-  manx
  ;ul
    ;*  %+  turn  items
        |=  item=@t
        ;li: {(trip item)}
  ==

::  Usage
(item-list ~['First' 'Second' 'Third'])
```

### Layout Component

```hoon
++  page-layout
  |=  [title=@t body=manx]
  ^-  manx
  ;html
    ;head
      ;title: {(trip title)}
      ;meta(charset "UTF-8");
      ;style
        ; body { font-family: sans-serif; }
      ==
    ==
    ;body
      ;header
        ;h1: {(trip title)}
      ==
      ;main
        ;+  body
      ==
      ;footer
        ;p: Footer
      ==
    ==
  ==

::  Usage
%+  page-layout  'My Page'
;div
  ;p: Page content
==
```

## 7. Integration with Gall

### HTTP Response

```hoon
++  render-page
  |=  [req-id=@ta data=state]
  ^-  (quip card _this)
  =/  html
    ;html
      ;head
        ;title: My App
      ==
      ;body
        ;h1: Count: {(a-co:co count.data)}
        ;form(method "post", action "/increment")
          ;button(type "submit"): Increment
        ==
      ==
    ==
  =/  html-text  (en-xml:html html)
  :_  this
  %+  give-simple-payload:app:server  req-id
  [[200 ~[['Content-Type' 'text/html']]] `(as-octs:mimes:html html-text)]
```

### Handling Routes

```hoon
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  !!
      %handle-http-request
    =/  [req-id=@ta req=inbound-request:eyre]  !<([@ta inbound-request:eyre] vase)
    =/  url  (parse-request-line:server url.request.req)
    ?+    site.url  (not-found req-id)
        [%~my-app ~]          (render-home req-id)
        [%~my-app %about ~]   (render-about req-id)
        [%~my-app %item id=@ ~]
      (render-item req-id (slav %ud id.site.url))
    ==
  ==
```

## 8. Advanced Patterns

### Table Generation

```hoon
++  render-table
  |=  data=(list [name=@t age=@ud email=@t])
  ^-  manx
  ;table(class "data-table")
    ;thead
      ;tr
        ;th: Name
        ;th: Age
        ;th: Email
      ==
    ==
    ;tbody
      ;*  %+  turn  data
          |=  [name=@t age=@ud email=@t]
          ;tr
            ;td: {(trip name)}
            ;td: {(a-co:co age)}
            ;td: {(trip email)}
          ==
    ==
  ==
```

### Navigation Menu

```hoon
++  nav-menu
  |=  [current-page=@tas items=(list [@tas @t])]
  ^-  manx
  ;nav
    ;ul
      ;*  %+  turn  items
          |=  [id=@tas label=@t]
          =/  is-current  =(id current-page)
          ;li(class ?:(is-current "active" ""))
            ;a(href "/{(trip id)}"): {(trip label)}
          ==
    ==
  ==

::  Usage
%+  nav-menu  %home
:~  [%home 'Home']
    [%about 'About']
    [%contact 'Contact']
==
```

### Pagination

```hoon
++  pagination
  |=  [current=@ud total=@ud]
  ^-  manx
  ;div(class "pagination")
    ;*  ?.  (gth current 1)  ~
        :~  ;a(href "/page/{(a-co:co (dec current))}"): Previous
        ==
    ;span: Page {(a-co:co current)} of {(a-co:co total)}
    ;*  ?.  (lth current total)  ~
        :~  ;a(href "/page/{(a-co:co +(current))}"): Next
        ==
  ==
```

## 9. Performance Optimization

### Caching

```hoon
|_  state=[page-cache=(map @t manx)]
++  render-cached
  |=  key=@t
  ^-  manx
  =/  cached  (~(get by page-cache.state) key)
  ?^  cached  u.cached
  =/  rendered  (expensive-render key)
  ::  Update cache (in real agent)
  rendered
--
```

### Lazy Loading

```hoon
++  render-lazy-list
  |=  [items=(list item) page=@ud page-size=@ud]
  ^-  manx
  =/  start  (mul page page-size)
  =/  subset  (scag page-size (slag start items))
  ;div
    ;+  (item-list subset)
    ;+  (pagination page (div (lent items) page-size))
  ==
```

## 10. Common Sail Patterns

### Pattern 1: Card/Grid Layout

```hoon
++  card-grid
  |=  items=(list [title=@t description=@t image=@t])
  ^-  manx
  ;div(class "grid")
    ;*  %+  turn  items
        |=  [title=@t description=@t image=@t]
        ;div(class "card")
          ;img(src (trip image), alt (trip title));
          ;h3: {(trip title)}
          ;p: {(trip description)}
        ==
  ==
```

### Pattern 2: Flash Messages

```hoon
++  flash-message
  |=  [type=@tas message=@t]
  ^-  manx
  =/  class  (cat 3 'flash ' type)
  ;div(class (trip class))
    ;p: {(trip message)}
  ==

::  Usage
(flash-message %success 'Operation successful!')
(flash-message %error 'Something went wrong')
```

### Pattern 3: Breadcrumbs

```hoon
++  breadcrumbs
  |=  path=(list [@t @t])  ::  [(url label) ...]
  ^-  manx
  ;nav(class "breadcrumbs")
    ;*  %+  turn  path
        |=  [url=@t label=@t]
        ;span
          ;a(href (trip url)): {(trip label)}
          ;+  ?:  =(path ~)  ;span;
              ;span: " > "
        ==
  ==
```

## 11. Sail Utilities

### Safe HTML Escaping

```hoon
++  escape-html
  |=  text=@t
  ^-  @t
  %-  crip
  %+  turn  (trip text)
  |=  char=@t
  ?+  char  char
    '<'  '&lt;'
    '>'  '&gt;'
    '&'  '&amp;'
    '"'  '&quot;'
    '\''  '&#39;'
  ==
```

### Convert Manx to HTML

```hoon
::  Sail produces 'manx' type
::  Convert to HTML text:
(en-xml:html my-sail-markup)
```

## 12. Testing Sail

### Visual Testing

```hoon
::  Generate HTML file
++  test-render
  ^-  @t
  =/  html  (my-component)
  (en-xml:html html)

::  Save and open in browser
```

### Component Testing

```hoon
++  test-card
  =/  result  (card-component 'Test' 'Content')
  =/  html  (en-xml:html result)
  ::  Verify contains expected elements
  &((has-substring html "Test") (has-substring html "Content"))
```

## Resources

- [Sail Guide](https://developers.urbit.org/guides/additional/dist/sail) - Official Sail documentation
- [HTTP Guide](https://developers.urbit.org/guides/core/app-school/8-http) - Sail with Gall
- [Sail (HTML)](https://docs.urbit.org/hoon/sail) - Sail types

## Summary

Sail markup:
1. **Syntax** - `;tag`, `:` for inline, `==` to close
2. **Attributes** - `(attr "value")`, dynamic with interpolation
3. **Dynamic content** - `{var}`, conditionals with `;+`, loops with `;*`
4. **Components** - Reusable `manx` producing functions
5. **Forms** - Standard HTML forms with Sail syntax
6. **Styling** - Inline styles, CSS classes, style blocks
7. **Gall integration** - HTTP responses with `en-xml:html`
8. **Optimization** - Caching, lazy loading, pagination

Sail enables building server-rendered web UIs directly in Hoon with type safety and dynamic content generation.
