CacheBack DB
===========

CacheBack is a serverless NoSQL database utilizing Lua Tables for reads and<br>
writes. It is written in Fennel.

Dependencies
===========

1. [Fennel](https://fennel-lang.org/)
2. [lua-posix](https://github.com/luaposix/luaposix)
3. [lua-messagepack](https://fperrad.frama.io/lua-MessagePack/)

Usage
===========

Copy CacheBack.fnl where where your libraries are.
```fennel
(local cacheback (require :CacheBack)
```

1. Attach to your directory(database)
```fennel
(local cbdb (cacheback './db'))
```

2. If there is no pages(file/table) in your directory(database), create one
```fennel
(if (not (. cbdb :page))
  (tset cbdb :page {}))
```

3. Store key-value pair
```fennel
(tset (. cbdb :page) key value)
```

4. Retreive value
```fennel
(. (. cbdb :page) key)
```

5. Save to file
```fennel
(cacheback.utils.save cbdb :page)
```
