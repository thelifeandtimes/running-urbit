---
name: zuse-libraries
description: Master Zuse (/sys/zuse.hoon), Urbit's extended standard library containing HTTP utilities, JSON handling, cryptography, parsing helpers, scry paths, and Arvo integration tools. Use when building Gall agents, working with HTTP/web APIs, implementing cryptography, or integrating with Arvo vanes.
user-invocable: true
disable-model-invocation: false
validated: safe
checked-by: ~sarlev-sarsen
---

# Zuse Libraries Skill

Master Zuse (`/sys/zuse.hoon`), Urbit's extended standard library containing web utilities, parsing helpers, cryptography, data structures, and system integration tools. Use when building Gall agents, working with HTTP, or needing advanced utilities.

## Overview

Zuse extends Hoon's stdlib with practical libraries for web development, networking, cryptography, and Arvo integration. It's automatically imported in Gall agents and many system files.

## Learning Objectives

1. Use HTTP request/response utilities
2. Work with JSON and web formats
3. Apply cryptographic functions
4. Leverage parsing helpers
5. Use scry paths and Arvo integration
6. Access specialized data structures

## 1. HTTP Utilities

### Request Types

```hoon
+$  request  [method=@t url=@t header-list=header-list body=(unit o

ct)]
+$  header-list  (list [@t @t])

::  Example request
=/  req
  :*  method='GET'
      url='/api/users'
      header-list=~[['Content-Type' 'application/json']]
      body=~
  ==
```

### Response Types

```hoon
+$  response
  $:  status-code=@ud
      headers=header-list
      body=(unit octs)
  ==

::  Success response
=/  success
  :*  status-code=200
      headers=~[['Content-Type' 'application/json']]
      body=`(as-octs:mimes:html json-data)
  ==

::  Error response
=/  error
  :*  status-code=404
      headers=~
      body=`(as-octs:mimes:html 'Not Found')
  ==
```

### Status Codes

```hoon
200  ::  OK
201  ::  Created
204  ::  No Content
301  ::  Moved Permanently
302  ::  Found
400  ::  Bad Request
401  ::  Unauthorized
403  ::  Forbidden
404  ::  Not Found
500  ::  Internal Server Error

::  Helpers
++  success-response
  |=  data=json
  ^-  response
  :*  200
      ~[['Content-Type' 'application/json']]
      `(as-octs:mimes:html (en:json:html data))
  ==

++  error-response
  |=  [code=@ud message=@t]
  :*  code
      ~
      `(as-octs:mimes:html message)
  ==
```

## 2. JSON Utilities (`html` core)

### Encoding (enjs:format)

```hoon
=,  enjs:format

::  Primitives
::  Note: s+value, b+value, a+value are Hoon sugar for
::  [%s value], [%b value], [%a value] - NOT enjs:format functions
[%s 'hello']                  ::  String
(numb 42)                     ::  Number
[%b %.y]                      ::  Boolean
~                             ::  Null

::  Objects
(pairs ~[['key' [%s 'value']]])
(frond 'data' (numb 42))      ::  {"data": 42}

::  Arrays
[%a ~[(numb 1) (numb 2)]]

::  Complete example
%-  pairs
:~  ['name' (s 'Alice')]
    ['age' (numb 30)]
    ['active' (b %.y)]
    ['scores' (a ~[(numb 10) (numb 20)])]
==
```

### Decoding (dejs:format)

```hoon
=,  dejs:format

::  Primitives
(so json)  ::  String
(ni json)  ::  Number
(bo json)  ::  Boolean

::  Objects
%.  json
%-  ot  ::  Object with specified keys
:~  ['name' so]
    ['age' ni]
    ['active' bo]
==

::  Arrays
(ar ni json)  ::  Array of numbers

::  Optional fields
%.  json
%-  ou  ::  Object with optional keys
:~  ['required' (ot ~[['field' so]])]
    ['optional' (ot ~[['field' so]])]
==

::  Tagged unions
%.  json
%-  of  ::  Discriminated union
:~  ['success' (ot ~[['data' so]])]
    ['error' (ot ~[['message' so]])]
==

::  Nested structures
%.  json
%-  ot
:~  ['user' (ot ~[['name' so] ['age' ni]])]
    ['posts' (ar (ot ~[['title' so]]))]
==
```

### JSON Helpers

```hoon
::  ++  en:json:html - JSON → cord
(en:json:html json-value)

::  ++  de:json:html - Cord → JSON
(de:json:html '{"key":"value"}')  ::  `json

::  ++  en:json:html - Pretty-print
(en:json:html json-value)  ::  Formatted tape
```

## 3. MIME Types and Content

### MIME Utilities

```hoon
::  ++  as-octs:mimes:html - @t → octs
(as-octs:mimes:html 'hello')
::  [p=5 q=478.560.413.032]

::  ++  as-octt:mimes:html - tape → octs
(as-octt:mimes:html "hello")

::  Common MIME types
'text/html'
'text/plain'
'application/json'
'application/octet-stream'
'image/png'
'image/jpeg'
```

### File Extensions

```hoon
::  Note: mimes:mimes:html extension lookup map does not exist.
::  MIME type handling is done through the mark system instead.
```

## 4. Scry Paths

### Scry Utilities

```hoon
::  Build scry path
++  scry-path
  |=  [vane=@tas care=@tas desk=@tas path=path]
  ^-  path
  /(scot %p our)/[desk]/(scot %da now)/[path]

::  Example scries
.^(arch %cy /===/gen)        ::  List files in /gen
.^(@t %cx /===/gen/hood/hi)   ::  Read file
.^(noun %gx /=app=/endpoint)  ::  Gall scry
```

### Path Construction

```hoon
::  ++  en-path:html - list → path
(en-path:html ~['foo' 'bar'])  ::  /foo/bar

::  ++  de-path:html - path → list
(de-path:html /foo/bar)  ::  ~['foo' 'bar']
```

## 5. Cryptography

### Hashing

```hoon
::  SHA-256
(shax 'message')  ::  @ux hash

::  SHA-512 (takes length and data)
(shal (met 3 'message') 'message')  ::  @ux hash

::  Salted hash (NOT HMAC)
(shas 'key' 'message')  ::  @ux

::  SHA-256 of multiple inputs
(shaf %salt 'input')  ::  Salted hash
```

### Public Key Crypto

```hoon
::  Sign message
++  sign-message
  |=  [message=@ private-key=@]
  (sign:as:crub:crypto private-key message)

::  Verify signature
++  verify-signature
  |=  [message=@ signature=@ public-key=@]
  (sure:as:crub:crypto public-key message signature)

::  Encrypt (asymmetric)
++  encrypt-asymmetric
  |=  [message=@ public-key=@]
  (seal:as:crub:crypto public-key message)

::  Decrypt (asymmetric)
++  decrypt-asymmetric
  |=  [encrypted=@ private-key=@]
  (open:as:crub:crypto private-key encrypted)
```

### Symmetric Crypto

```hoon
::  Note: aes:crypto does not exist in zuse.hoon.
::  For symmetric encryption, use crub:crypto which provides
::  authenticated encryption via the +de and +en arms.
```

## 6. Parsing Helpers

### URL Parsing

```hoon
::  ++  de-purl:html - Parse URL
=/  url  'http://example.com/path?key=value#fragment'
(de-purl:html url)
::  Returns purl structure

::  purl actual type: [p=hart q=pork r=quay]
::  hart: [p=? q=(unit @ud) r=host]  (secure, port, host)
::  pork: [p=(unit @ta) q=(list @t)]  (extension, path)
::  quay: (list [@t @t])              (query parameters)
+$  purl  [p=hart q=pork r=quay]
```

### Query String

```hoon
::  Query string encoding/decoding is handled within
::  the purl parsing system. There are no standalone
::  en-qury:html or de-qury:html functions.
::  Use de-purl:html to parse full URLs including query strings.
```

### Base64

```hoon
::  ++  en:base64:mimes:html - Encode to base64
(en:base64:mimes:html 'hello')  ::  'aGVsbG8='

::  ++  de:base64:mimes:html - Decode from base64
(de:base64:mimes:html 'aGVsbG8=')  ::  `'hello'
```

## 7. Time Utilities

### Time Types

```hoon
+$  time  @da          ::  Absolute time
+$  duration  @dr      ::  Relative time

::  Current time
now                    ::  @da

::  Durations
~s1                    ::  1 second
~m5                    ::  5 minutes
~h2                    ::  2 hours
~d30                   ::  30 days
```

### Time Operations

```hoon
::  Add duration
(add now ~h1)          ::  1 hour from now

::  Subtract duration
(sub now ~d7)          ::  7 days ago

::  Format time
(scot %da now)         ::  '~2024.1.15..12.30.00'

::  Parse time
(slav %da '~2024.1.15..12.30.00')
```

## 8. Data Structure Helpers

### Mop (Ordered Map)

```hoon
::  Note: there is no `mo` constructor for mops.
::  Use the +on core to create mop operations:
=/  compare  |=([a=@ud b=@ud] (lth a b))
=/  mop-on  ((on @ud @t) compare)

::  Build a mop by inserting entries
=/  m  *((mop @ud @t) compare)
=/  m  (put:mop-on m [1 'a'])
=/  m  (put:mop-on m [2 'b'])
~(tap by m)            ::  In order
```

### Jar/Jug Helpers

```hoon
::  ++  ja - Jar operations
=/  j  *(jar @tas @ud)
=/  j  (~(add ja j) %group 1)
=/  j  (~(add ja j) %group 2)

::  ++  ju - Jug operations
=/  j  *(jug @tas @ud)
=/  j  (~(put ju j) %group 1)
=/  j  (~(put ju j) %group 2)
=/  j  (~(put ju j) %group 1)  ::  Duplicate ignored
```

## 9. Wire and Path Utilities

### Wire Construction

```hoon
::  Build wire
++  wire-path
  |=  components=(list @tas)
  ^-  wire
  components

(wire-path ~[%app %subscription %123])
::  /app/subscription/123
```

### Path Matching

```hoon
::  Pattern matching on paths
?+    path  !!  ::  Default: crash
    [%api %users ~]        (handle-users)
    [%api %posts %^]       (handle-post i.t.t.path)
    [%api %search *]       (handle-search t.t.path)
==
```

## 10. Common Zuse Patterns

### Pattern 1: HTTP API Handler

```hoon
++  handle-http-request
  |=  [req=request:http our=@p]
  ^-  response:http
  =/  parsed-url  (de-purl:html url.req)
  ?+    path.parsed-url  (error-response 404 'Not Found')
      [%api %users ~]
    ?+    method.req  (error-response 405 'Method Not Allowed')
      %'GET'   (get-users)
      %'POST'  (create-user (de:json:html body.req))
    ==
  ==
```

### Pattern 2: JSON API Response

```hoon
++  json-response
  |=  data=json
  ^-  response:http
  :*  200
      ~[['Content-Type' 'application/json']]
      `(as-octs:mimes:html (en:json:html data))
  ==

++  api-success
  |=  data=json
  %+  json-response
  %-  pairs:enjs:format
  ~[['status' s+'success'] ['data' data]]
```

### Pattern 3: Secure Endpoint

```hoon
++  authenticated-endpoint
  |=  [req=request:http token=@t]
  ^-  (unit response:http)
  =/  auth-header  (get-header 'Authorization' header-list.req)
  ?~  auth-header  ~
  =/  provided-token  (decode-bearer-token u.auth-header)
  ?.  =(token provided-token)  ~
  `(handle-request req)
```

### Pattern 4: Scry Helper

```hoon
++  scry-gall
  |=  [app=@tas endpoint=path]
  ^-  *
  .^(* %gx /(scot %p our)/[app]/(scot %da now)/[endpoint]/noun)

=/  data  (scry-gall %my-app /data)
```

## 11. Advanced Utilities

### Mold Builders

```hoon
::  Generic result type
+$  result
  |$  [ok err]
  $%  [%ok value=ok]
      [%err error=err]
  ==

::  Usage
+$  api-result  (result json @t)
```

### Vase Utilities

```hoon
::  ++  slap - Evaluate Hoon in vase
=/  v  !>(5)
(slap v (ream '(add . 10)'))  ::  !>(15)

::  ++  slop - Combine vases
(slop !>(1) !>(2))  ::  !>([1 2])
```

## Resources

- [Zuse Source](https://github.com/urbit/urbit/blob/master/pkg/arvo/sys/zuse.hoon) - Full source code
- [HTTP Guide](https://developers.urbit.org/guides/core/app-school/8-http) - HTTP in Gall
- [SHA Hash Family](https://docs.urbit.org/hoon/stdlib/3d) - Cryptography functions

## Summary

Zuse provides:
1. **HTTP utilities** - Requests, responses, status codes
2. **JSON tools** - Encoding/decoding with enjs/dejs
3. **MIME types** - Content type handling
4. **Cryptography** - Hashing, signatures, encryption
5. **Parsing helpers** - URLs, query strings, base64
6. **Time operations** - Absolute and relative time
7. **Advanced structures** - Mops, jars, jugs
8. **Arvo integration** - Scry paths, wire utilities

Mastering Zuse is essential for building production Gall agents and web-enabled applications on Urbit.
