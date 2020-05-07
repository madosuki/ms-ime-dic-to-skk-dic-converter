(defpackage :ms-ime-dic-to-skk-dic
  (:use :cl :asdf))

(in-package :ms-ime-dic-to-skk-dic)

(defsystem :ms-ime-dic-to-skk-dic
  :name "ms-ime-dic-to-skk-dic"
  :version "0.01"
  :author "madosuki"
  :licence "GPL-3.0"
  :description "MS-IME dictonary file to SKK Dictonary file converter."
  :serial t
  :components ((:file "main"))
  :depends-on ("cl-ppcre" "babel" "cl-fad" "alexandria"))

