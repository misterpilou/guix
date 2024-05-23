(cons* (channel
  (name 'nonguix)
  (url "https://gitlab.com/nonguix/nonguix")
  (introduction
    (make-channel-introduction
      "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
      (openpgp-fingerprint
      "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"))))
  (channel
    (name 'guix-hpc-non-free)
    (url "https://gitlab.inria.fr/guix-hpc/guix-hpc-non-free.git"))
  ; (channel
  ;   (name 'rde)
  ;   (url "https://git.sr.ht/~abcdw/rde")
  ;   (introduction
  ;     (make-channel-introduction
	; "257cebd587b66e4d865b3537a9a88cccd7107c95"
	; (openpgp-fingerprint
	;  "2841 9AC6 5038 7440 C7E9 2FFA 2208 D209 58C1 DEB0"))))
  (channel
    (name 'emacs)
    (url "https://github.com/babariviere/guix-emacs")
    (introduction
      (make-channel-introduction
      "72ca4ef5b572fea10a4589c37264fa35d4564783"
      (openpgp-fingerprint
      "261C A284 3452 FB01 F6DF  6CF4 F9B7 864F 2AB4 6F18"))))

   %default-channels)
