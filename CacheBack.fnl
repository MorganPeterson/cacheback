;; ISC License (ISC)
;; Copyright 2021 Morgan Peterson <lastyearsmodel at gmail dot com>

;; Permission to use, copy, modify, and/or distribute this software for any
;; purpose with or without fee is hereby granted, provided that the above
;; copyright notice and this permission notice appear in all copies.
;;
;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
;; IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;;
;; CacheBack.fnl
;; https://github.com/MorganPeterson/cacheback

(local messagepack (require :MessagePack))
(local posix (require :posix))

(fn exists [path posixType]
  "checks if a posix defined location exists"
  (let [stat (posix.stat path)]
    (and (~= stat nil) (= (assert (. stat :type)) posixType))))

(fn load-page [path]
  "Read a db page and unpack it if it exists"
  (let [fp (io.open path "rb")]
    (when fp
      (let [content (messagepack.unpack (fp:read "*a"))]
        (fp:close)
        content))))

(fn save-page [path page]
  "pack a db page and save it to a file"
  (if (= (type page) "table")
    (let [fp (io.open path "wb")]
      (if fp
        (do
          (fp:write (messagepack.pack page))
          (fp:close)
          true)
        false)))
    false)

;; our pool table for export
(local pool {})

(fn db-save [db val]
  "high level save db file method"
  (when val
    (if (and (= (type val) "string") (= (type (. db val)) "table"))
      (save-page (.. (. pool db) "/" val) (. db val))
      false))
  (each [key val (pairs db)]
    (if (not (save-page (.. (. pool db) "/" key) val))
      false))
  true)

;; utility functions
(local dbFuncs {:save db-save})

;; metatable
(local mt {
           :__index (fn [db k]
                     (if (. dbFuncs k)
                       (. dbFuncs k))
                     (when (exists (.. (. pool db) "/" k) :regular)
                         (tset db k (load-page (.. (. pool db) "/" k))))
                     (rawget db k))})

;; set utility functions to pool
(tset pool :utils dbFuncs)

;; set final metatable for pool and export
(setmetatable pool {
                    :__mode "kv"
                    :__call (fn [pool path]
                              (assert (exists path :directory)
                                      (.. path " is not a directory"))
                              (if (. pool path) (. pool path))
                              (let [db {}]
                                (setmetatable db mt)
                                (tset pool path db)
                                (tset pool db path)
                                db))})

