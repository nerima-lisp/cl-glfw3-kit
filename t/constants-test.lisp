(in-package #:cl-glfw3-kit/test)

(describe
  "GLFW constant tables"
  (it "every *GLFW-ERROR-CONDITIONS* entry names a CL-GLFW3-KIT-ERROR subtype"
    (dolist (entry *glfw-error-conditions*)
      (expect (subtypep (cdr entry) 'cl-glfw3-kit-error) :to-be-truthy)))

  (it-property "every *GLFW-ERROR-CONDITIONS* code maps to its paired condition type"
      ((entry (gen-member *glfw-error-conditions*)))
    ;; Avoid leaking the global error cell across property trials.
    (expect (lambda () (%signal-glfw-error (car entry) "property test"))
            :to-throw (cdr entry)))

  (it-property "every known key keyword round-trips through %KEY-CODE/%KEY-KEYWORD"
      ((entry (gen-member *glfw-keys*)))
    (expect (%key-code (car entry)) :to-equal (cdr entry))
    (expect (%key-keyword (cdr entry)) :to-equal (car entry)))

  (it "%KEY-KEYWORD falls back to the raw integer for an unknown key code"
    (expect (%key-keyword 999999) :to-equal 999999))

  (it-property "every known action keyword round-trips through %ACTION-KEYWORD"
      ((entry (gen-member *glfw-actions*)))
    (expect (%action-keyword (cdr entry)) :to-equal (car entry))))

(describe
  "%DECODE-MODS"
  (it "decodes an empty bitmask to no modifiers"
    (expect (%decode-mods 0) :to-equal nil))

  (it "decodes a combined bitmask to every held modifier"
    (expect (sort (%decode-mods (logior #x0001 #x0004)) #'string<)
            :to-equal (sort (list :alt :shift) #'string<))))

(describe
  "%ENCODE-WINDOW-HINT-VALUE"
  (it-property "every boolean hint encodes NIL/T to GLFW_FALSE/GLFW_TRUE"
      ((entry (gen-member *glfw-boolean-window-hints*)))
    (expect (%encode-window-hint-value (car entry) nil) :to-equal (cons (cdr entry) 0))
    (expect (%encode-window-hint-value (car entry) t) :to-equal (cons (cdr entry) 1)))

  (it-property "every integer hint passes its value through unchanged"
      ((entry (gen-member *glfw-integer-window-hints*))
       (value (gen-integer :min 0 :max 8)))
    (expect (%encode-window-hint-value (car entry) value) :to-equal (cons (cdr entry) value)))

  (it "encodes a known enum hint value to its GLFW integer"
    (expect (%encode-window-hint-value :client-api :opengl) :to-equal (cons #x00022001 #x00030001)))

  (it "signals GLFW-INVALID-ENUM for an unknown hint keyword"
    (signals glfw-invalid-enum (%encode-window-hint-value :not-a-real-hint t)))

  (it "signals GLFW-INVALID-ENUM for an unknown enum hint value"
    (signals glfw-invalid-enum (%encode-window-hint-value :client-api :not-a-real-api))))

(describe
  "%ENCODE-WINDOW-HINTS"
  (it "encodes an empty plist to no pairs"
    (expect (%encode-window-hints nil) :to-equal nil))

  (it "encodes a multi-entry plist to one pair per entry, in order"
    (expect (%encode-window-hints (list :resizable nil :samples 4))
            :to-equal (list (cons #x00020003 0) (cons #x0002100d 4)))))
