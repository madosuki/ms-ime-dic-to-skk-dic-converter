(defpackage :ms-ime-dic-to-skk-dic-converter-asd
  (:use :cl :asdf))

(in-package :ms-ime-dic-to-skk-dic-converter-asd)

(defsystem :ms-ime-dic-to-skk-dic-converter
  :name "ms-ime-dic-to-skk-dic-converter"
  :version "0.1"
  :author "madosuki"
  :licence "GPL-3.0"
  :description "MS-IME dictonary file to SKK Dictonary file converter."
  :serial t
  :components ((:file "main"))
  :depends-on ("cl-ppcre" "babel" "cl-fad"))

