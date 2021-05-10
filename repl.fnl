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

(local signal (require :posix.signal))

;; check input reults enum
(local checkInputResult {:SUCCESS 0 :FAILURE 1})

(local validCommands {
                 :select true
                 :insert true
                 })

 (fn signal-handler [signum]
  "handle incoming signals (ctrl+c)"
  (os.exit (+ 128 (or signum 0))))

(fn check-input [buffer]
  "check user input"
  (if (. validCommands buffer)
    (. checkInputResult :SUCCESS)
    (. checkInputResult :FAILURE)))


(fn execute-input [buffer]
  "execute user input"
  (os.exit 0))

(fn illegal-input []
  "handle illegal user input"
  (os.exit 1))

(fn new [options]
  "Create a new REPL given user options"
  (let [mt options
        inputBuffer {:buffer nil :bufferLength 0 :inputLength 0}
        ]

    ;; write prompt to the screen
    (tset inputBuffer :input-prompt (fn [] (io.stdout:write "db > ")))
    
    ;; io reader function
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
    ;; main loop function
    (tset inputBuffer
          :run (fn []
                 (signal.signal signal.SIGINT signal-handler)
                 (signal.signal signal.SIGKILL signal-handler)
                 (signal.signal signal.SIGQUIT signal-handler)
                 (signal.signal signal.SIGSTOP signal-handler)
                 (signal.signal signal.SIGTERM signal-handler)
                 (while true
                   (inputBuffer.read-input)
                   (match (check-input (. inputBuffer :buffer))
                     checkInputResult.FAILURE (illegal-input)
                     checkInputResult.SUCCESS (execute-input
                                                (. inputBuffer :buffer))))))
    (setmetatable mt inputBuffer)
    inputBuffer))

{: new}
