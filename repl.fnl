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
;; repl.fnl
;; https://github.com/MorganPeterson/cacheback

(fn new [options]
  (let [mt options
        inputBuffer {:buffer nil :bufferLength 0 :inputLength 0}
        ]
    (tset inputBuffer :input-prompt (fn [] (io.stdout:write "db > ")))
    (tset inputBuffer
          :read-input (fn []
                        (inputBuffer.input-prompt)
                        (tset inputBuffer :buffer (io.read))
                        (tset inputBuffer
                              :bufferLength
                              (string.len (. inputBuffer :buffer)))
                        (tset inputBuffer
                              :inputLength
                              (. inputBuffer :bufferLength))))
    (tset inputBuffer :run (fn [] 
      (while true
        (inputBuffer.read-input)
        (match (. inputBuffer :buffer)
          ".exit" (os.exit 0)))))
    (setmetatable inputBuffer mt)
    inputBuffer))

{: new}
