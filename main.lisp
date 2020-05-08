(defpackage :ms-ime-dic-to-skk-dic-converter
  (:use :cl :cl-ppcre :babel)
  (:import-from :cl-fad
                :file-exists-p
                :directory-exists-p)
  (:export #:converter))

(in-package :ms-ime-dic-to-skk-dic-converter)

(defparameter declare-utf-8-message ";; -*- mode: fundamental; coding: utf-8 -*-")
(defparameter declare-okuri-ari-line ";; okuri-ari entries.")
(defparameter declare-okuri-nasi-line ";; okuri-nasi entries.")


(defun split-from-tab (s)
  (let ((tmp (ppcre:split "\\t" s)))
    (if tmp
        (format nil "~A /~A/" (car tmp) (cadr tmp))
        "")))

(defun split-from-line-code (s)
  (cl-ppcre:split #\linefeed s))

(defun remove-comment-line (l)
  (delete-if (lambda (x) (if (cl-ppcre:scan "^![\\w\\W\\s:]+$" x) t
                             (if (equal x "")
                                 t
                                 nil)))
             l))

(defun open-dic-txt (name &optional (external-format :SJIS) (error-count 0))
  (let ((text nil))
    (with-open-file (input name
                           :direction :input
                           :if-does-not-exist nil
                           :element-type '(unsigned-byte 8))
      (let ((buf (make-array (file-length input) :element-type '(unsigned-byte 8))))
        (read-sequence buf input)
        (setq text (handler-case (babel:octets-to-string buf :encoding external-format)
                     (error (e)
                       (case error-count
                         (0 (open-dic-txt name :UTF-16 (1+ error-count)))
                         (1 (open-dic-txt name :UTF-8 (1+ error-count)))
                         (otherwise
                          (format t "Error!: ~A~%" e)
                          (return-from open-dic-txt 'error))))))
        (cl-ppcre:regex-replace-all #\return text "")))))

(defun write-to-text-file (name l)
  (with-open-file (out name
                       :direction :output
                       :if-exists :supersede)
    (write-line declare-utf-8-message out)
    (write-line declare-okuri-ari-line out)
    (write-line declare-okuri-nasi-line out)
    (dolist (x l)
      (write-line x out))))

(defun converter (l)
  (unless l
    (format t "Missing Arguments!~%")
    (return-from converter nil))
  (dolist (x l)
    (when (and (cl-fad:file-exists-p x) (null (cl-fad:directory-exists-p x)))
      (let ((tmp (remove-comment-line (split-from-line-code (open-dic-txt x)))))
        (let ((result (mapcar #'split-from-tab tmp))
              (out-name (format nil "~A.skkdic" x)))
          (write-to-text-file out-name result)
          (format t "Done! converted ~A to ~A~%~%" x out-name))))))
